#!/usr/bin/env python3

import re
from colors import *
import json
import websocket

from Tft import Tft
from MainScreen import MainScreen


host = "trident.local"
tft = Tft('COM4')

# moonraker api: https://moonraker.readthedocs.io/en/latest/web_api/
# klipper objects: https://www.klipper3d.org/Status_Reference.html
state = {
    "gcode_move" : {},
    "print_stats" : {},
    "gcode_macro G92" : {},
}

def on_open(wsapp):
    global tft
    tft.print(0, 30, ".. connected!")
    tft.print(0, 40, "Subscribing to events ...")

    message = {
        "jsonrpc": "2.0",
        "method": "printer.objects.subscribe",
        "params": {
            "objects": {
                        "gcode_move": [ "position", "speed_factor" ],
                        "print_stats": [ "state" ],
                        "gcode_macro G92": [ "workspace" ],
                        }
            },
        "id": 5434,
    }
    wsapp.send(json.dumps(message))

def on_message(wsapp, message):
    global tft
    global screen
    msg = json.loads(message)
    updated = False

    for key, _ in state.items():
        try:
            state[key] = msg['params'][0][key]
            updated = True
        except:
            try:
                state[key] = msg['result']['status'][key] # todo (fixme): when speed_factor is changed, position gets removed
                updated = True
            except:
                pass

    if updated:
        try:
            print(state)
            screen.updateKlipper(state)

            print(f"{fg.green}%s{util.reset}" % {
                "state" : state["print_stats"]["state"],
                "speed_factor" : int(state["gcode_move"]["speed_factor"] * 100),
                "workspace" : "G%i" % (53 + state["gcode_macro G92"]["workspace"]),
            })

        except Exception as e:
            print(f"{fg.red}{e}{util.reset}")

def on_close(wsapp):
    print("connection closed")

if __name__ == '__main__':
    screen = MainScreen(tft)

    tft.fillScreen(0x0000)
    tft.print(0, 0, "Loading ...")

    tft.print(0, 10, f"Trying to connect {host} ...") # todo: implement printline
    ws = websocket.WebSocketApp(f'ws://{host}/websocket',
                                on_open=on_open,
                                on_message=on_message,
                                on_close=on_close,
                                )
    ws.run_forever()

    tft.close()
