#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/$style"

# Theme Elements
prompt='Screenshot'
mesg="DIR: ~/Pictures/Screenshots"

if [[ "$theme" == *'type-1'* ]]; then
    list_col='1'
    list_row='6'
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
layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
    option_1=" Capture Desktop"
    option_2=" Capture Area"
    option_3=" Capture Area and Edit"
    option_4=" Capture in 5s"
    option_5=" Capture in 10s"
    option_6=" Open Screenshots Folder"
else
    option_1=""
    option_2=""
    option_3=""
    option_4=""
    option_5=""
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

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Screenshot variables
time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir PICTURES)/Screenshots"

mkdir -p "$dir"  # Ensure directory exists

# Screenshot functions
shotnow() {
    sleep 0.5 && grim - | tee ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy
}

shot5() {
    sleep 5 && grim - | tee ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy
}

shot10() {
    sleep 10 && grim - | tee ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy
}

shot_area_edit() {
    grim -g "$(slurp)" - | swappy -f - -o ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png
}

shotarea() {
    grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy
}

# Execute Command
run_cmd() {
    case "$1" in
        '--opt1') shotnow ;;
        '--opt2') shotarea ;;
        '--opt3') shot_area_edit ;;
        '--opt4') shot5 ;;
        '--opt5') shot10 ;;
    esac
}

# Actions
chosen="$(run_rofi)"
case "$chosen" in
    $option_1) run_cmd --opt1 ;;
    $option_2) run_cmd --opt2 ;;
    $option_3) run_cmd --opt3 ;;
    $option_4) run_cmd --opt4 ;;
    $option_5) run_cmd --opt5 ;;
    $option_6) ghostty -e yazi "$dir" ;;
esac
