from typing import Callable, Dict

from PySide2.QtNetwork import QNetworkAccessManager, QNetworkReply, QNetworkRequest
from PySide2.QtCore import QObject, Signal, QByteArray, Slot, Property, QTimer

import json


class Node(QObject):
    def __init__(self, node_id: str, parent=None):
        QObject.__init__(self, parent)
        self._temperature = 293
        self._node_id = node_id

        self._source_url = "http://localhost:5000/%s/" % self._node_id
        self._temperature_history_url = "http://localhost:5000/%s/temperature/history/?showLast=50" % self._node_id
        self._all_chart_data_url = "http://localhost:5000/%s/all_property_chart_data?showLast=50" % self._node_id
        self._incoming_connections_url = "http://localhost:5000/%s/connections/incoming" % self._node_id
        self._outgoing_connections_url = "http://localhost:5000/%s/connections/outgoing" % self._node_id
        self._performance_url = "http://localhost:5000/%s/performance/" % self._node_id
        self._description_url = "http://localhost:5000/%s/description" % self._node_id

        self._additional_properties_url = "http://localhost:5000/%s/additional_properties" % self._node_id

        self._static_properties_url = "http://localhost:5000/%s/static_properties" % self._node_id
        self._modifiers_url = "http://localhost:5000/%s/modifiers" % self._node_id
        self._all_chart_data = {}

        self._network_manager = QNetworkAccessManager()
        self._network_manager.finished.connect(self._onNetworkFinished)

        self._temperature_history = []
        self._data = None
        self._enabled = True
        self._incoming_connections = []
        self._outgoing_connections = []
        self._onFinishedCallbacks = {}  # type: Dict[QNetworkReply, Callable[[QNetworkReply], None]]
        self._description = ""
        self._static_properties = {}
        self._performance = 1
        self._min_performance = 0.5
        self._max_performance = 1
        self._max_safe_temperature = 500
        self._heat_convection = 1.0
        self._heat_emissivity = 1.0
        self._modifiers = []

        self._update_timer = QTimer()
        self._update_timer.setInterval(2000)
        self._update_timer.setSingleShot(False)
        self._update_timer.timeout.connect(self.partialUpdate)
        #self._update_timer.start()

        # Timer that is used when the server could not be reached.
        self._failed_update_timer = QTimer()
        self._failed_update_timer.setInterval(10000)
        self._failed_update_timer.setSingleShot(True)
        self._failed_update_timer.timeout.connect(self.fullUpdate)

        self._additional_properties = {}
        self._converted_additional_properties = []
        self.server_reachable = False
        self.fullUpdate()

    temperatureChanged = Signal()
    temperatureHistoryChanged = Signal()
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

    def get(self, url: str, callback: Callable[[QNetworkReply], None]) -> None:
        reply = self._network_manager.get(QNetworkRequest(url))
        self._onFinishedCallbacks[reply] = callback

    def fullUpdate(self) -> None:
        """
        Request all data of this node from the server
        :return:
        """
        self.get(self._incoming_connections_url, self._onIncomingConnectionsFinished)
        self.get(self._outgoing_connections_url, self._onOutgoingConnectionsFinished)
        self.get(self._static_properties_url, self._onStaticPropertiesFinished)

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
        return json.loads(data)

    def _onAdditionalPropertiesFinished(self, reply: QNetworkReply) -> None:
        result = self._readData(reply)
        if not result:
            return

        if self._additional_properties != result:
            self._additional_properties = result
            self._converted_additional_properties = []
            # Clear the list and convert them in a way that we can use them in a repeater.
            for key in result:
                self._converted_additional_properties.append({"key": key,
                                                              "value": result[key]["value"],
                                                              "max_value": result[key]["max_value"]})
            self._converted_additional_properties.reverse()
            self.additionalPropertiesChanged.emit()

    def _onModifiersChanged(self, reply: QNetworkReply):
        result = self._readData(reply)
        if not result:
            return
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
        reply = self._network_manager.put(QNetworkRequest(self._performance_url), data.encode())
        self._performance = performance
        self.performanceChanged.emit()
        self._onFinishedCallbacks[reply] = self._onPerformanceChanged

    @Property(float, notify=performanceChanged)
    def performance(self):
        return self._performance

    @Property("QVariantList", notify=modifiersChanged)
    def modifiers(self):
        return self._modifiers

    @Property(float, notify=minPerformanceChanged)
    def min_performance(self):
        return self._min_performance

    @Property(float, notify=maxPerformanceChanged)
    def max_performance(self):
        return self._max_performance

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

    @Property(float, notify=staticPropertiesChanged)
    def surface_area(self):
        return self._static_properties.get("surface_area", 0)

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
        self._updateProperty("temperature", data["temperature"])
        self._updateProperty("enabled", bool(data["enabled"]))
        self._updateProperty("performance", data["performance"])
        self._updateProperty("min_performance", data["min_performance"])
        self._updateProperty("max_performance", data["max_performance"])
        self._updateProperty("max_safe_temperature", data["max_safe_temperature"])
        self._updateProperty("heat_convection", data["heat_convection"])
        self._updateProperty("heat_emissivity", data["heat_emissivity"])

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

    @Property(float, notify=temperatureChanged)
    def temperature(self):
        return self._temperature

    @Property("QVariantList", notify=temperatureHistoryChanged)
    def temperatureHistory(self):
        return self._temperature_history

    @Property("QVariantList", notify=historyPropertiesChanged)
    def allHistoryProperties(self):
        return list(self._all_chart_data.keys())

    @Property("QVariantMap", notify=historyDataChanged)
    def historyData(self):
        return self._all_chart_data

    @Property("QVariantList", notify=additionalPropertiesChanged)
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
