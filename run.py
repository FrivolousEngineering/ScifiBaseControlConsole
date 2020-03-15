from PySide2.QtQml import qmlRegisterType
from PySide2.QtWidgets import QApplication
from PySide2.QtQuick import QQuickView
from PySide2.QtCore import QUrl, QObject, Property

from Node import Node
from RadialBar import RadialBar


class TestObject(QObject):
    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self._data = [ Node("generator_1"),  Node("fluid_cooler_2"), Node("battery_2"), Node("generator_2"), Node("fluid_cooler_1"),  Node("battery_1"), Node("water_storage_1"), Node("water_storage_2"), Node("rain_collector"), Node("rain_collector_2"), Node("hydroponics_2"), Node("oxygen_storage")]

    @Property("QVariantList", constant=True)
    def nodeData(self):
        return self._data


if __name__ == '__main__':
    app = QApplication([])
    view = QQuickView()
    url = QUrl("view.qml")
    beep = TestObject()
    qmlRegisterType(RadialBar, "SDK", 1, 0, "RadialBar")
    view.rootContext().setContextProperty("backend", beep)
    view.setSource(url)

    view.show()
    app.exec_()