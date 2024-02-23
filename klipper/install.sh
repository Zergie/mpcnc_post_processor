#!/bin/sh

PDIR="${HOME}/printer_data"
ENVDIR="${HOME}/mpcnc_post_processor-env"
DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ ! -d "$PDIR" ] ; then
    echo "mpcnc_post_processor: printer_data env doesn't exist"
    exit 1
fi

# update links
echo "mpcnc_post_processor: linking mpcnc to printer_data"
rm "${PDIR}/config/mpcnc" 2> /dev/null
ln -s "${DIR}" "${PDIR}/config/mpcnc"

# initial variables.cfg
if [ ! -f "$PDIR/variables.cfg" ] ; then
    touch "${PDIR}/variables.cfg"
fi
if ! grep -Fxq "[Variables]" "${PDIR}/variables.cfg"; then echo "[Variables]" >> "${PDIR}/variables.cfg"; fi
if ! grep -xq "workspace0 =.*" "${PDIR}/variables.cfg"; then echo "workspace0 = (0.0, 0.0, 0.0)" >> "${PDIR}/variables.cfg"; fi
if ! grep -xq "workspace1 =.*" "${PDIR}/variables.cfg"; then echo "workspace1 = (0.0, 0.0, 0.0)" >> "${PDIR}/variables.cfg"; fi
if ! grep -xq "workspace2 =.*" "${PDIR}/variables.cfg"; then echo "workspace2 = (0.0, 0.0, 0.0)" >> "${PDIR}/variables.cfg"; fi
if ! grep -xq "workspace3 =.*" "${PDIR}/variables.cfg"; then echo "workspace3 = (0.0, 0.0, 0.0)" >> "${PDIR}/variables.cfg"; fi
if ! grep -xq "workspace4 =.*" "${PDIR}/variables.cfg"; then echo "workspace4 = (0.0, 0.0, 0.0)" >> "${PDIR}/variables.cfg"; fi
if ! grep -xq "workspace5 =.*" "${PDIR}/variables.cfg"; then echo "workspace5 = (0.0, 0.0, 0.0)" >> "${PDIR}/variables.cfg"; fi

echo "mpcnc_post_processor: installation successful."
