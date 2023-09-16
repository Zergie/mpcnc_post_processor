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

| Gcode   | Parameters                | Command   | Description   |
| ------- | ------------------------- | --------- | ------------- |
| G92.1   | Reset origin offsets      |           |               |
| G92.2   | Suspend origin offsets    |           |               |
| G92.3   | Resume origin offsets     |           |               |
