#!/bin/sh

PDIR="${HOME}/printer_data"
DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ ! -d "$PDIR" ] ; then
    echo "mpcnc_post_processor: printer_data env doesn't exist"
    exit 1
fi

# update link to macros
echo "mpcnc_post_processor: linking printer_data to macros"
rm "${PDIR}/config/macros" 2> /dev/null
ln -s "${DIR}" "${PDIR}/config/macros"

echo "mpcnc_post_processor: installation successful."
