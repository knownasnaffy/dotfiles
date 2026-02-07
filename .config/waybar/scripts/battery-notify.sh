#!/bin/sh

# battery-notify
#
# Stateful battery notification helper for Waybar + swaync.
#
# swaync does not allow dismissing notifications programmatically, so this script
# tracks the notification ID returned by notify-send (-p) and reuses it (-r) to
# replace or clear previous battery notifications reliably.
#
# Supported modes:
#   warning   -> send low battery warning
#   critical  -> send critical battery warning
#   full      -> send battery full notification
#   (no args) -> if battery state is charging, clear the active battery notification
#
# The notification ID is stored per-user in /run/user/$UID and updated automatically
# when swaync assigns a new one. Safe to call repeatedly and from on-update hooks.

set -eu

idfile="/run/user/$UID/battery.notifyid"
lockfile="${idfile}.lock"

battery_path=$(upower -e | grep battery | head -n1)

get_state() {
    upower -i "$battery_path" | awk '/state/ {print $2}'
}

send() {
    old_id="${1:-0}"
    shift
    notify-send -p -r "$old_id" "$@"
}

(
    flock -x 9

    old_id="$(cat "$idfile" 2>/dev/null || echo 0)"

    case "${1:-}" in
        warning)
            new_id="$(send "$old_id" \
        -a battery 'Battery Low (20%)' \
        -u critical -i battery-020)"
            ;;

        critical)
            new_id="$(send "$old_id" \
        -a battery 'Battery Critical (10%)' \
        -u critical -i battery-010)"
            ;;

        full)
            new_id="$(send "$old_id" \
        -a battery 'Battery Full (100%)' \
        -i battery-100-charged)"
            ;;

        "")
            state="$(get_state)"
            if [ "$state" = "charging" ]; then
                new_id="$(send "$old_id" -a no-sound '' -t 1 --transient)"
            else
                exit 0
            fi
            ;;

        *)
            exit 1
            ;;
    esac

    [ "$new_id" != "$old_id" ] && echo "$new_id" >"$idfile"

) 9>"$lockfile"
