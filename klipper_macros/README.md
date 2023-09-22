# Klipper Macros for MPCNC

Useful klipper macros for useing with your MPCNC.

### Installation

Clone this repo to your $Home folder.


### Configuration

```
# printer.cfg

[include macros/macros.cfg]
```

```
# moonraker.cfg

[update_manager mpcnc_post_processor]
type: git_repo
path: ~/mpcnc_post_processor
origin: https://github.com/Zergie/mpcnc_post_processor.git
primary_branch:master
env: ~/mobileraker-env/bin/python
install_script: klipper_macros/install.sh
```

### Added G-codes

| Gcode   | Description                 |
| ------- | --------------------------- |
| G53     | Select machine coordinates  |
| G54     | Select coord system 1       |
| G55     | Select coord system 2       |
| G56     | Select coord system 3       |
| G57     | Select coord system 4       |
| G58     | Select coord system 5       |
| G59     | Select coord system 6       |
| G92     | Set origin offsets          |
| G92.1   | Reset origin offsets        |
| G92.2   | Suspend origin offsets      |
| G92.3   | Resume origin offsets       |
| M0      | Pause                       |
| M1      | Pause                       |
| M601    | Pause                       |
| T0      | Select tool 0               |
| T1      | Select tool 1               |
| T2      | Select tool 2               |
| T3      | Select tool 3               |
| T4      | Select tool 4               |
| T5      | Select tool 5               |
| T6      | Select tool 6               |
