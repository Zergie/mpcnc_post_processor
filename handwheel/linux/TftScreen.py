import threading
from JogWheel import *

class TftScreen:
    def __init__(self, tft:JogWheel) -> None:
        self.tft = tft
        self.lock = threading.Lock()

    def updateApp(self, state:dict) -> None:
        pass

    def updateKlipper(self, state:dict) -> None:
        pass
