#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/$style"

# Theme Elements
prompt='Pick Colors'
mesg="Choose the format to pick in"

if [[ "$theme" == *'type-1'* ]]; then
    list_col='1'
    list_row='5'
    win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
    list_col='1'
    list_row='5'
    win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
    list_col='1'
    list_row='5'
    win_width='520px'
elif [[ "$theme" == *'type-2'* || "$theme" == *'type-4'* ]]; then
    list_col='5'
    list_row='1'
    win_width='670px'
fi

# Options
option_1=" RGB"
option_2=" HSL"
option_3=" HEX"
option_4=" CMYK"
option_5=" HSV"

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

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Actions
chosen="$(run_rofi)"
case "$chosen" in
    $option_1) sleep 0.2 && hyprpicker --autocopy --format=rgb ;;
    $option_2) sleep 0.2 && hyprpicker --autocopy --format=hsl ;;
    $option_3) sleep 0.2 && hyprpicker --autocopy --format=hex ;;
    $option_4) sleep 0.2 && hyprpicker --autocopy --format=cmyk ;;
    $option_5) sleep 0.2 && hyprpicker --autocopy --format=hsv ;;
esac
