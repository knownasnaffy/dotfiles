#!/usr/bin/env bash

term_title="TabTerm$$"

# Step 1: ensure current node is a tab group
hyprctl dispatch hy3:makegroup tab

# Step 2: spawn terminal
uwsm app -- ghostty --title="$term_title" &

# Step 3: wait for it to map, then move into the group
for i in {1..20}; do
    addr=$(hyprctl clients -j | jq -r --arg t "$term_title" '.[] | select(.title==$t) | .address')
    [ -n "$addr" ] && break
    sleep 0.05
done

hyprctl dispatch hy3:moveintogroup address:"$addr"
