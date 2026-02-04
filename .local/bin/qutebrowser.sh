#!/bin/bash

export QT_SCALE_FACTOR=1.2
export QT_QPA_PLATFORM=xcb
exec /usr/bin/qutebrowser $@
