from PySide2.QtWidgets import QGraphicsView

from Generator import Generator
from Node import Node
from NodeScene import NodeScene
from Connection import Connection


class NodeViewer(QGraphicsView):
    def __init__(self, parent=None):
        super(NodeViewer, self).__init__(parent)

        self.setScene(NodeScene(self))

        self._node = Node("fuel_storage_1")

        self._node_2 = Generator("generator_1")

        self._node_3 = Node("battery_2")
        self._node_3.setSupportedInputs(["energy"])
        #self._node_4 = Node("Water Storage")
        #self._node_5 = Node("Fuel Storage")
        #self._node_4.setPosition(0, 550)
        #self._node_5.setPosition(0, 275)

        self._node_2.setPosition(450, 250)
        self._node_3.setPosition(800, 0)
        self._connection = Connection(self._node, self._node_2, "fuel")
        self._connection_2 = Connection(self._node_2, self._node_3, "energy")

        #self._connection_3 = Connection(self._node_4, self._node_2, "water")
        #self._connection_4 = Connection(self._node_5, self._node_2, "fuel")
        self.addItems(self._node.getItemsToDraw())
        self.addItems(self._node_2.getItemsToDraw())
        self.addItems(self._node_3.getItemsToDraw())
        #self.addItems(self._node_4.getItemsToDraw())
        #self.addItems(self._node_5.getItemsToDraw())
        self.addItems(self._connection.getItemsToDraw())
        self.addItems(self._connection_2.getItemsToDraw())
        #self.addItems(self._connection_3.getItemsToDraw())
        #self.addItems(self._connection_4.getItemsToDraw())

        self.resize(1100, 800)
        self.setSceneRect(0, 0, 1100, 800)

    def addItems(self, items_to_add):
        for item in items_to_add:
            self.scene().addItem(item)
