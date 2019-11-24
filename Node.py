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

        self._supported_inputs = []
        self._supported_outputs = []
        self._offset = 20

    def setSupportedInputs(self, supported_inputs):
        self._supported_inputs = supported_inputs

    def setSupportedOutputs(self, supported_outputs):
        self._supported_outputs = supported_outputs

    def getInputOffset(self, resource_type):
        #TODO; Find a better way to do this, but i can't be bothered now.
        index = self._supported_inputs.index(resource_type)
        if len(self._supported_inputs) == 1:
            return 0
        if len(self._supported_inputs) == 2:
            if index == 0:
                return self._offset * 0.5
            else:
                return -self._offset * 0.5
        if len(self._supported_inputs) == 3:
            if index == 0:
                return 0
            if index == 1:
                return self._offset
            else:
                return -self._offset

    def getItemsToDraw(self):
        result = [self.item]
        return result

    def setPosition(self, x, y):
        self.item.setPos(x, y)

    def getPosition(self):
        return self.item.scenePos()

    def getSize(self):
        return self.item.getSize()