#!/usr/bin/env bash

focused_class="$(hyprctl activewindow -j | jq -r '.class // empty')"

if [[ "$focused_class" == "footclient" ]]; then
    sleep 0.3 && ydotool key 29:1 42:1 49:1 49:0 42:0 29:0
    exit 0
fi

hyprctl dispatch exec "uwsm app -- $TERMINAL"
