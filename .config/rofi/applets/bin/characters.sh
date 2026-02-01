#!/usr/bin/bash
#
# this script displays unicode characters in a rofi menu
# selecting an entry will copy the character to the clipboard using xdotool (ydotool on wayland)
#
# dependencies: rofi, wtype
#
# Note: ydotool does not work, as it tries to type the key sequence to get the character
# and the characters which are not available on the keyboard layout will cause a failure
#
# Thanks rofi-desktop

ROFI_DATA_DIR="$HOME/.config/rofi/applets/data"
themes_dir="$HOME/.config/rofi/launchers/type-1"
dmenu_theme="$themes_dir/dmenu.rasi"
characters_file="$ROFI_DATA_DIR/unicode.txt"

selected=$(rofi -dmenu -i -p "Characters" -theme "$dmenu_theme" < "$characters_file")

[[ -z "$selected" ]] && exit 1

# Extract first whitespace-separated field (the character)
char=$(awk '{print $1}' <<< "$selected")

sleep 0.35
printf '%s' "$char" | wtype -
