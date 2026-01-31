#!/usr/bin/env bash

target="$1"
current=$(hyprctl activeworkspace -j | jq -r '.id')

if [ "$current" = "$target" ]; then
    hyprctl dispatch workspace previous
else
    hyprctl dispatch workspace "$target"
fi
