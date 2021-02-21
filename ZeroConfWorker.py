from zeroconf import Zeroconf, ServiceBrowser, ServiceStateChange, ServiceInfo

from queue import Queue
from typing import Optional
from threading import Thread, Event
from time import time
from PyQt5.QtCore import pyqtSignal as Signal, QObject
from PyQt5.QtCore import pyqtProperty as Property
from PyQt5.QtCore import pyqtSlot as Slot
import time
class ZeroConfWorker(QObject):
    ZEROCONFNAME = u"_ScifiBase._tcp.local."

    serverAddressChanged = Signal()

    def __init__(self) -> None:
        super().__init__()
        self._zero_conf = None  # type: Optional[Zeroconf]
        self._zero_conf_browser = None  # type: Optional[ServiceBrowser]

        self._service_changed_request_queue = None  # type: Optional[Queue]
        self._service_changed_request_event = None  # type: Optional[Event]
        self._service_changed_request_thread = None  # type: Optional[Thread]

        self._server_address = ""

    @Property(bool, notify=serverAddressChanged)
    def server_address(self):
        return self._server_address

    @Slot()
    def start(self) -> None:
        self._service_changed_request_queue = Queue()
        self._service_changed_request_event = Event()
        try:
            self._zero_conf = Zeroconf()
        except OSError:
            print("Something failed")
            return

        self._zero_conf_browser = ServiceBrowser(self._zero_conf, self.ZEROCONFNAME, [self._queueService])
        self.run()

    def stop(self) -> None:
        if self._zero_conf is not None:
            self._zero_conf.close()
            self._zero_conf = None
        if self._zero_conf_browser is not None:
            self._zero_conf_browser.cancel()
            self._zero_conf_browser = None

    def _queueService(self, zeroconf: Zeroconf, service_type, name: str, state_change: ServiceStateChange) -> None:
        if not self._service_changed_request_queue or not self._service_changed_request_event:
            return

        self._service_changed_request_queue.put((zeroconf, service_type, name, state_change))
        self._service_changed_request_event.set()

    def run(self) -> None:
        if not self._service_changed_request_queue or not self._service_changed_request_event:
            return

        while True:
            self._service_changed_request_event.wait(timeout=10.0)
            self._service_changed_request_event.clear()

            reschedule_requests = []
            while not self._service_changed_request_queue.empty():
                request = self._service_changed_request_queue.get()
                zeroconf, service_type, name, state_change = request
                try:
                    result = self._onServiceChanged(zeroconf, service_type, name, state_change)
                    if not result:
                        reschedule_requests.append(request)
                except Exception:
                    print("Failed to get service info for [%s] [%s], the request will be rescheduled" %(service_type, name))
                    reschedule_requests.append(request)

            if reschedule_requests:
                for request in reschedule_requests:
                    self._service_changed_request_queue.put(request)

    def _onServiceChanged(self, zero_conf: Zeroconf, service_type: str, name: str, state_change: ServiceStateChange) -> bool:
        if state_change == ServiceStateChange.Added:
            return self._onServiceAdded(zero_conf, service_type, name)
        elif state_change == ServiceStateChange.Removed:
            return self._onServiceRemoved(name)
        return True

    def _onServiceRemoved(self, name: str) -> bool:
        print("ZeroConf service removed: %s" % name)
        return True

    def _onServiceAdded(self, zero_conf: Zeroconf, service_type: str, name: str) -> bool:
        info = ServiceInfo(service_type, name, properties={})

        if not info.addresses:
            new_info = zero_conf.get_service_info(service_type, name)
            if new_info is not None:
                info = new_info

        if info and info.addresses:
            if info.name == "Base-Control-Server._ScifiBase._tcp.local.":
                self._server_address = '.'.join(map(str, info.addresses[0]))
                self.serverAddressChanged.emit()
        else:
            print("Could not get information about %s" % name)
            return False

        return True


