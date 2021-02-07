from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtQuick import QQuickView
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import pyqtSignal as Signal

from ApplicationController import ApplicationController
from RadialBar import RadialBar


class ScifiBaseApplication(QApplication):
    _application_name = "UNDEFINED"
    _qquickview = None
    _engine = None
    _settings = None

    def __init__(self, title, args):
        QApplication.__init__(self, args)
        qmlRegisterType(RadialBar, "SDK", 1, 0, "RadialBar")
        self._qquickview = _QQuickView()
        self._qquickview.setTitle(title)

        self._engine = self._qquickview.engine()

    def showAndExec(self, qml_url):
        beep = ApplicationController()
        self._qquickview.rootContext().setContextProperty("backend", beep)
        self._qquickview.setSource(qml_url)
        self._qquickview.mouseMoved.connect(beep.tickleTimeout)
        self._qquickview.show()
        return self.exec_()


class _QQuickView(QQuickView):
    mouseMoved = Signal()

    def mouseMoveEvent(self, event) -> None:
        super().mouseMoveEvent(event)
        self.mouseMoved.emit()