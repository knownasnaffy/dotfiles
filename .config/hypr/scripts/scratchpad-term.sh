#!/usr/bin/env bash

title="ScratchTerm"

# Check if window exists
addr=$(hyprctl clients -j | jq -r --arg t "$title" '.[] | select(.title==$t) | .address')

if [ -z "$addr" ]; then
    # Not running → start it (your rule will send it to special:magic)
    uwsm app -- ghostty --title=$title &
    exit 0
fi

# Running → just toggle the special workspace
hyprctl dispatch togglespecialworkspace magic
