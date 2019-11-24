from PySide2.QtGui import QColor, QPainter
from PySide2.QtWidgets import QGraphicsScene


class NodeScene(QGraphicsScene):

    def __init__(self, parent=None):
        super(NodeScene, self).__init__(parent)
        self._background_color = QColor(35, 35, 35)

    def drawBackground(self, painter, rect):
        painter.save()
        painter.setRenderHint(QPainter.Antialiasing, False)
        painter.setBrush(self._background_color)

        painter.drawRect(rect)
        painter.restore()

    def viewer(self):
        return self.views()[0] if self.views() else None
