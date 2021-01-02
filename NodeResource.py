from PyQt5.QtCore import QObject

from PyQt5.QtCore import pyqtSignal as Signal
from PyQt5.QtCore import pyqtProperty as Property


class NodeResource(QObject):
    def __init__(self, type: str, value: float, parent=None):
        QObject.__init__(self, parent)
        self._type = type
        self._value = value

    typeChanged = Signal()
    valueChanged = Signal()

    @Property(str, notify=typeChanged)
    def type(self):
        return self._type

    @Property(float, notify=valueChanged)
    def value(self):
        return self._value

    @value.setter
    def value(self, value):
        if self._value != value:
            self._value = value
            self.valueChanged.emit()