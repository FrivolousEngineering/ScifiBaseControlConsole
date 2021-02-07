from PyQt5.QtCore import QObject
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtCore import pyqtSignal as Signal


class SerialWorker(QObject):
    cardDetected = Signal(str)
    finished = Signal()

    def __init__(self, serial):
        super().__init__()
        self._serial = serial
        self._read_result = None

    @Slot(bool)
    def setReadResult(self, result):
        self._read_result = result

    @Slot()
    def run(self):
        while True:
            if self._read_result is not None:
                if self._read_result is True:
                    self._serial.write(b"ok\n")
                else:

                    self._serial.write(b"nok\n")
                self.setReadResult(None)
            try:
                line = self._serial.readline()
            except:
                self.finished.emit()
                return
            if not line:
                # Skip empty commands
                continue
            # TODO: clean up this horrible excuse of code.
            if line.startswith(b"start"):
                print("Serial started as expected")
            else:
                # We got an access code
                card_id = line.rstrip()
                self.cardDetected.emit(card_id.decode("utf-8"))
