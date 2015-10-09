#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- hackdepot "$@"
fi

if [ "$1" = 'hackdepot' ]; then
    cd /srv/hackdepot
    ./hackdepot && while true; do sleep 1; done
fi

exec $@
