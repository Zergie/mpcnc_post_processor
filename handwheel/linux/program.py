#!/usr/bin/env python3

import re
from time import sleep

from serial import SerialException
from colors import *
import json
import websocket

from JogWheel import JogWheel
from MainScreen import MainScreen


host = "trident.local"
jog = JogWheel()
screen = MainScreen(jog)

# moonraker api: https://moonraker.readthedocs.io/en/latest/web_api/
# klipper objects: https://www.klipper3d.org/Status_Reference.html
state = {
    "gcode_move" : {},
    "print_stats" : {},
    "gcode_macro G92" : {},
}

def on_open(wsapp):
    global jog
    jog.printline(".. connected!")
    jog.printline("Subscribing to events ...")

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

def on_button(index):
    global screen
    screen.on_button(index)

def on_rotary(index, value):
    global screen
    screen.on_rotary(index, value)

def on_encoder(index, value):
    global screen
    screen.on_encoder(index, value)

if __name__ == '__main__':
    jog.on_button = on_button
    jog.on_rotary = on_rotary
    jog.on_encoder = on_encoder

    print("Looking for controller ...")
    port = 11
    while not jog.is_attached:
        if port > 19:
            port = 3
        try:
            # print(f"Trying COM{port}..")
            jog.attach(f'COM{port}')
        except SerialException as e:
            port += 1

    jog.printline(f"Connected via {jog.serial.portstr}.")
    jog.printline(f"Trying to connect {host} ...")
    jog.debug = ("<", "encoder<")
    # jog.debug = ("print>",)
    # ws = websocket.WebSocketApp(f'ws://{host}/websocket',
    #                             on_open=on_open,
    #                             on_message=on_message,
    #                             on_close=on_close,
    #                             )
    # ws.run_forever()
    sleep(10)
    jog.close()
