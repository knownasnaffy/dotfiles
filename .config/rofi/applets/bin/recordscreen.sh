#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/style-4.rasi"

echo $theme
# Theme Elements
prompt='Record Screen'
mesg="DIR: ~/Videos/Screen Recordings"

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
layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
    option_1=" Record Desktop"
    option_2=" Record Area"
    option_3=" Stop Recording"
    # option_3=" Capture Area and Edit"
    # option_4=" Capture in 5s"
    # option_5=" Capture in 10s"
else
    option_1=""
    option_2=""
    option_3=""
    # option_4=""
    # option_5=""
fi

# Rofi CMD
rofi_cmd() {
    rofi -theme-str "window {width: $win_width;}" \
        -theme-str "listview {columns: $list_col; lines: 3;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -dmenu \
        -p "$prompt" \
        -markup-rows \
        -mesg "$mesg" \
        -theme "$theme"
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3" | rofi_cmd
}

# Screenshot variables
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(xrandr | grep 'current' | awk '{print $8 "x" $10}' | tr -d ',')
dir="~/Videos/Screen Recordings"
file="Recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"

mkdir -p "$dir"  # Ensure directory exists

# Screenshot functions
shotnow() {
    sleep 0.5 && wf-recorder -f "$dir/$file" --audio
}

# shot5() {
#     sleep 5 && grim - | tee ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy
# }
#
# shot10() {
#     sleep 10 && grim - | tee ~/Pictures/Screenshots/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy
# }
#
# shot_area_edit() {
#     sleep 0.5 && wf-recorder -f $dir/$file --audio
# }

shotarea() {
    sleep 0.5 && wf-recorder -g "$(slurp)" -f "$dir/$file" --audio
}

stoprecording() {
    pkill -INT wf-recorder
}

# Execute Command
run_cmd() {
    case "$1" in
        '--opt1') shotnow ;;
        '--opt2') shotarea ;;
        '--opt3') stoprecording ;;
            # '--opt4') shot5 ;;
            # '--opt5') shot10 ;;
    esac
}

# Actions
chosen="$(run_rofi)"
case "$chosen" in
    $option_1) run_cmd --opt1 ;;
    $option_2) run_cmd --opt2 ;;
    $option_3) run_cmd --opt3 ;;
        # $option_4) run_cmd --opt4 ;;
        # $option_5) run_cmd --opt5 ;;
esac
