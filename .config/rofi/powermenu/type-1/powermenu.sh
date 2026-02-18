#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-1"
theme='style-1'

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostnamectl hostname`

# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
logout=' Logout'
yes=' Yes'
no=' No'

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "$host" \
        -mesg "Uptime: $uptime" \
        -theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$shutdown\n$reboot\n$logout\n$lock" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprhalt --text "Shutting Down" --post-cmd 'systemctl poweroff' || systemctl poweroff
        elif [[ $1 == '--reboot' ]]; then
            [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprhalt --text "Restarting" --post-cmd 'systemctl reboot' || systemctl reboot
        elif [[ $1 == '--logout' ]]; then
            [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprhalt --vt 2 || i3-msg exit
        fi
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $lock)
        [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprlock || sleep 0.5 && $HOME/.config/i3/lock.sh
        ;;
    $logout)
        run_cmd --logout
        ;;
esac
