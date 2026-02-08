#!/bin/sh

# battery-notify
#
# Battery notification helper for Waybar + swaync.
#
# Supported modes:
#   warning   -> send low battery warning
#   critical  -> send critical battery warning
#   full      -> send battery full notification
#
# Stateful behavior was removed as there was no direct way to reset a permanent
# notification, and adding a timeout notification was causing trouble as it was
# sent in regular intervals, even if not visible to the eye, it was disrupting
# other notifications and sometimes blocking screenshots and other actions. So
# now the script just sends a notification with the appropriate urgency and
# message.

set -eu

dir="$HOME/.config/rofi/powermenu/type-1"
theme='style-1'

ok='OK'

rofi_cmd() {
    if [ "$1" = "critical" ]; then
        color="#f7768e"
        message="Battery critical! 10%"
    else
        color="#e0af68"
        message="Battery low! 20%"
    fi
    echo -e "$ok" |rofi -theme-str "window {location: center; anchor: center; fullscreen: false; width: 250px; background-color: $color;}" \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 1; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5; background-color: transparent; text-color: #15161Eaa;}' \
        -theme-str 'message {background-color: transparent;}' \
        -theme-str 'element selected.normal {background-color: #1A1B2644; text-color: #15161Edd;}' \
        -dmenu \
        -mesg "<b>$message</b>" \
        -theme ${dir}/${theme}.rasi
}

case "${1:-}" in
    warning)
        mpv --no-video --quiet ~/Music/battery-warning.mp3 &
        rofi_cmd "warning"
        ;;

    critical)
        mpv --no-video --quiet ~/Music/battery-critical.mp3 &
        rofi_cmd "critical"
        ;;

    full)
        notify-send -a Battery 'Battery Full (100%)' -i battery-100-charged
        ;;
    *)
        exit 1
        ;;
esac
