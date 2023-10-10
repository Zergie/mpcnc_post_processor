from TftScreen import *

class MainScreen(TftScreen):
    def updateKlipper(self, state):
        if not self.tft.has_cells:
            self.tft.fillScreen(0x0000)
        self.tft.drawCell("x", 0, 0, 80, 20, f'X {state["gcode_move"]["position"][0]:.1f}', 2, 0xffff, 0x0000)
        self.tft.drawCell("y", 0, 20, 80, 20, f'Y {state["gcode_move"]["position"][1]:.1f}', 2, 0xffff, 0x0000)
        self.tft.drawCell("z", 0, 40, 80, 20, f'Z {state["gcode_move"]["position"][2]:.1f}', 2, 0xffff, 0x0000)
        self.tft.drawCell("workspace", 90, 0, 60, 20, f'G{53 + state["gcode_macro G92"]["workspace"]}', 2, 0x0000, 0xffff)
