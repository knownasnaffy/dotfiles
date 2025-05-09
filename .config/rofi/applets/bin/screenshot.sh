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
	option_1=" Capture Desktop"
	option_2=" Capture Area"
	option_3=" Capture Window"
	option_4=" Capture in 5s"
	option_5=" Capture in 10s"
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
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Screenshot variables
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(xrandr | grep 'current' | awk '{print $8 "x" $10}' | tr -d ',')
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

mkdir -p "$dir"  # Ensure directory exists

# Notify and copy screenshot
notify_view() {
	dunstify -u low --replace=699 "Screenshot saved and copied to clipboard."
}

# Copy screenshot to clipboard
copy_shot() {
	tee "$dir/$file" | xclip -selection clipboard -t image/png
	notify_view
}

# Countdown function
countdown() {
	for sec in $(seq "$1" -1 1); do
		dunstify -t 1000 --replace=699 "Taking shot in: $sec"
		sleep 1
	done
}

# Screenshot functions
shotnow() {
	cd "$dir" && sleep 0.5 && maim -u -f png | copy_shot
}

shot5() {
	countdown '5'
	sleep 1 && cd "$dir" && maim -u -f png | copy_shot
}

shot10() {
	countdown '10'
	sleep 1 && cd "$dir" && maim -u -f png | copy_shot
}

shotwin() {
	cd "$dir" && maim -u -f png -i "$(xdotool getactivewindow)" | copy_shot
}

shotarea() {
	cd "$dir" && maim -u -f png -s -b 2 -c 0.35,0.55,0.85,0.25 -l | copy_shot
}

# Execute Command
run_cmd() {
	case "$1" in
		'--opt1') shotnow ;;
		'--opt2') shotarea ;;
		'--opt3') shotwin ;;
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
esac
