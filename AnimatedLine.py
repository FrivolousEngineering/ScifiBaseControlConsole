from PySide2.QtCore import QObject, Property, QPropertyAnimation, QPointF
from PySide2.QtGui import QColor, QPen, QPainterPath
from PySide2.QtWidgets import QGraphicsLineItem, QGraphicsPathItem


class AnimatedLine(QObject):
    def __init__(self):
        super(AnimatedLine, self).__init__()
        self._color = QColor(255, 0, 0)

        self._space = 4

        self._dash_shift = 0
        self._dashes = [max(0, self._dash_shift - self._space), min(self._dash_shift, 4), self._space, self._space, min(2 * self._space - self._dash_shift, 4), max(self._space - self._dash_shift, 0)]

        self.line = QGraphicsPathItem()

        path = QPainterPath()
        ctr_point1 = QPointF(75, 0)
        ctr_point2 = QPointF(125, 200)
        path.cubicTo(ctr_point1, ctr_point2, QPointF(200, 200))
        self.line.setPath(path)

        self.anim = QPropertyAnimation(self, b'dashShift')
        self.anim.setDuration(1000)
        self.anim.setStartValue(0.)
        self.anim.setEndValue(2 * self._space)
        self.anim.setLoopCount(-1)

        self.anim.start()

    def _recreatePen(self):
        pen = QPen()
        pen.setColor(self._color)
        pen.setDashPattern(self._dashes)
        pen.setWidth(5)
        return pen

    def setColor(self, color):
        self._color = color
        self.line.setPen(self._recreatePen())

    def setDashShift(self, dash_shift):
        self._dash_shift = dash_shift

        self._dashes = [max(0, self._dash_shift - self._space), min(self._dash_shift, 4), self._space, self._space, min(2 * self._space - self._dash_shift, 4), max(self._space - self._dash_shift, 0)]

        self.line.setPen(self._recreatePen())

    dashShift = Property(float, fset= setDashShift)
    color = Property(QColor, fset= setColor)