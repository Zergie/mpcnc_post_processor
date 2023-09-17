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
| G92     | Set origin offsets          |
| G92.1   | Reset origin offsets        |
| G92.2   | Suspend origin offsets      |
| G92.3   | Resume origin offsets       |
| G53     | Select machine coordinates  |
| G54     | Select coord system 1       |
| G55     | Select coord system 2       |
| G56     | Select coord system 3       |
| G57     | Select coord system 4       |
| G58     | Select coord system 5       |
| G59     | Select coord system 6       |
