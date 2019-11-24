from PySide2.QtCore import QObject, Property, QPropertyAnimation, QPointF
from PySide2.QtGui import QColor, QPen, QPainterPath
from PySide2.QtWidgets import  QGraphicsPathItem


class Connection(QObject):
    def __init__(self, origin, target):
        super(Connection, self).__init__()
        self._color = QColor(255, 0, 0, 127)

        self._background_color = QColor(70, 70, 70)

        self.origin = origin
        self.target = target
        self._connection_width = 12
        self._space = 4

        self._dash_shift = 0
        self._dashes = [max(0, self._dash_shift - self._space), min(self._dash_shift, 4), self._space, self._space, min(2 * self._space - self._dash_shift, 4), max(self._space - self._dash_shift, 0)]
        self._background_line = QGraphicsPathItem()
        background_pen = QPen()
        background_pen.setWidth(self._connection_width)
        background_pen.setColor(self._background_color)
        self._background_line.setPen(background_pen)
        self.dashed_line = QGraphicsPathItem()

        self.anim = QPropertyAnimation(self, b'dashShift')
        self.anim.setDuration(1000)
        self.anim.setStartValue(0.)
        self.anim.setEndValue(2 * self._space)
        self.anim.setLoopCount(-1)

        self.anim.start()
        self._updateDrawPath()

    def getItemsToDraw(self):
        return [self._background_line, self.dashed_line]

    def _updateDrawPath(self):
        path = QPainterPath()

        origin_pos = self.origin.getPosition()
        origin_pos.setX(origin_pos.x() + self.origin.getSize())
        origin_pos.setY(origin_pos.y() + self.origin.getSize() / 2)

        target_pos = self.target.getPosition()
        target_pos.setY(target_pos.y() + self.target.getSize() / 2)
        path.moveTo(origin_pos)

        difference = target_pos.x() - origin_pos.x()

        ctr_point1 = QPointF(origin_pos.x() + difference / 2, origin_pos.y())
        ctr_point2 = QPointF(target_pos.x() - difference / 2, target_pos.y())

        path.lineTo(ctr_point1)
        path.lineTo(ctr_point2)
        path.lineTo(target_pos)

        self.dashed_line.setPath(path)
        self._background_line.setPath(path)

    def _recreateDashedPen(self):
        pen = QPen()
        pen.setColor(self._color)
        pen.setDashPattern(self._dashes)
        pen.setWidth(5)
        return pen

    def setColor(self, color):
        self._color = color
        self.dashed_line.setPen(self._recreateDashedPen())

    def setDashShift(self, dash_shift):
        self._dash_shift = dash_shift

        self._dashes = [max(0, self._dash_shift - self._space), min(self._dash_shift, 4), self._space, self._space, min(2 * self._space - self._dash_shift, 4), max(self._space - self._dash_shift, 0)]

        self.dashed_line.setPen(self._recreateDashedPen())

    dashShift = Property(float, fset= setDashShift)
    color = Property(QColor, fset= setColor)