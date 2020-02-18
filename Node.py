from PySide2.QtNetwork import QNetworkAccessManager, QNetworkReply, QNetworkRequest
from PySide2.QtCore import QObject, Signal, QByteArray, Slot, Property

import json

class Node(QObject):
    def __init__(self, node_id: str, parent=None):
        QObject.__init__(self, parent)
        self._temperature = 293
        self._node_id = node_id

        self._source_url = "http://localhost:5000/%s/" % self._node_id
        self._temperature_history_url = "http://localhost:5000/%s/temperature/history/" % self._node_id
        self._all_chart_data_url = "http://localhost:5000/%s/all_property_chart_data" % self._node_id
        self._incoming_connections_url = "http://localhost:5000/%s/connections/incoming" % self._node_id
        self._outgoing_connections_url = "http://localhost:5000/%s/connections/outgoing" % self._node_id
        
        self._description_url = "http://localhost:5000/%s/description" % self._node_id

        self._static_properties_url = "http://localhost:5000/%s/static_properties" % self._node_id
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
        self.update()

    temperatureChanged = Signal()
    temperatureHistoryChanged = Signal()
    historyPropertiesChanged = Signal()
    historyDataChanged = Signal()
    enabledChanged = Signal()
    incomingConnectionsChanged = Signal()
    outgoingConnectionsChanged = Signal()

    staticPropertiesChanged = Signal()

    @Slot()
    def update(self):
        reply = self._network_manager.get(QNetworkRequest(self._source_url))
        self._onFinishedCallbacks[reply] = self._onSourceUrlFinished

        reply = self._network_manager.get(QNetworkRequest(self._all_chart_data_url))
        self._onFinishedCallbacks[reply] = self._onChartDataFinished

        reply = self._network_manager.get(QNetworkRequest(self._incoming_connections_url))
        self._onFinishedCallbacks[reply] = self._onIncomingConnectionsFinished

        reply = self._network_manager.get(QNetworkRequest(self._outgoing_connections_url))
        self._onFinishedCallbacks[reply] = self._onOutgoingConnectionsFinished

        reply = self._network_manager.get(QNetworkRequest(self._static_properties_url))
        self._onFinishedCallbacks[reply] = self._onStaticPropertiesFinished

    def _onStaticPropertiesFinished(self, reply: QNetworkReply):
        # Todo: Handle errors.
        result = json.loads(bytes(reply.readAll().data()))
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

    @Slot()
    def toggleEnabled(self):
        url = self._source_url + "enabled/"
        reply = self._network_manager.put(QNetworkRequest(url), QByteArray())
        self._onFinishedCallbacks[reply] = self._onPutUpdateFinished
        # Already trigger an update, so the interface feels snappy
        self._enabled = not self._enabled
        self.enabledChanged.emit()
