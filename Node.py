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
        self._onFinishedCallbacks = {}
        self._description = ""
        self._static_properties = {}
        self._performance = 1

        self._modifiers = []

        self._update_timer = QTimer()
        self._update_timer.setInterval(2000)
        self._update_timer.setSingleShot(False)
        self._update_timer.timeout.connect(self.partialUpdate)
        self._update_timer.start()

        self._additional_properties = {}
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

    def fullUpdate(self):
        """
        Request all data of this node from the server
        :return:
        """
        self.partialUpdate()

        reply = self._network_manager.get(QNetworkRequest(self._incoming_connections_url))
        self._onFinishedCallbacks[reply] = self._onIncomingConnectionsFinished

        reply = self._network_manager.get(QNetworkRequest(self._outgoing_connections_url))
        self._onFinishedCallbacks[reply] = self._onOutgoingConnectionsFinished

        reply = self._network_manager.get(QNetworkRequest(self._static_properties_url))
        self._onFinishedCallbacks[reply] = self._onStaticPropertiesFinished

        reply = self._network_manager.get(QNetworkRequest(self._static_properties_url))
        self._onFinishedCallbacks[reply] = self._onStaticPropertiesFinished

    @Slot()
    def partialUpdate(self):
        """
        Request all the data that is dynamic
        :return:
        """
        reply = self._network_manager.get(QNetworkRequest(self._source_url))
        self._onFinishedCallbacks[reply] = self._onSourceUrlFinished

        reply = self._network_manager.get(QNetworkRequest(self._all_chart_data_url))
        self._onFinishedCallbacks[reply] = self._onChartDataFinished

        reply = self._network_manager.get(QNetworkRequest(self._performance_url))
        self._onFinishedCallbacks[reply] = self._onPerformanceChanged

        reply = self._network_manager.get(QNetworkRequest(self._modifiers_url))
        self._onFinishedCallbacks[reply] = self._onModifiersChanged

        reply = self._network_manager.get(QNetworkRequest(self._additional_properties_url))
        self._onFinishedCallbacks[reply] = self._onAdditionalPropertiesFinished

    def _onAdditionalPropertiesFinished(self, reply: QNetworkReply):
        result = json.loads(bytes(reply.readAll().data()))
        if self._additional_properties != result:
            self._additional_properties = result
            self.additionalPropertiesChanged.emit()

    def _onModifiersChanged(self, reply: QNetworkReply):
        result = json.loads(bytes(reply.readAll().data()))
        if self._modifiers != result:
            self._modifiers = result
            self.modifiersChanged.emit()

    def _onPerformanceChanged(self, reply: QNetworkReply):
        result = json.loads(bytes(reply.readAll().data()))
        self._performance = result
        self.performanceChanged.emit()

    @Slot(float)
    def setPerformance(self, performance):
        data = "{\"performance\": %s}" % performance
        reply = self._network_manager.put(QNetworkRequest(self._performance_url), data.encode())
        self._performance = performance
        self.performanceChanged.emit()
        #reply = self._network_manager.get(QNetworkRequest(self._performance_url))
        self._onFinishedCallbacks[reply] = self._onPerformanceChanged

    @Property(float, notify=performanceChanged)
    def performance(self):
        return self._performance

    @Property("QVariantList", notify=modifiersChanged)
    def modifiers(self):
        return self._modifiers

    @Property(float, notify=staticPropertiesChanged)
    def min_performance(self):
        return self._static_properties.get("min_performance", 1)

    @Property(float, notify=staticPropertiesChanged)
    def max_performance(self):
        return self._static_properties.get("max_performance", 1)

    def _onStaticPropertiesFinished(self, reply: QNetworkReply):
        # Todo: Handle errors.
        result = json.loads(bytes(reply.readAll().data()))
        if self._static_properties != result:
            self._static_properties = result
            self.staticPropertiesChanged.emit()

    def _onIncomingConnectionsFinished(self, reply: QNetworkReply):
        # Todo: Handle errors.
        self._incoming_connections = json.loads(bytes(reply.readAll().data()))
        self.incomingConnectionsChanged.emit()

    def _onOutgoingConnectionsFinished(self, reply: QNetworkReply):
        # Todo: Handle errors.
        self._outgoing_connections =json.loads(bytes(reply.readAll().data()))
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

    @Property(float, notify=staticPropertiesChanged)
    def max_safe_temperature(self):
        return self._static_properties.get("max_safe_temperature", 0)

    @Property(float, notify=staticPropertiesChanged)
    def heat_convection(self):
        return self._static_properties.get("heat_convection", 0)

    @Property(float, notify=staticPropertiesChanged)
    def heat_emissivity(self):
        return self._static_properties.get("heat_emissivity", 0)

    @Property("QVariantList", notify=outgoingConnectionsChanged)
    def outgoingConnections(self):
        return self._outgoing_connections

    def _onSourceUrlFinished(self, reply: QNetworkReply):
        # For some magical reason, it segfaults if i convert the readAll() data directly to bytes.
        # So, yes, the extra .data() is needed.
        data = json.loads(bytes(reply.readAll().data()))
        self._updateTemperature(data["temperature"])
        self._updateEnabled(data["enabled"])

    def _onPutUpdateFinished(self, reply: QNetworkReply):
        pass

    def _onChartDataFinished(self, reply: QNetworkReply):
        # For some magical reason, it segfaults if i convert the readAll() data directly to bytes.
        # So, yes, the extra .data() is needed.
        data = json.loads(bytes(reply.readAll().data()))
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

    def _updateEnabled(self, enabled):
        if self._enabled != bool(enabled):
            self._enabled = bool(enabled)
            self.enabledChanged.emit()

    def _handleTemperatureHistoryUpdate(self, data):
        if self._temperature_history != data:
            self._temperature_history = data
            self.temperatureHistoryChanged.emit()

    def _updateTemperature(self, temperature):
        if self._temperature != temperature:
            self._temperature = temperature
            self.temperatureChanged.emit()

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

    @Property("QVariantMap", notify=additionalPropertiesChanged)
    def additionalProperties(self):
        return self._additional_properties

    @Slot()
    def toggleEnabled(self):
        url = self._source_url + "enabled/"
        reply = self._network_manager.put(QNetworkRequest(url), QByteArray())
        self._onFinishedCallbacks[reply] = self._onPutUpdateFinished
        # Already trigger an update, so the interface feels snappy
        self._enabled = not self._enabled
        self.enabledChanged.emit()
