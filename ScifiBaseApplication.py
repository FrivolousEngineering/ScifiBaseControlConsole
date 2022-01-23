from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtQuick import QQuickView
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import pyqtSignal as Signal

from ApplicationController import ApplicationController
from RadialBar import RadialBar

import argparse


class ScifiBaseApplication(QApplication):
    def __init__(self, title, args, parser, graph_data):
        QApplication.__init__(self, args)
        qmlRegisterType(RadialBar, "SDK", 1, 0, "RadialBar")
        self._qquickview = _QQuickView()
        self._qquickview.setTitle(title)

        self._graph_data = graph_data

        parsed_args = parser.parse_args()
        self._rfid_card = parsed_args.rfid_card  # Debug only so the app can work without a RFID card reader
        self._engine = self._qquickview.engine()

    def showAndExec(self, qml_url):
        application_controller = ApplicationController(rfid_card = self._rfid_card)
        self._qquickview.rootContext().setContextProperty("backend", application_controller)
        self._qquickview.rootContext().setContextProperty("graph_data", self._graph_data)
        self._qquickview.setSource(qml_url)
        self._qquickview.mouseMoved.connect(application_controller.tickleTimeout)
        self._qquickview.setResizeMode(self._qquickview.SizeRootObjectToView)
        self._qquickview.showFullScreen()

        return self.exec_()


class _QQuickView(QQuickView):
    mouseMoved = Signal()

    def mouseMoveEvent(self, event) -> None:
        super().mouseMoveEvent(event)
        self.mouseMoved.emit()