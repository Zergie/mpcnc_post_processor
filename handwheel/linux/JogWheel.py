from time import sleep
import serial
import struct
from threading import Lock, Thread

from colors import fg, util

class JogWheel:
    def __init__(self) -> None:
        self.debug = []
        self.serial:serial.Serial = None
        self._state_reader = Thread(target=self._check_buttons)
        self.on_button = None
        self.on_rotary = None
        self.on_encoder = None
        self.shutdown = False
        self._lock = Lock()
        self.rotary = [0, 0]

    def attach(self, port) -> None:
        self.serial = serial.Serial(port, baudrate=115200, timeout=.10)
        self._textsize:int = None
        self._textcolor:int = None
        self._cells = {}
        self._print_buffer = []

        self._state_reader.start()
        self.write(b'x', 1)
        self.fillScreen(0x0000)

    @property
    def is_attached(self) -> bool:
        if self.serial is None:
            return False
        return self.serial.is_open

    @property
    def has_cells(self) -> bool:
        return len(self._cells) > 0
    
    def _debug(self, text:str) -> None:
        if len(self.debug) > 0:
            for i in self.debug:
                if text.startswith(i):
                    print(text.replace("\\x00", f"{fg.gray}\\x00{util.reset}"))
                    return

    def close(self) -> None:
        print("closing..")
        self.shutdown = True
        self._state_reader.join()
        self.serial.flush()
        self.serial.read_all()
        self.serial.close()

    def write(self, message, size:None|int) -> None|bytes:
        self._debug(f">{message}")
        with self._lock:
            try:
                self.serial.write(message)
            except serial.SerialTimeoutException:
                sleep(.1)
                self.serial.write(message)
            if size != None:
                return self._read(size)
    
    def _read(self, size) -> bytes:
        try:
            message = self.serial.read(size)
            self._debug(f"<{message}")
            return message
        except Exception as e:
            print(f"read({size}) error: {e}")
            return b'\0' * size

    def fillScreen(self, color:int) -> None:
        message = b'f'
        message += struct.pack('<H', color)
        self.write(message, 1)

    def fillRect(self, x:int, y:int, width:int, height:int, color:int) -> None:
        message = b'r'
        message += struct.pack('<h', x)
        message += struct.pack('<h', y)
        message += struct.pack('<H', width)
        message += struct.pack('<H', height)
        message += struct.pack('<H', color)
        self.write(message, 1)

    def print(self, x:None|int = None, y:None|int = None, text:str = "", size:None|int = 1, color:None|int = 0xFFFF) -> None:
        message = b''
        if x != None and y != None:
            self.write(b'_' + struct.pack('<h', x) + struct.pack('<h', y), 1)
        elif x == None and y == None:
            pass
        else:
            raise ValueError("x and y must be None or Int")
        if size != None and size != self._textsize:
            self.write(b's' + struct.pack('<B', size), 1)
            self._textsize = size
        if color != None and color != self._textcolor:
            self.write(b'c' + struct.pack('<H', color), 1)
            self._textcolor = color
        if text != None:
            self._debug(f"print> {text}")
            self.write(b't' + struct.pack('<H', len(text)) + text.encode(), 1)
    
    def printline(self, text:str) -> None:
        if len(text) < 22:
            self._debug(f"printline> {text}")
            if len(self._print_buffer) >= 14:
                for i in range(0, 14):
                    y = i*9
                    self.print(0, y, self._print_buffer[i], 1, 0)
                del self._print_buffer[0]
                for i in range(0, 13):
                    y = i*9
                    self.print(0, y, self._print_buffer[i], 1)
            
            y = len(self._print_buffer) * 9
            self.print(0, y, text, 1, 0xffff)
            self._print_buffer.append(text)
        else:
            while(len(text) > 21):
                self.printline(text[:21])
                text = text[21:]
            self.printline(text)

    def drawCell(self, id:str, x:int, y:int, width:int, height:int, text:str, size:int, fg:int, bg:int) -> None:
        checksum = hash((x, y, width, height, text, size, fg, bg))

        if id in self._cells and self._cells[id] == checksum:
            pass
        else:
            self.fillRect(x, y, width, height, bg)
            self.print(x+2, y+3, text, size, fg)
            self._cells[id] = checksum
            # self.debug(checksum)
    
    def _check_buttons(self):
        while 1:
            if self.shutdown:
                return
            
            if self.serial.is_open:
                message = b'i'
                data = self.write(message, 6 + 3*4)
                
                if len(data) > 0:
                    buttons = []
                    for b in data[:4]:
                        buttons.append(bool(b & 1))
                        buttons.append(bool((b & 2) >> 1))
                        buttons.append(bool((b & 4) >> 2))
                        buttons.append(bool((b & 8) >> 3))

                    if not self.on_button is None:
                        for i in range(0, len(buttons)):
                            if buttons[i]:
                                self.on_button(i)


                    rotary = []
                    lookup = { 8:1, 4:2, 2:3, 1:4, 0:0 }
                    for b in data[4:6]:
                        if b in lookup:
                            rotary.append(lookup[b])

                    if not self.on_rotary is None:
                        for i in range(0, len(rotary)):
                            if rotary[i] != self.rotary[i]:
                                self.on_rotary(i, rotary[i])
                                self.rotary[i] = rotary[i]


                    encoder = [data[6:10], data[10:14], data[14:18]]
                    self._debug(f"encoder<{encoder}")
                    encoder = [struct.unpack('<i', i)[0] for i in encoder]
                    self._debug(f"encoder<{encoder}")
                    if not self.on_encoder is None:
                        for i in range(0, len(encoder)):
                            if encoder[i] != 0:
                                self.on_encoder(i, round(float(encoder[i])/2 - .1)  )

                sleep(1)