from PySide2.QtCore import QPropertyAnimation
from PySide2.QtGui import QColor
from PySide2.QtWidgets import QGraphicsView

from AnimatedLine import AnimatedLine
from NodeScene import NodeScene
from Connection import Connection


class NodeViewer(QGraphicsView):
    def __init__(self, parent=None):
        super(NodeViewer, self).__init__(parent)

        self.setScene(NodeScene(self))
        self._animated_line = AnimatedLine()
        self.scene().addItem(self._animated_line.line)

