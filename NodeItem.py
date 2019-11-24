from PySide2 import QtCore
from PySide2.QtCore import QRectF
from PySide2.QtGui import QPen, QColor, QPainterPath
from PySide2.QtWidgets import QGraphicsItem


class NodeItem(QGraphicsItem):

    def __init__(self, parent=None):
        super(NodeItem, self).__init__(parent)
        self._size = 250

        self._background_color = QColor(13, 18, 23, 50)
        self._header_color = QColor(13, 18, 23, 255)
        self._text_color = QColor(255, 255, 255, 180)
        self._border_color = QColor(46, 57, 66, 255)
        self._name = "OMGZOMG"

    def getSize(self):
        return self._size

    def setSize(self, size):
        self._size = size

    def setName(self, name):
        self._name = name

    def boundingRect(self):
        return QRectF(0, 0, self._size, self._size)

    def paint(self, painter, option, widget):
        painter.save()

        rect = self.boundingRect()

        painter.setBrush(self._background_color)
        painter.setPen(QPen())
        painter.drawRect(rect)

        top_rect = QRectF(0.0, 0.0, rect.width(), 20.0)

        painter.setBrush(self._header_color)
        painter.setPen(QPen())
        painter.drawRect(top_rect)

        txt_rect = QRectF(top_rect.x(), top_rect.y() + 1.2, rect.width(), top_rect.height())
        painter.setPen(self._text_color)
        painter.drawText(txt_rect, QtCore.Qt.AlignCenter, self._name)

        path = QPainterPath()
        path.addRect(rect)
        painter.setBrush(QtCore.Qt.NoBrush)
        painter.setPen(QPen(self._border_color, 1))
        painter.drawPath(path)

        painter.restore()
