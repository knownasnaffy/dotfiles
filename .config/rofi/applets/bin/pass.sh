#!/bin/bash

shopt -s nullglob globstar

# Rofi styles
dir="$HOME/.config/rofi/launchers/type-1"
theme='dmenu'

if [[ -z $WAYLAND_DISPLAY && -z $DISPLAY ]]; then
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

ok=' OK'

feedback() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 1; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg "$1" \
        -theme $HOME/.config/rofi/applets/type-1/style-2.rasi

}

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

password=$(printf '%s\n' "${password_files[@]}" | rofi \
        -dmenu \
        -theme ${dir}/${theme}.rasi \
        -kb-custom-1 'Alt+a' \
        -kb-custom-2 'Alt+o' \
        -kb-custom-3 'Alt+e' \
        -kb-custom-4 'Alt+D' \
        -kb-custom-5 'Alt+g' \
    "$@")

case $? in
    0)
        [[ -n $password ]] || exit 0
        if pass otp -c "$password" 2>/dev/null; then
            :
        else
            pass show -c "$password" 2>/dev/null
        fi
        ;;
    10)
        service=$(rofi -dmenu -theme ${dir}/text-input.rasi -theme-str '
		entry {
		    placeholder: "Enter service name...";
		}
	')
        [[ -n $service ]] || exit 0
        account=$(rofi -dmenu -theme ${dir}/dmenu.rasi)
        [[ -n $service ]] || exit 0
        password=$(rofi -dmenu -theme ${dir}/text-input.rasi -theme-str '
		entry {
		    placeholder: "Enter the password...";
		}
		textbox-prompt-colon {
		    str: " ";
		}
	')
        [[ -n $password ]] || exit 0

        (echo "$password" | pass insert -m $service) && (echo "$ok" | feedback "Password successfully added to $label")
        ;;
    11)
        echo -e "$ok" | feedback "Add otp not implemented yet"
        ;;
    12)
        echo -e "$ok" | feedback "Edit password not implemented yet"
        ;;
    13)
        echo -e "$ok" | feedback "Delete password not implemented yet"
        ;;
    14)
        echo -e "$ok" | feedback "Generate password not implemented yet"
        ;;
esac
