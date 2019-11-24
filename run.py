import sys
from PySide2.QtWidgets import QApplication


import NodeViewer



if __name__ == '__main__':
    # Create the Qt Application
    app = QApplication(sys.argv)
    # Create and show the form
    node_viewer = NodeViewer.NodeViewer()
    node_viewer.show()
    # Run the main Qt loop
    sys.exit(app.exec_())