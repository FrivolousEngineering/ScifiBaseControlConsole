from PySide2.QtCore import QPointF, QPropertyAnimation, QObject, Property
from PySide2.QtGui import QColor, QPen, QPainterPath
from PySide2.QtWidgets import QGraphicsPathItem


class Connection(QGraphicsPathItem, QObject):
    def __init__(self):
        super(Connection, self).__init__()
        self._color = QColor(255, 0, 0)

        self.updatePath()

    def setColor(self, color):
        self._color = color

    color = Property(QColor, fset=setColor)



    def resetPath(self):
        path = QPainterPath(QPointF(0.0, 0.0))
        self.setPath(path)

    def paint(self, painter, option, widget):

        pen = QPen(self._color, 2)

        painter.save()
        painter.setPen(pen)
        painter.setRenderHint(painter.Antialiasing, True)
        painter.drawPath(self.path())
        painter.restore()

    def updatePath(self):
        path = QPainterPath()

        path.moveTo(10, 20)
        path.lineTo(200, 200)

        self.setPath(path)
