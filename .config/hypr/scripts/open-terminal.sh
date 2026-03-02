#!/usr/bin/env bash

focused_class="$(hyprctl activewindow -j | jq -r '.class // empty')"
focused_addr="$(hyprctl activewindow -j | jq -r '.address')"

if [[ "$focused_class" == "footclient" ]]; then
    hyprctl dispatch sendshortcut "CTRL SHIFT, N, address:$focused_addr"
    exit 0
fi

hyprctl dispatch exec "uwsm app -- $TERMINAL"
