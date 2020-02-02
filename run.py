from PySide2.QtNetwork import QNetworkAccessManager, QNetworkReply, QNetworkRequest
from PySide2.QtWidgets import QApplication
from PySide2.QtQuick import QQuickView
from PySide2.QtCore import QUrl, QObject, Slot, Property, Signal, QByteArray
import json

class NodeData(QObject):
    def __init__(self, node_id: str, parent=None):
        QObject.__init__(self, parent)
        self._temperature = 293
        self._node_id = node_id

        self._source_url = "http://localhost:5000/%s/" % self._node_id
        self._temperature_history_url = "http://localhost:5000/%s/temperature/history/" % self._node_id

        self._network_manager = QNetworkAccessManager()
        self._network_manager.finished.connect(self._onNetworkFinished)
        self.update()
        self._temperature_history = []
        self._data = None

    temperatureChanged = Signal()
    temperatureHistoryChanged = Signal()

    def update(self):
        self._network_manager.get(QNetworkRequest(self._source_url))
        self._network_manager.get(QNetworkRequest(self._temperature_history_url))

    def _onNetworkFinished(self, reply: QNetworkReply):
        http_status_code = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        if http_status_code != 200:
            print("http request failed :(", reply.readAll())
            return
        url = reply.url().toString()
        # For some magical reason, it segfaults if i convert the readAll() data directly to bytes.
        # So, yes, the extra .data() is needed.
        self._data = json.loads(bytes(reply.readAll().data()))

        if url == self._source_url:
            self._handleBaseUpdate(self._data)
        else:
            self._handleTemperatureHistoryUpdate(self._data)

    def _handleBaseUpdate(self, data):

        self._updateTemperature(data["temperature"])

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

    @Property(float, notify=temperatureChanged)
    def temperature(self):
        return self._temperature

    @Property("QVariantList", notify=temperatureHistoryChanged)
    def temperatureHistory(self):
        return self._temperature_history


class TestObject(QObject):

    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self._data = [ NodeData("generator_1")]

    @Property("QVariantList", constant=True)
    def nodeData(self):
        return self._data

if __name__ == '__main__':
    app = QApplication([])
    view = QQuickView()
    url = QUrl("view.qml")
    beep = TestObject()
    view.rootContext().setContextProperty("backend", beep)
    view.setSource(url)



    view.show()
    app.exec_()