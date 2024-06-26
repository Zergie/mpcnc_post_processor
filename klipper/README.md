# Klipper Macros for MPCNC

Useful klipper macros for using with your MPCNC.

### Installation

Clone this repo to your $Home folder.


### Configuration

```
# printer.cfg

[include mpcnc/essential/*.cfg]
[include mpcnc/optional/*.cfg]
```

```
# moonraker.cfg

[update_manager mpcnc_post_processor]
type: git_repo
path: ~/mpcnc_post_processor
origin: https://github.com/Zergie/mpcnc_post_processor.git
primary_branch: master
install_script: klipper/install.sh
managed_services: klipper
```

### Special output_pins

| Name       | Description                                                                                           |
|------------|-------------------------------------------------------------------------------------------------------|
| RELAY_M3   | Relais pin for Spindle                                                                                |
| RELAY_M3_1 | Relaus pin for Spindle, toggled on after a short delay e.g. for the safety switch on a RT0702C router |
| RELAY_M7   | Relais pin for Coolant 1                                                                              |
| RELAY_M8   | Relais pin for Coolant 2                                                                              |
| BEEPER     | Pin for audio feedback                                                                                |

### Added G-codes

| Gcode          | Description                              | config   |
|----------------|------------------------------------------|----------|
| CANCEL_PRINT   | Cancel the running print                 | optional |
| END_PRINT      | End Print                                | optional |
| G53            | Select machine coordinates               |          |
| G54            | Select coord system 1                    |          |
| G55            | Select coord system 2                    |          |
| G56            | Select coord system 3                    |          |
| G57            | Select coord system 4                    |          |
| G58            | Select coord system 5                    |          |
| G59            | Select coord system 6                    |          |
| G92            | Set origin offsets                       |          |
| G92.1          | Reset origin offsets                     |          |
| G92.2          | Suspend origin offsets                   |          |
| G92.3          | Resume origin offsets                    |          |
| M0             | Pause                                    |          |
| M1             | Pause                                    |          |
| M3             | Spindle CW                               | optional |
| M300           | beep                                     | optional |
| M4             | Spindle CCW                              | optional |
| M5             | Spindle Off                              | optional |
| M601           | Pause                                    |          |
| M7             | Coolant 1 On                             | optional |
| M8             | Coolant 2 On                             | optional |
| M9             | All Coolants Off                         | optional |
| PAUSE          | Pause Print                              | optional |
| PLANE          | Planes surface                           |          |
| PRINT_INFO_G92 | Prints debug info for G92                |          |
| PROBE_TOOL     | Probes tool and sets offset              |          |
| RELAY_OFF      | Turn all via relay connected devices off | optional |
| RESUME         | Resume the running print                 | optional |
| START_PRINT    | Start Print                              | optional |

