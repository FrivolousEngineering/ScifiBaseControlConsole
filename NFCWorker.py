from PyQt5.QtCore import QObject
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtCore import pyqtSignal as Signal

import nfc
import time


class NFCWorker(QObject):
    cardDetected = Signal(str)
    finished = Signal()

    def __init__(self):
        super().__init__()
        self._read_result = None
        self.reader = nfc.ContactlessFrontend()
        self.reader.open('usb')

    @Slot(bool)
    def setReadResult(self, result: bool) -> None:
        self._read_result = result

    @Slot()
    def run(self):
        print("Starting NFC Worker")
        while True:
            try:
                tag = self.reader.connect(rdwr={'on-connect': lambda tag: False})
            except OSError: 
                print("FAILED TO FIND THE READER")
                time.sleep(5)
                # Couldn't find serial connection. Try again in a bit!
                self.reader.close()
                self.reader = nfc.ContactlessFrontend()
                self.reader.open('usb')

                continue
            try:
                uid = tag.identifier

                card_uid = ''
                for part in uid:
                    card_uid += "%02X" % part
                self.cardDetected.emit(card_uid)

            except AttributeError:  # can happen on a misread from pynfc
                self.reader.close()
                self.reader = nfc.ContactlessFrontend()
                self.reader.open('usb')

            finally:
                time.sleep(1)  # Only a single read per second
