from TftScreen import *

class MainScreen(TftScreen):
    _state = {
        'x' : [0.0, 0.0],
        'y' : [0.0, 0.0],
        'z' : [0.0, 0.0],
        'workspace' : [0, 0],
    }

    def _updateScreen(self):
        if self.tft is None:
            return
        if not self.tft.has_cells:
            self.tft.fillScreen(0x0000)

        self.tft.drawCell("x", 0, 0,  90, 20, f'X {sum(self._state['x']):.1f}', 2, 0xffff, 0x0000)
        self.tft.drawCell("y", 0, 20, 90, 20, f'Y {sum(self._state['y']):.1f}', 2, 0xffff, 0x0000)
        self.tft.drawCell("z", 0, 40, 90, 20, f'Z {sum(self._state['z']):.1f}', 2, 0xffff, 0x0000)
        self.tft.drawCell("workspace", 90, 0, 60, 20, f'G{53 + sum(self._state["workspace"])}', 2, 0x0000, 0xffff)

    def updateKlipper(self, state):
        self._state['x'][0] = state["gcode_move"]["position"][0]
        self._state['y'][0] = state["gcode_move"]["position"][1]
        self._state['z'][0] = state["gcode_move"]["position"][2]
        self._state['workspace'][0] = state["gcode_macro G92"]["workspace"]
        self._updateScreen()
    
    def on_button(self, index):
        print(f"on_button: {index}")

    def on_rotary(self, index, value):
        print(f"on_rotary: {index} -> {value}")

    def on_encoder(self, index, value):
        key = ' '

        if (index == 0):
            key = 'x'
        elif (index == 1):
            key = 'y'
        elif (index == 2):
            key = 'z'
        else:
            return
        
        self._state[key][1] += value
        self._updateScreen()
        print(f"on_encoder: {index} -> {value}")