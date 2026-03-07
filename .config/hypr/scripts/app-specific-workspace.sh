#!/usr/bin/env bash

app="$1"
class="$2"
ws="$3"

# Check if window exists
addr=$(hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .address')
focusHistoryID=$(hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .focusHistoryID')

[ -z "$addr" ] && echo "Window found"
[[ $focusHistoryID -eq 0 ]] && echo "Window is focused"
# Running → just toggle the special workspace

toggle=0
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slide top"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slide bottom"
if [[ $focusHistoryID -eq 0 ]]; then toggle=1; echo "Hallelujah"; fi
hyprctl dispatch workspace 11
[[ "$toggle" -eq 1 ]] || (hyprctl dispatch togglespecialworkspace $ws && [ -z "$addr" ] && hyprctl dispatch exec "uwsm app -- $app")
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slidevert"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slidevert"
