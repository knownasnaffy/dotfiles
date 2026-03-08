#!/usr/bin/env bash

app="$1"
class="$2"
ws="$3"

echo "App: $1"
echo "Class: $2"
echo "SpecialWorkspace: $3"

# Check if window exists
addr=$(hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .address')
focusHistoryID=$(hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .focusHistoryID')

[ -n "$addr" ] && echo "Window found"
[[ -n $focusHistoryID && $focusHistoryID -eq 0 ]] && echo "Window is focused"
# Running → just toggle the special workspace

toggle=0
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slide top"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slide bottom"
if [[ -n $focusHistoryID && $focusHistoryID -eq 0 ]]; then toggle=1; echo "Hallelujah"; fi
hyprctl dispatch workspace 11
[[ "$toggle" -eq 1 ]] || (hyprctl dispatch togglespecialworkspace $ws && [ -z "$addr" ] && hyprctl dispatch exec "uwsm app -- $app")
hyprctl keyword animation "workspacesOut, 1, 3.34, easeOutBack, slidevert"
hyprctl keyword animation "workspacesIn,  1, 2.51, easeOutBack, slidevert"

#  TODO: Implement this logic:
#        ..
#        Case 1: we are on a normal workspace (1-10): we go to workspace 11 and
#        toggle special workspace and execute the app if it isn't already open
#        ..
#        Case 2: we are already focused on the window we are supposed to toggle,
#        so we just try to go to workspace 11 which is supposedly already
#        active, which takes us back to the workspace we came from
#        ..
#        Case 3: we are not on a normal workspace, and we are not on the special
#        workspace we are supposed to be, it means we are either on workspace >
#        10 or we are on a special worksapce of some other app. In this case, we
#        don't toggle the workspace 11 at all, instead, we toggle our target
#        special workspace which simply focuses it.
