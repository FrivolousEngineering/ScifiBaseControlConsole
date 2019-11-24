from Node import Node


class Generator(Node):
    def __init__(self, name, parent=None):
        super(Generator, self).__init__(name, parent)
        self.setSupportedInputs(["water", "fuel"])
        self.setSupportedOutputs(["energy"])
