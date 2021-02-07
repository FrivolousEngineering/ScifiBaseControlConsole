from PyQt5.QtCore import QUrl

from ScifiBaseApplication import ScifiBaseApplication

import sys

if __name__ == '__main__':
    app = ScifiBaseApplication('Test', sys.argv)
    app.showAndExec(QUrl("resources/qml/view.qml"))
