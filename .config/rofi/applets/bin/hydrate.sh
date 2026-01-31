#!/bin/bash

# Exit if DISPLAY is not set
if [ -z "$DISPLAY" ]; then
    echo "No DISPLAY found. Exiting."
    exit 0
fi

# play notification sound
mpv --no-video --quiet "$HOME/Music/notification-1.mp3" >/dev/null 2>&1 &

yes=' Done'
no=' Later'

selected=$(
    echo -e "$no\n$yes" | rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Time to drink some water' \
        -theme $HOME/.config/rofi/applets/type-1/style-2.rasi
)

if [[ $selected == $yes ]]; then
    echo "Done"
else
    echo "Later"
    sleep 300
    exec $0
fi
