#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

# Wait for termination
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch Polybar on all connected monitors
echo "---" | tee -a /tmp/polybar.log

for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
  MONITOR=$m polybar bar1 2>&1 | tee -a /tmp/polybar-$m.log & disown
done

echo "Bars launched on all monitors..."
