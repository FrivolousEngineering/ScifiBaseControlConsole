from PyQt5.QtNetwork import QNetworkAccessManager, QNetworkReply, QNetworkRequest
from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtCore import QUrl, QObject, QRect, QTimer, QThread, QCoreApplication
from PyQt5.QtCore import pyqtSignal as Signal
from PyQt5.QtCore import pyqtProperty as Property
from PyQt5.QtCore import pyqtSlot as Slot

import threading
import serial
import time

from PyQt5.QtQml import QQmlApplicationEngine,QQmlEngine, QQmlComponent
import json

from Node import Node
from RadialBar import RadialBar

import sys


class TestObject(QObject):
    serverReachableChanged = Signal()
    modifiersChanged = Signal()
    nodesChanged = Signal()
    authenticationRequiredChanged = Signal()

    def __init__(self, parent=None):
        QObject.__init__(self, parent)

        self._data = []
        self._server_reachable = False

        self._authentication_required = True

        self._network_manager = QNetworkAccessManager()
        self._network_manager.finished.connect(self._onNetworkFinished)

        # Since the serial handling is done on a seperate thread, we need an extra handler.
        self._serial_network_manager = None

        self._modifiers = []

        self._failed_update_modifier_timer = QTimer()
        self._failed_update_modifier_timer.setInterval(10000)
        self._failed_update_modifier_timer.setSingleShot(True)
        self._failed_update_modifier_timer.timeout.connect(self.requestModifiersData)

        self.requestModifiersData()

        self._failed_update_nodes_timer = QTimer()
        self._failed_update_nodes_timer.setInterval(10000)
        self._failed_update_nodes_timer.setSingleShot(True)
        self._failed_update_nodes_timer.timeout.connect(self.requestKnownNodes)

        self.requestKnownNodes()

        self._serial = None
        self._createSerial()

        # Handle listening to serial.
        self._serial_listen_thread = QThread()
        self._serial_listen_thread.started.connect(self._handleSerial)

    def _startSerialThreads(self):
        print("starting serial threads")
        self._serial_listen_thread.start()

    def _createSerial(self):
        print("Attempting to create serial")
        for i in range(0, 10):
            try:
                port = "/dev/ttyUSB%s" % i
                self._serial = serial.Serial(port, 9600, timeout=3)
                print("Connected with serial %s" % port)
                break
            except:
                pass
            try:
                port = "/dev/ttyACM%s" % i
                self._serial = serial.Serial(port, 9600, timeout=3)
                print("Connected with serial %s" % port)
                break
            except:
                pass

        if self._serial is not None:
            # Call later
            threading.Timer(2, self._startSerialThreads).start()
        else:
            print("Unable to create serial. Attempting again in a few seconds.")
            # Check again after a bit of time has passed
            threading.Timer(30, self._createSerial).start()

    def _handleSerial(self):
        self._serial_network_manager = QNetworkAccessManager()
        self._serial_network_manager.finished.connect(self._onSerialNetworkFinished)
        while self._serial is not None:
            QCoreApplication.processEvents()
            try:
                line = self._serial.readline()
                if not line:
                    # Skip empty commands
                    continue
                #TODO: clean up this horrible excuse of code.
                if line.startswith(b"start"):
                    print("Serial started as expected")
                else:
                    # We got an access code
                    card_id = line.rstrip()
                    RFID_url = "http://localhost:5000/RFID/{card_id}/".format(card_id=card_id.decode("utf-8"))
                    self._serial_network_manager.get(QNetworkRequest(QUrl(RFID_url)))
            except Exception as e:
                print("failed", e)
                time.sleep(0.1)  # Prevent error spam.


    @Property(bool, notify=authenticationRequiredChanged)
    def authenticationRequired(self):
        return self._authentication_required

    def requestModifiersData(self):
        # This is pretty static data so we only need to request this once.
        modifier_data_url = "http://localhost:5000/modifier/"
        self._network_manager.get(QNetworkRequest(QUrl(modifier_data_url)))
        
    def requestKnownNodes(self):
        # Debug function
        modifier_data_url = "http://localhost:5000/node/"
        self._network_manager.get(QNetworkRequest(QUrl(modifier_data_url)))

    def _onSerialNetworkFinished(self, reply: QNetworkReply):
        status_code = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        if status_code != 404:
            self._authentication_required = False
            self.authenticationRequiredChanged.emit()
            self._serial.write(b"ok\n")
        else:
            self._serial.write(b"nok\n")

    def _onNetworkFinished(self, reply: QNetworkReply):
        status_code = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        if reply.url() == QUrl('http://localhost:5000/modifier/'):
            if status_code == 404:
                print("server was not found!")
                self._failed_update_modifier_timer.start()
                return
            data = bytes(reply.readAll())

            try:
                self._modifiers = json.loads(data)
            except:
                print("Failed to get modifier data")
                self._failed_update_modifier_timer.start()
                return
            self.modifiersChanged.emit()
        else:
            # Yeah it's hackish, but it's faster than building a real system. For now we don't need more
            if status_code == 404:
                print("Server was not found!")
                self._failed_update_nodes_timer.start()
                return
            data = bytes(reply.readAll())

            try:
                data = json.loads(data)
                for item in data:
                    new_node = Node(item["node_id"])
                    self._data.append(new_node)
                    new_node.serverReachableChanged.connect(self.serverReachableChanged)
                self.nodesChanged.emit()
            except:
                print("Failed to get modifier data")
                self._failed_update_nodes_timer.start()
                return

    @Property("QVariantList", notify = modifiersChanged)
    def modifierData(self):
        return self._modifiers

    @Slot(str, result = "QVariant")
    def getModifierByType(self, modifier_type):
        for modifier in self._modifiers:
            if modifier["type"] == modifier_type:
                return modifier

    @Property("QVariantList", notify = nodesChanged)
    def nodeData(self):
        return self._data

    @Property(bool, notify = serverReachableChanged)
    def serverReachable(self):
        return all([node.server_reachable for node in self._data])

    @Slot(str, result = "QVariant")
    def getNodeById(self, nodeId):
        for node in self._data:
            if node.id == nodeId:
                return node





class MyQmlApplication(QApplication):
    _application_name = "UNDEFINED"
    _qquickview = None
    _engine = None
    _settings = None

    def __init__(self, title, args):
        QApplication.__init__(self, args)
        qmlRegisterType(RadialBar, "SDK", 1, 0, "RadialBar")
        self._qquickview = QQuickView()
        self._qquickview.setTitle(title)

        self._engine = self._qquickview.engine()

    def showAndExec(self, qml_url):
        beep = TestObject()
        self._qquickview.rootContext().setContextProperty("backend", beep)
        self._qquickview.setSource(qml_url)
        self._qquickview.show()
        return self.exec_()


if __name__ == '__main__':
    app = MyQmlApplication('Test',sys.argv)
    app.showAndExec(QUrl("view.qml"))



'''if __name__ == '__main__':
    app = QApplication([])

    view = QQuickView()
    engine = QQmlApplicationEngine()
    ctx = engine.rootContext()
    beep = TestObject()
    ctx.setContextProperty("backend", beep)
    engine.load("view.qml")

    #qmlRegisterType(RadialBar, "SDK", 1, 0, "RadialBar")
    #url = QUrl("view.qml")
    win = engine.rootObjects()[0].show()
    #view.rootContext().setContextProperty("backend", beep)
    #view.setSource(url)

    #view.show()
    app.exec_()'''