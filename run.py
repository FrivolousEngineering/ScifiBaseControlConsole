from PyQt5.QtNetwork import QNetworkAccessManager, QNetworkReply, QNetworkRequest
from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtCore import QUrl, QObject, QRect, QTimer, QThread, QCoreApplication
from PyQt5.QtCore import pyqtSignal as Signal
from PyQt5.QtCore import pyqtProperty as Property
from PyQt5.QtCore import pyqtSlot as Slot

import threading
import serial
import time

from PyQt5.QtQml import QQmlApplicationEngine,QQmlEngine, QQmlComponent
import json

from Node import Node
from RadialBar import RadialBar

import sys

from ScifiBaseApplication import ScifiBaseApplication




if __name__ == '__main__':
    app = ScifiBaseApplication('Test',sys.argv)
    app.showAndExec(QUrl("resources/qml/view.qml"))
