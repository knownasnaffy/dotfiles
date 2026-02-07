#!/usr/bin/env bash

# --------------------------------------------------
# Config
# --------------------------------------------------

SCREENSHOT_DIR="$(xdg-user-dir PICTURES)/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Rofi theme
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/$style"

prompt="Screenshot"
mesg="DIR: ~/Pictures/Screenshots"

# --------------------------------------------------
# Options
# --------------------------------------------------

option_1=" Capture Screenshot"
option_2=" Capture and Edit"
option_3=" Capture in 5s"
option_4=" Open Screenshots Folder"

# --------------------------------------------------
# Rofi
# --------------------------------------------------

rofi_cmd() {
    rofi \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -theme-str "listview {columns: 1; lines: 4;}" \
        -theme "$theme"
}

chosen="$(printf "%s\n%s\n%s\n" \
    "$option_1" \
    "$option_2" \
    "$option_3" \
    "$option_4" | rofi_cmd)"

# --------------------------------------------------
# Actions
# --------------------------------------------------

case "$chosen" in
    "$option_1")
        sleep 0.2; hyprquickframe
        ;;
    "$option_2")
        sleep 0.2; hyprquickframe -e
        ;;
    "$option_3")
        sleep 5; hyprquickframe
        ;;
    "$option_4")
        ghostty -e yazi "$SCREENSHOT_DIR"
        ;;
esac
