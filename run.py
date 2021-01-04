from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtCore import QUrl, QObject, QRect
from PyQt5.QtCore import pyqtSignal as Signal
from PyQt5.QtCore import pyqtProperty as Property

from PyQt5.QtQml import QQmlApplicationEngine,QQmlEngine, QQmlComponent

from Node import Node
from RadialBar import RadialBar

import sys
class TestObject(QObject):
    serverReachableChanged = Signal()

    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self._data = [ Node("generator_1"),  Node("fluid_cooler_2"), Node("battery_2"), Node("generator_2"), Node("fluid_cooler_1"),  Node("battery_1"), Node("water_storage_1"), Node("water_storage_2"), Node("rain_collector_2"), Node("hydroponics_2"), Node("oxygen_storage"), Node("water_purifier")]
        self._server_reachable = False

        for node in self._data:
            node.serverReachableChanged.connect(self.serverReachableChanged)

    @Property("QVariantList", constant=True)
    def nodeData(self):
        return self._data

    @Property(bool, notify = serverReachableChanged)
    def serverReachable(self):
        return all([node.server_reachable for node in self._data])





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
        self._qquickview.setSource(qml_url)
        beep = TestObject()
        self._qquickview.rootContext().setContextProperty("backend", beep)
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