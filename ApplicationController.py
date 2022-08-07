from PyQt5.QtCore import pyqtSignal as Signal, QObject, QTimer, QUrl, QThread
from PyQt5.QtCore import pyqtProperty as Property
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtNetwork import QNetworkAccessManager, QNetworkRequest, QNetworkReply
import threading
import serial
import json

from Node import Node
from SerialWorker import SerialWorker
from NFCWorker import NFCWorker
from ZeroConfWorker import ZeroConfWorker

INACTIVITY_TIMEOUT = 10  # Seconds
FAILED_REQUEST_TRY_AGAIN = 30  # Seconds


class ApplicationController(QObject):
    serverReachableChanged = Signal()
    modifiersChanged = Signal()
    nodesChanged = Signal()
    authenticationRequiredChanged = Signal()
    authenticationScannerAttachedChanged = Signal()
    inactivityTimeout = Signal()
    userNameChanged = Signal()
    accessLevelChanged = Signal()
    showModifierFailedMessage = Signal()
    showUnknownAccessCardMessage = Signal()

    def __init__(self, parent=None, rfid_card = None):
        QObject.__init__(self, parent)

        self._rfid_card = rfid_card

        self._startZeroConfThreads()
        self._data = []
        self._server_reachable = False

        self._authentication_required = True
        self._authentication_scanner_attached = False

        self._network_manager = QNetworkAccessManager()
        self._network_manager.finished.connect(self._onNetworkFinished)

        # Since the serial handling is done on a seperate thread, we need an extra handler.
        self._serial_network_manager = None

        self._modifiers = []

        self._failed_update_modifier_timer = QTimer()
        self._failed_update_modifier_timer.setInterval(FAILED_REQUEST_TRY_AGAIN * 1000)
        self._failed_update_modifier_timer.setSingleShot(True)
        self._failed_update_modifier_timer.timeout.connect(self.requestModifiersData)

        self._failed_update_nodes_timer = QTimer()
        self._failed_update_nodes_timer.setInterval(FAILED_REQUEST_TRY_AGAIN * 1000)
        self._failed_update_nodes_timer.setSingleShot(True)
        self._failed_update_nodes_timer.timeout.connect(self.requestKnownNodes)

        self._inactivity_timer = QTimer()
        self._inactivity_timer.setInterval(INACTIVITY_TIMEOUT * 1000)
        self._inactivity_timer.setSingleShot(True)

        self._user_name = "Unknown"
        self._access_level = 0
        self._serial_worker = None
        self._serial = None
        self._server_reachable_count = 0
        if self._rfid_card:
            self.setAuthenticationRequired(False)
        else:
            # Check for RFID scanner as normal
            self._createSerial()
            self._inactivity_timer.timeout.connect(self.onInactivityTimeout)

    def _onServerAddressChanged(self):
        for node in self._data:
            node.updateServerUrl(self._zeroconf_worker.server_address)
        self.requestModifiersData()
        self.requestKnownNodes()
        if self._rfid_card:
            self.onCardDetected(self._rfid_card)

    def setAuthenticationRequired(self, auth_required: bool) -> None:
        if self._authentication_required != auth_required:
            if not auth_required:
                self._inactivity_timer.start()  # User just logged in, so start the logout timer.
            self._authentication_required = auth_required
            self.authenticationRequiredChanged.emit()

    def onInactivityTimeout(self):
        self.logout()

    def setAccessLevel(self, access_level):
        if self._access_level != access_level:
            self._access_level = access_level
            self.accessLevelChanged.emit()

    def setUserName(self, user_name):
        if self._user_name != user_name:
            self._user_name = user_name
            self.userNameChanged.emit()

    @Property(str, notify=userNameChanged)
    def userName(self):
        return self._user_name

    @Property(int, notify=accessLevelChanged)
    def accessLevel(self):
        return self._access_level

    @Slot()
    def tickleTimeout(self):
        self._inactivity_timer.start()

    @Slot()
    def logout(self):
        self.setAuthenticationRequired(True)
        self.setUserName("")
        self._rfid_card = None
        self.setAccessLevel(0)

    def getBaseUrl(self):
        return f"http://{self._zeroconf_worker.server_address}:5000"

    def onCardDetected(self, card_id):
        print("A CARD WAS DETECTED!", card_id)
        self.tickleTimeout()
        if card_id == self._rfid_card:
            return  # Same card as before. Don't request permission again!
        self._rfid_card = card_id
        RFID_url = f"{self.getBaseUrl()}/RFID/{card_id}/"
        for node in self._data:
            node.setAccessCard(card_id)
        self._network_manager.get(QNetworkRequest(QUrl(RFID_url)))

    def _startSerialThreads(self):
        print("starting serial threads")

        self._serial_worker = NFCWorker()
        self._serial_thread = QThread()
        self._serial_thread.started.connect(self._serial_worker.run)
        self._serial_worker.cardDetected.connect(self.onCardDetected)  # Connect your signals/slots
        self._serial_worker.finished.connect(self._createSerial)
        self._serial_worker.moveToThread(self._serial_thread)  # Move the Worker object to the Thread object
        self._serial_thread.start()

    def _startZeroConfThreads(self):
        print("starting zeroconf")
        self._zeroconf_worker = ZeroConfWorker()

        self._zeroconf_thread = QThread()
        self._zeroconf_thread.started.connect(self._zeroconf_worker.start)
        self._zeroconf_worker.serverAddressChanged.connect(self._onServerAddressChanged)
        self._zeroconf_worker.moveToThread(self._zeroconf_thread)

        self._zeroconf_thread.start()

    def _createSerial(self):
        self._authentication_scanner_attached = False
        self.authenticationScannerAttachedChanged.emit()
        self._serial = None
        '''print("Attempting to create serial")
        for i in range(0, 10):
            try:
                port = "/dev/ttyUSB%s" % i
                self._serial = serial.Serial(port, 9600, timeout=0.1)
                print("Connected with serial %s" % port)
                break
            except:
                pass
            try:
                port = "/dev/ttyACM%s" % i
                self._serial = serial.Serial(port, 9600, timeout=0.1)
                print("Connected with serial %s" % port)
                break
            except:
                pass

        if self._serial is not None:
            # Call latertext
            self._authentication_scanner_attached = True
            self.authenticationScannerAttachedChanged.emit()
            threading.Timer(2, self._startSerialThreads).start()
        else:
            print("Unable to create serial. Attempting again in a few seconds.")
            # Check again after a bit of time has passed
            threading.Timer(10, self._createSerial).start()'''

        threading.Timer(2, self._startSerialThreads).start()

    @Property(bool, notify=authenticationRequiredChanged)
    def authenticationRequired(self):
        return self._authentication_required

    @Property(bool, notify=authenticationScannerAttachedChanged)
    def authenticationScannerAttached(self):
        print("AUTH SCANNER ATTACHED", self._authentication_scanner_attached)
        return self._authentication_scanner_attached

    def requestModifiersData(self):
        # This is pretty static data so we only need to request this once.
        modifier_data_url = f"{self.getBaseUrl()}/modifier/"
        self._network_manager.get(QNetworkRequest(QUrl(modifier_data_url)))

    def requestKnownNodes(self):
        print('requesting nodes')
        # Debug function
        modifier_data_url = f"{self.getBaseUrl()}/node/"
        self._network_manager.get(QNetworkRequest(QUrl(modifier_data_url)))

    def _onNetworkFinished(self, reply: QNetworkReply):
        status_code = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        if status_code == 503:
            self.onServerReachableChanged(False)
        url_string = reply.url().toString()
        if "/modifier/" in url_string:
            if status_code == 404:
                print("server was not found!")
                self._failed_update_modifier_timer.start()
                return
            data = bytes(reply.readAll())
            try:
                self._modifiers = json.loads(data)
                self.onServerReachableChanged(True)
            except:
                print("Failed to get modifier data")
                self._failed_update_modifier_timer.start()
                return
            self.modifiersChanged.emit()
        elif "RFID" in url_string:
            if status_code != 404:
                if self._serial_worker:
                    self._serial_worker.setReadResult(True)
                self.setAuthenticationRequired(False)
                self.onServerReachableChanged(True)
                data = bytes(reply.readAll())
                data = json.loads(data)
                self.setUserName(data["user_name"])
                user_data_url = f"{self.getBaseUrl()}/user/{data['user_name']}/"
                self._network_manager.get(QNetworkRequest(QUrl(user_data_url)))
            else:
                print("UNKNOWN CARD!")
                self.showUnknownAccessCardMessage.emit()
                self._serial_worker.setReadResult(False)
                self.setAuthenticationRequired(True)
                self.onServerReachableChanged(True)
        elif "/modifiers/" in url_string:
            if status_code == 403:
                self.showModifierFailedMessage.emit()
            self.onServerReachableChanged(True)
        elif "/user/" in url_string:
            if status_code not in [404, 500] and self._user_name != "":
                data = bytes(reply.readAll())
                data = json.loads(data)
                self.onServerReachableChanged(True)
                self.setAccessLevel(data["engineering_level"])
        else:
            # Yeah it's hackish, but it's faster than building a real system. For now we don't need more
            if status_code == 404:
                print("Server was not found!")
                self._failed_update_nodes_timer.start()
                self.onServerReachableChanged(False)
                return
            data = bytes(reply.readAll())

            try:
                data = json.loads(data)
                self.onServerReachableChanged(True)
                for item in data:
                    new_node = Node(item["node_id"])
                    new_node.setAccessCard(self._rfid_card)
                    new_node.updateServerUrl(self._zeroconf_worker.server_address)
                    self._data.append(new_node)
                    new_node.serverReachableChanged.connect(self.onServerReachableChanged)

                self._data = sorted(self._data, key=lambda node: node.id)  # sort by age
                self._data.reverse()
                self.nodesChanged.emit()
            except Exception as e:
                print("Failed to get modifier data", e)
                self._failed_update_nodes_timer.start()

    def onServerReachableChanged(self, is_server_reachable):
        if not is_server_reachable:
            self._server_reachable_count += 1
        else:
            self._server_reachable_count = 0

        if self._server_reachable_count > 50 and self._server_reachable:
            self._server_reachable = False
            self.serverReachableChanged.emit()
        if not self._server_reachable and is_server_reachable:
            self._server_reachable = True
            self.serverReachableChanged.emit()

    @Property("QVariantList", notify=modifiersChanged)
    def modifierData(self):
        return self._modifiers

    @Slot(str, result="QVariant")
    def getModifierByType(self, modifier_type):
        for modifier in self._modifiers:
            if modifier["type"] == modifier_type:
                return modifier

    @Property("QVariantList", notify=nodesChanged)
    def nodeData(self):
        return self._data

    @Property(bool, notify=serverReachableChanged)
    def serverReachable(self):
        return self._server_reachable

    @Slot(str, result="QVariant")
    def getNodeById(self, node_id: str):
        for node in self._data:
            if node.id == node_id:
                return node

    @Slot(str, str)
    def addModifier(self, modifier: str, node_id: str):
        data = "{\"modifier_name\": \"%s\"}" % modifier

        modifiers_url = f"{self.getBaseUrl()}/node/{node_id}/modifiers/?accessCardID={self._rfid_card}"
        print(modifiers_url)
        request = QNetworkRequest(QUrl(modifiers_url))
        request.setHeader(QNetworkRequest.ContentTypeHeader, "application/json")

        reply = self._network_manager.post(request, data.encode())

