#!/usr/bin/env bash

STATE_FILE="/tmp/laptop_tp_state"

if [ ! -f "$STATE_FILE" ]; then
    echo "true" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

if [ "$CURRENT" = "true" ]; then
    NEW_STATE="false"
    notify-send "Touchpad disabled"
else
    NEW_STATE="true"
    notify-send "Touchpad enabled"
fi

echo "$NEW_STATE" > "$STATE_FILE"
hyprctl keyword '$TP_ENABLED' "$NEW_STATE" -r
