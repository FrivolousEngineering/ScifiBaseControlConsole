from typing import Callable, Dict

from PyQt5.QtCore import QObject, QTimer, QByteArray, QUrl
from PyQt5.QtCore import pyqtSignal as Signal
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtCore import pyqtProperty as Property

from PyQt5.QtNetwork import QNetworkAccessManager, QNetworkReply, QNetworkRequest

import json

from NodeResource import NodeResource


class Node(QObject):
    def __init__(self, node_id: str, parent=None):
        QObject.__init__(self, parent)
        self._temperature = 293
        self._node_id = node_id
        self._server_url = "localhost"
        self._access_card = ""
        self.updateServerUrl(self._server_url)

        self._all_chart_data = {}

        self._network_manager = QNetworkAccessManager()
        self._network_manager.finished.connect(self._onNetworkFinished)
        self._data = None
        self._enabled = True
        self._incoming_connections = []
        self._outgoing_connections = []
        self._onFinishedCallbacks = {}  # type: Dict[QNetworkReply, Callable[[QNetworkReply], None]]
        self._description = ""
        self._static_properties = {}
        self._performance = 1
        self._target_performance = 1
        self._min_performance = 0.5
        self._max_performance = 1
        self._max_safe_temperature = 500
        self._heat_convection = 1.0
        self._heat_emissivity = 1.0
        self._modifiers = []
        self._active = True

        self._update_timer = QTimer()
        self._update_timer.setInterval(10000)
        self._update_timer.setSingleShot(False)
        self._update_timer.timeout.connect(self.partialUpdate)


        # Timer that is used when the server could not be reached.
        self._failed_update_timer = QTimer()
        self._failed_update_timer.setInterval(10000)
        self._failed_update_timer.setSingleShot(True)
        self._failed_update_timer.timeout.connect(self.fullUpdate)

        self._additional_properties = []
        self._converted_additional_properties = {}
        self.server_reachable = False
        self._optimal_temperature = 200
        self._is_temperature_dependant = False
        self._resources_required = []
        self._optional_resources_required = []
        self._resources_received = []
        self._resources_produced = []
        self._resources_provided = []
        self._health = 100


        self._max_amount_stored = 0
        self._amount_stored = 0
        self._effectiveness_factor = 0
        self.fullUpdate()

    temperatureChanged = Signal()
    historyPropertiesChanged = Signal()
    historyDataChanged = Signal()
    enabledChanged = Signal()
    incomingConnectionsChanged = Signal()
    outgoingConnectionsChanged = Signal()
    performanceChanged = Signal()
    staticPropertiesChanged = Signal()
    modifiersChanged = Signal()
    additionalPropertiesChanged = Signal()
    minPerformanceChanged = Signal()
    maxPerformanceChanged = Signal()
    maxSafeTemperatureChanged = Signal()
    heatConvectionChanged = Signal()
    heatEmissivityChanged = Signal()
    serverReachableChanged = Signal()
    isTemperatureDependantChanged = Signal()
    optimalTemperatureChanged = Signal()
    targetPerformanceChanged = Signal()
    resourcesRequiredChanged = Signal()
    optionalResourcesRequiredChanged = Signal()
    resourcesReceivedChanged = Signal()
    resourcesProducedChanged = Signal()
    resourcesProvidedChanged = Signal()
    healthChanged = Signal()
    maxAmountStoredChanged = Signal()
    amountStoredChanged = Signal()
    effectivenessFactorChanged = Signal()
    activeChanged = Signal()

    def setAccessCard(self, access_card):
        self._access_card = access_card
        self._updateUrlsWithAuth(self._server_url, access_card)

    def _updateUrlsWithAuth(self, server_url, access_card):
        self._performance_url = f"{self._server_url}/node/{self._node_id}/performance/?accessCardID={self._access_card}"

    def updateServerUrl(self, server_url):
        if server_url == "":
            return

        self._server_url = f"http://{server_url}:5000"

        self._source_url = f"{self._server_url}/node/{self._node_id}/"
        self._incoming_connections_url = f"{self._server_url}/node/{self._node_id}/connections/incoming/"
        self._all_chart_data_url = f"{self._server_url}/node/{self._node_id}/all_property_chart_data/?showLast=50"
        self._outgoing_connections_url = f"{self._server_url}/node/{self._node_id}/connections/outgoing/"
        self._additional_properties_url = f"{self._server_url}/node/{self._node_id}/additional_properties/"
        self._static_properties_url = f"{self._server_url}/node/{self._node_id}/static_properties/"
        self._modifiers_url = f"{self._server_url}/node/{self._node_id}/modifiers/"
        self._updateUrlsWithAuth(self._server_url, self._access_card)

    def get(self, url: str, callback: Callable[[QNetworkReply], None]) -> None:
        reply = self._network_manager.get(QNetworkRequest(QUrl(url)))
        self._onFinishedCallbacks[reply] = callback

    def fullUpdate(self) -> None:
        """
        Request all data of this node from the server
        :return:
        """
        self.get(self._incoming_connections_url, self._onIncomingConnectionsFinished)
        self.get(self._outgoing_connections_url, self._onOutgoingConnectionsFinished)
        self.get(self._static_properties_url, self._onStaticPropertiesFinished)

        self.partialUpdate()
        self._update_timer.start()

    @Slot()
    def partialUpdate(self) -> None:
        """
        Request all the data that is dynamic
        :return:
        """
        self.get(self._source_url, self._onSourceUrlFinished)
        self.get(self._all_chart_data_url, self._onChartDataFinished)
        self.get(self._modifiers_url, self._onModifiersChanged)
        self.get(self._additional_properties_url, self._onAdditionalPropertiesFinished)

    def _readData(self, reply: QNetworkReply):
        status_code = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        if status_code == 404:
            print("Node was not found!")
            return
        # For some magical reason, it segfaults if i convert the readAll() data directly to bytes.
        # So, yes, the extra .data() is needed.
        data = bytes(reply.readAll().data())
        if not data:
            self._failed_update_timer.start()
            self._update_timer.stop()
            self.server_reachable = False
            self.serverReachableChanged.emit()
            return None
        self.server_reachable = True
        self.serverReachableChanged.emit()
        try:
            return json.loads(data)
        except json.decoder.JSONDecodeError:
            return None

    def _onAdditionalPropertiesFinished(self, reply: QNetworkReply) -> None:
        result = self._readData(reply)
        if not result:
            return

        if self._additional_properties != result:
            self._additional_properties = result
            self._converted_additional_properties = {}
            # Clear the list and convert them in a way that we can use them in a repeater.
            for additional_property in result:
                self._converted_additional_properties[additional_property["key"]] = {
                                                              "value": additional_property["value"],
                                                              "max_value": additional_property["max_value"]}
            #self._converted_additional_properties.reverse()
            self.additionalPropertiesChanged.emit()

    def _onModifiersChanged(self, reply: QNetworkReply):
        result = self._readData(reply)
        if result is None:
            result = []
        if self._modifiers != result:
            self._modifiers = result
            self.modifiersChanged.emit()

    def _onPerformanceChanged(self, reply: QNetworkReply):
        result = self._readData(reply)
        if not result:
            return
        if self._performance != result:
            self._performance = result
            self.performanceChanged.emit()

    @Slot(float)
    def setPerformance(self, performance):
        data = "{\"performance\": %s}" % performance
        self._target_performance = performance
        self.targetPerformanceChanged.emit()
        reply = self._network_manager.put(QNetworkRequest(QUrl(self._performance_url)), data.encode())
        self._onFinishedCallbacks[reply] = self._onPerformanceChanged

    @Slot(str)
    def addModifier(self, modifier: str):
        data = "{\"modifier_name\": \"%s\"}" % modifier
        request = QNetworkRequest(QUrl(self._modifiers_url))
        request.setHeader(QNetworkRequest.ContentTypeHeader, "application/json")

        reply = self._network_manager.post(request, data.encode())

        self._onFinishedCallbacks[reply] = self._onModifiersChanged

    @Property(float, notify=performanceChanged)
    def performance(self):
        return self._performance

    @Property(float, notify=targetPerformanceChanged)
    def targetPerformance(self):
        return self._target_performance

    @Property("QVariantList", notify=resourcesRequiredChanged)
    def resourcesRequired(self):
        return self._resources_required

    @Property("QVariantList", notify=resourcesProducedChanged)
    def resourcesProduced(self):
        return self._resources_produced

    @Property("QVariantList", notify=resourcesProvidedChanged)
    def resourcesProvided(self):
        return self._resources_provided

    @Property("QVariantList", notify=resourcesReceivedChanged)
    def resourcesReceived(self):
        return self._resources_received

    @Property("QVariantList", notify=optionalResourcesRequiredChanged)
    def optionalResourcesRequired(self):
        return self._optional_resources_required

    @Property("QVariantList", notify=modifiersChanged)
    def modifiers(self):
        return self._modifiers

    @Property(float, notify=minPerformanceChanged)
    def min_performance(self):
        return self._min_performance

    @Property(float, notify=maxPerformanceChanged)
    def max_performance(self):
        return self._max_performance

    @Property(float, notify=healthChanged)
    def health(self):
        return self._health

    def _onStaticPropertiesFinished(self, reply: QNetworkReply) -> None:
        result = self._readData(reply)
        if not result:
            return
        if self._static_properties != result:
            self._static_properties = result
            self.staticPropertiesChanged.emit()

    def _onIncomingConnectionsFinished(self, reply: QNetworkReply):
        result = self._readData(reply)
        if not result:
            return
        self._incoming_connections = result
        self.incomingConnectionsChanged.emit()

    def _onOutgoingConnectionsFinished(self, reply: QNetworkReply):
        result = self._readData(reply)
        if not result:
            return
        self._outgoing_connections = result
        self.outgoingConnectionsChanged.emit()

    @Property("QVariantList", notify=incomingConnectionsChanged)
    def incomingConnections(self):
        return self._incoming_connections

    @Property(str, notify=staticPropertiesChanged)
    def description(self):
        return self._static_properties.get("description", "")

    @Property(str, notify=staticPropertiesChanged)
    def node_type(self):
        return self._static_properties.get("node_type", "")

    @Property(str, notify=staticPropertiesChanged)
    def custom_description(self):
        return self._static_properties.get("custom_description", "")

    @Property("QStringList", notify=staticPropertiesChanged)
    def supported_modifiers(self):
        return self._static_properties.get("supported_modifiers", "")

    @Property(bool, notify=staticPropertiesChanged)
    def hasSettablePerformance(self):
        return self._static_properties.get("has_settable_performance", False)

    @Property(str, notify=staticPropertiesChanged)
    def label(self):
        return self._static_properties.get("label", self._node_id)

    @Property(float, notify=staticPropertiesChanged)
    def surface_area(self):
        return self._static_properties.get("surface_area", 0)

    @Property(float, notify=isTemperatureDependantChanged)
    def isTemperatureDependant(self):
        return self._is_temperature_dependant

    @Property(float, notify=activeChanged)
    def active(self):
        return self._active

    @Property(float, notify=optimalTemperatureChanged)
    def optimalTemperature(self):
        return self._optimal_temperature

    @Property(float, notify=maxSafeTemperatureChanged)
    def max_safe_temperature(self):
        return self._max_safe_temperature

    @Property(float, notify=heatConvectionChanged)
    def heat_convection(self):
        return self._heat_convection

    @Property(float, notify=heatEmissivityChanged)
    def heat_emissivity(self):
        return self._heat_emissivity

    @Property("QVariantList", notify=outgoingConnectionsChanged)
    def outgoingConnections(self):
        return self._outgoing_connections

    def _onSourceUrlFinished(self, reply: QNetworkReply):
        data = self._readData(reply)
        if not data:
            return
        self._updateProperty("temperature", data["temperature"] - 273.15 )
        self._updateProperty("enabled", bool(data["enabled"]))
        self._updateProperty("active", bool(data["active"]))
        self._updateProperty("performance", data["performance"])
        self._updateProperty("min_performance", data["min_performance"])
        self._updateProperty("max_performance", data["max_performance"])
        self._updateProperty("max_safe_temperature", data["max_safe_temperature"] - 273.15)
        self._updateProperty("heat_convection", data["heat_convection"])
        self._updateProperty("heat_emissivity", data["heat_emissivity"])
        self._updateProperty("is_temperature_dependant", data["is_temperature_dependant"])
        self._updateProperty("optimal_temperature", data["optimal_temperature"] - 273.15)
        self._updateProperty("target_performance", data["target_performance"])
        self._updateProperty("health", data["health"])
        self._updateProperty("effectiveness_factor", data["effectiveness_factor"])

        # We need to update the resources a bit different to prevent recreation of QML items.
        # As such we use tiny QObjects with their own getters and setters.
        # If an object is already in the list with the right type, don't recreate it (just update it's value)
        self.updateResourceList("optional_resources_required", data["optional_resources_required"])
        self.updateResourceList("resources_received", data["resources_received"])
        self.updateResourceList("resources_required", data["resources_required"])
        self.updateResourceList("resources_produced", data["resources_produced"])
        self.updateResourceList("resources_provided", data["resources_provided"])

    def updateResourceList(self, property_name, data):
        list_to_check = getattr(self, "_" + property_name)
        list_updated = False

        for item in data:
            item_found = False
            for resource in list_to_check:
                if item["resource_type"] == resource.type:
                    item_found = True
                    resource.value = item["value"]
                    break

            if not item_found:
                list_updated = True
                list_to_check.append(NodeResource(item["resource_type"], item["value"]))

        if list_updated:
            signal_name = "".join(x.capitalize() for x in property_name.split("_"))
            signal_name = signal_name[0].lower() + signal_name[1:] + "Changed"
            getattr(self, signal_name).emit()

    def _updateProperty(self, property_name, property_value):
        if getattr(self, "_" + property_name) != property_value:
            setattr(self, "_" + property_name, property_value)
            signal_name = "".join(x.capitalize() for x in property_name.split("_"))
            signal_name = signal_name[0].lower() + signal_name[1:] + "Changed"
            getattr(self, signal_name).emit()

    def _onPutUpdateFinished(self, reply: QNetworkReply):
        pass

    def _onChartDataFinished(self, reply: QNetworkReply):
        data = self._readData(reply)
        if not data:
            return

        # Offset is given in the reply, but it's not a list of data. Remove it here.
        if "offset" in data:
            del data["offset"]

        all_keys = set(data.keys())

        keys_changed = False
        data_changed = False
        if set(self._all_chart_data.keys()) != all_keys:
            keys_changed = True
        if self._all_chart_data != data:
            data_changed = True
            self._all_chart_data = data

        if data_changed:
            self.historyDataChanged.emit()
        if keys_changed:
            self.historyPropertiesChanged.emit()

    def _onNetworkFinished(self, reply: QNetworkReply):
        if reply in self._onFinishedCallbacks:
            self._onFinishedCallbacks[reply](reply)
            del self._onFinishedCallbacks[reply]
        else:
            print("GOT A RESPONSE WITH NO CALLBACK!", reply.readAll())

    @Property(str, constant=True)
    def id(self):
        return self._node_id

    @Property(bool, notify = enabledChanged)
    def enabled(self):
        return self._enabled

    @Property(float, notify=amountStoredChanged)
    def amount_stored(self):
        return self._amount_stored

    @Property(float, notify=effectivenessFactorChanged)
    def effectiveness_factor(self):
        return self._effectiveness_factor

    @Property(float, notify=temperatureChanged)
    def temperature(self):
        return self._temperature

    @Property("QVariantList", notify=historyPropertiesChanged)
    def allHistoryProperties(self):
        return list(self._all_chart_data.keys())

    @Property("QVariantMap", notify=historyDataChanged)
    def historyData(self):
        return self._all_chart_data

    @Property("QVariantMap", notify=additionalPropertiesChanged)
    def additionalProperties(self):
        return self._converted_additional_properties

    @Slot()
    def toggleEnabled(self):
        url = self._source_url + "enabled/"
        reply = self._network_manager.put(QNetworkRequest(url), QByteArray())
        self._onFinishedCallbacks[reply] = self._onPutUpdateFinished
        # Already trigger an update, so the interface feels snappy
        self._enabled = not self._enabled
        self.enabledChanged.emit()
