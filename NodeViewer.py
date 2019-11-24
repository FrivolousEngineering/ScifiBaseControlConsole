from PySide2.QtWidgets import QGraphicsView

from Node import Node
from NodeScene import NodeScene
from Connection import Connection


class NodeViewer(QGraphicsView):
    def __init__(self, parent=None):
        super(NodeViewer, self).__init__(parent)

        self.setScene(NodeScene(self))
        self._node = Node()
        self._node_2 = Node()

        self._node_2.setPosition(450, 250)
        self._connection = Connection(self._node, self._node_2)


        self.scene().addItem(self._node.item)
        self.scene().addItem(self._node_2.item)
        self.addItems(self._connection.getItemsToDraw())
        self.resize(1100, 800)
        self.setSceneRect(0, 0, 1100, 800)

    def addItems(self, items_to_add):
        for item in items_to_add:
            self.scene().addItem(item)