from PySide2.QtCore import QObject

from NodeItem import NodeItem


class Node(QObject):
    def __init__(self, name, parent=None):
        super(Node, self).__init__(parent)
        self._size = 250
        self.item = NodeItem()
        self.item.setSize(self._size)
        self.item.setName(name)
        self._name = name

    def getItemsToDraw(self):
        result = [self.item]
        return result

    def setPosition(self, x, y):
        self.item.setPos(x, y)

    def getOutgoingPorts(self):
        self.item.getOutgoingPorts()

    def getPosition(self):
        return self.item.scenePos()

    def getSize(self):
        return self.item.getSize()