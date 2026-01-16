#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x), Barinderpreet Singh (knownasnaffy)
## Github  : @adi1090x, @knownasnaffy
#
## Applets : Screen Recording

# Wayland only
[ "$XDG_SESSION_TYPE" = "wayland" ] || exit 1

# Import Current Theme
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/style-4.rasi"

# Theme Elements
prompt='Record Screen'
mesg="DIR: ~/Videos/Screen Recordings"

list_col='1'
win_width='400px'

# Options
option_1=" Record Full Screen"
option_2=" Record Area"
option_3=" Stop Recording"
option_4=" Open Recordings Folder"

# Build menu dynamically
if ! pgrep wf-recorder >/dev/null; then
    options="$option_1\n$option_2\n$option_4"
    list_row='3'
else
    options="$option_3\n$option_4"
    list_row='2'
fi

# Rofi CMD
rofi_cmd() {
    rofi -theme-str "window {width: $win_width;}" \
        -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -dmenu \
        -p "$prompt" \
        -markup-rows \
        -mesg "$mesg" \
        -theme "$theme"
}

run_rofi() {
    echo -e "$options" | rofi_cmd
}

# Recording variables
dir="$HOME/Videos/Screen Recordings"
file="Recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"

mkdir -p "$dir"

# Actions
chosen="$(run_rofi)"
case "$chosen" in
    $option_1)
        notify-send "Screen Recorder" "Recording started (Full Screen)"
        sleep 0.7
        wf-recorder \
            -f "$dir/$file" \
            --codec h264_nvenc \
            --preset p5 \
            --cq 23 \
            --audio \
            --audio-bitrate 128k \
            --audio-buffer 8192
        notify-send "Screen Recorder" "Recording stopped"
        ;;

    $option_2)
        region="$(slurp)" || exit 0
        notify-send "Screen Recorder" "Recording started (Area)"
        sleep 0.7
        wf-recorder \
            -g "$region" \
            -f "$dir/$file" \
            --codec h264_nvenc \
            --preset p5 \
            --cq 23 \
            --audio \
            --audio-bitrate 128k \
            --audio-buffer 8192
        notify-send "Screen Recorder" "Recording stopped"
        ;;

    $option_3)
        pkill -INT wf-recorder
        notify-send "Screen Recorder" "Recording stopped"
        ;;

    $option_4)
        ghostty -e yazi "$dir"
        ;;
esac
