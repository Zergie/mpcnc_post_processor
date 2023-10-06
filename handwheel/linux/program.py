#!/usr/bin/env python3

from colors import *
import websocket
import json

from colors import util

host = "trident.local"

# moonraker api: https://moonraker.readthedocs.io/en/latest/web_api/
# klipper objects: https://www.klipper3d.org/Status_Reference.html
state = {
    "gcode_move" : {},
    "print_stats" : {},
    "gcode_macro G92" : {},
}

def on_open(wsapp):
    message = {
        "jsonrpc": "2.0",
        "method": "printer.objects.subscribe",
        "params": {
            "objects": {
                        # "gcode_move": [ "position", "speed_factor" ],
                        "gcode_move": [ "speed_factor" ],
                        "print_stats": [ "state" ],
                        "gcode_macro G92": [ "workspace" ],
                        }
            },
        "id": 5434,
    }
    wsapp.send(json.dumps(message))

def on_message(wsapp, message):
    msg = json.loads(message)
    updated = False

    for key, _ in state.items():
        try:
            state[key] = msg['params'][0][key]
            updated = True
        except:
            try:
                state[key] = msg['result']['status'][key]
                updated = True
            except:
                pass

    if updated:
        try:
            print(state)
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
    ws = websocket.WebSocketApp('ws://' + host + '/websocket',
                                on_open=on_open,
                                on_message=on_message,
                                on_close=on_close,
                                )
    ws.run_forever()
