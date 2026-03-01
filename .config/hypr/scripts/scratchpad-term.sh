#!/usr/bin/env bash

title="ScratchTerm"

# Check if window exists
addr=$(hyprctl clients -j | jq -r --arg t "$title" '.[] | select(.initialTitle==$t) | .address')

# Running → just toggle the special workspace

toggle=0
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slide top"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slide bottom"
if [[ $(hyprctl activeworkspace -j | jq '.id') -eq 11 ]]; then toggle=1; fi
hyprctl dispatch workspace 11
[[ "$toggle" -eq 1 ]] || hyprctl dispatch togglespecialworkspace magic && [ -z "$addr" ] && hyprctl dispatch exec "uwsm app -- $TERMINAL --title \"$title\""
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slidevert"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slidevert"
