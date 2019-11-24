from PySide2.QtCore import QObject
from PySide2.QtWidgets import QGraphicsItem

from NodeItem import NodeItem


class Node(QObject):
    def __init__(self, parent=None):
        super(Node, self).__init__(parent)
        self.item = NodeItem()

        self.incomming_connections = []

        self.outgoing_connections = []

    def setPosition(self, x, y):
        self.item.setPos(x, y)

    def getPosition(self):
        return self.item.scenePos()

    def getSize(self):
        return self.item.getSize()