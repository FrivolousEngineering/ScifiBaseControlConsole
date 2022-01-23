from PyQt5.QtCore import QUrl

from GraphMLParser import GraphMLParser
from ScifiBaseApplication import ScifiBaseApplication

import sys

import argparse


parser = argparse.ArgumentParser(description='Add some integers.')
parser.add_argument("--rfid_card", type=str, nargs='?',
                    help='If this parameter is set, the RFID card authentication is skipped and this value is used. Should only be used for debug purposes')


if __name__ == '__main__':
    parser = GraphMLParser("output.graphml")
    pass
    #app = ScifiBaseApplication("EngineeringConsole", sys.argv, parser)
    #app.showAndExec(QUrl("resources/qml/view.qml"))
