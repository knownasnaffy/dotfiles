#!/usr/bin/env bash

title="ScratchTerm"

# Check if window exists
addr=$(hyprctl clients -j | jq -r --arg t "$title" '.[] | select(.title==$t) | .address')

if [ -z "$addr" ]; then
    # Not running → start it (your rule will send it to special:magic)
    hyprctl dispatch exec "uwsm app -- ghostty --title=$title"
fi

# Running → just toggle the special workspace

toggle=0
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slide top"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slide bottom"
if [[ $(hyprctl activeworkspace -j | jq '.id') -eq 11 ]]; then toggle=1; fi
hyprctl dispatch workspace 11
[[ "$toggle" -eq 1 ]] || hyprctl dispatch togglespecialworkspace magic
echo $toggle
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slide"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slide"
