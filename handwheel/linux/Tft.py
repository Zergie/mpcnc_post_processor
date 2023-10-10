import serial
import struct

class Tft:
    def __init__(self, port) -> None:
        self.serial = serial.Serial(port, baudrate=9600)
        self._textsize = None
        self._textcolor = None
        self._cells = {}

    @property
    def has_cells(self) -> bool:
        return len(self._cells) > 0

    def close(self) -> None:
        self.serial.close()

    def write(self, message) -> None:
        # print(f">{message}")
        self.serial.write(message)
        # print(f"<{self.serial.read()}")

    def fillScreen(self, color:int) -> None:
        message = b'f'
        message += struct.pack('<H', color)
        self.write(message)

    def fillRect(self, x:int, y:int, width:int, height:int, color:int) -> None:
        message = b'r'
        message += struct.pack('<h', x)
        message += struct.pack('<h', y)
        message += struct.pack('<H', width)
        message += struct.pack('<H', height)
        message += struct.pack('<H', color)
        self.write(message)

    def print(self, x:None|int = None, y:None|int = None, text:str = "", size:None|int = 1, color:None|int = 0xffff) -> None:
        message = b''
        if x != None and y != None:
            message += b'_'
            message += struct.pack('<h', x)
            message += struct.pack('<h', y)
        elif x == None and y == None:
            pass
        else:
            raise ValueError("x and y must be None or Int")
        if size != None and size != self._textsize:
            message += b's'
            message += struct.pack('<B', size)
            self._textsize = size
        if color != None and color != self._textcolor:
            message += b'c'
            message += struct.pack('<H', color)
            self._textcolor = color
        if text != None:
            message += b't'
            message += struct.pack('<H', len(text))
            message += text.encode()
        self.write(message)

    def drawCell(self, id:str, x:int, y:int, width:int, height:int, text:str, size:int, fg:int, bg:int) -> None:
        checksum = hash((x, y, width, height, text, size, fg, bg))

        if id in self._cells and self._cells[id] == checksum:
            pass
        else:
            self.fillRect(x, y, width, height, bg)
            self.print(x+2, y+3, text, size, fg)
            self._cells[id] = checksum
            # print(checksum)
