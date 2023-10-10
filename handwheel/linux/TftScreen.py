from Tft import *

class TftScreen:
    def __init__(self, tft:Tft) -> None:
        self.tft = tft

    def updateApp(self, state:dict) -> None:
        pass

    def updateKlipper(self, state:dict) -> None:
        pass
