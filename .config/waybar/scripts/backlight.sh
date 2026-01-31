#!/usr/bin/env bash
#
# Adjust screen brightness and send a notification with the current level
#
# Requirements:
# 	brightnessctl
# 	notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 28, 2025
# License: MIT

usage() {
    cat <<- EOF
		USAGE: ${0##*/} [OPTIONS]

		Adjust screen brightness and send a notification with the current level

		OPTIONS:
		    up                  Increase brightness
		    down                Decrease brightness

		EXAMPLES:
		    Increase brightness:
		        $ ${0##*/} up

		    Decrease brightness:
		        $ ${0##*/} down
	EOF
    exit 1
}

main() {
    local action=$1

    case $action in
        "up" | "down")
            case $action in
                "up") swayosd-client --brightness raise > /dev/null ;;
                "down") swayosd-client --brightness lower > /dev/null ;;
            esac

            local level
            level=$(brightnessctl -m | awk -F "," '{print $4}')

            ;;
        *) usage ;;
    esac
}

main "$@"
