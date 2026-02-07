#!/bin/bash

shopt -s nullglob globstar

set -o nounset

# Rofi styles
dir="$HOME/.config/rofi/launchers/type-1"

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
        -mesg "$1" \
        -theme $HOME/.config/rofi/applets/type-1/style-2.rasi

}

generate_placeholder_string() {
    echo "entry { placeholder: \"$1\"; }"
}

generate_placeholder_icon() {
    echo "textbox-prompt-colon { str: \"$1 \"; }"
}

fallback_message=""

fallback() {
    notify-send -a "password-manager" "$fallback_message"
}

type_secret() {
    local secret="$1"

    sleep 0.4

    # type like a real keyboard
    ydotool type "$secret"
}

get_password() {
    pass show "$1" | head -n1
}

get_otp() {
    pass otp "$1" 2>/dev/null
}

# Load emails
emails=()
if [[ -f "$HOME/.private_env" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.private_env"
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

password=$(printf '%s\n' "${password_files[@]}" | rofi \
        -dmenu \
        -no-custom \
        -theme ${dir}/dmenu.rasi \
        -kb-custom-1 'Alt+a' \
        -kb-custom-2 'Alt+o' \
        -kb-custom-3 'Alt+e' \
        -kb-custom-4 'Alt+D' \
        -kb-custom-5 'Alt+g' \
    "$@")

case $? in
    0)
        [[ -n $password ]] || exit 0

        fallback_message="Password not typed"

        otp=$(get_otp "$password")

        if [[ -n "$otp" ]]; then
            type_secret "$otp"
            notify-send -a "password-manager" "OTP typed"
        else
            pw=$(get_password "$password")
            type_secret "$pw"
            notify-send -a "password-manager" "Password typed"
        fi
        ;;
    10)
        fallback_message="No password created"

        service=$(rofi -dmenu -theme ${dir}/text-input.rasi \
                -theme-str "$(generate_placeholder_string "Enter service name...")"
        )
        [[ -n $service ]] || (fallback && exit 0)

        account=$(printf '%s\n' "${emails[@]}" | rofi -dmenu -theme ${dir}/dmenu.rasi -kb-custom-1 "Alt+Return" )
        rc=$?

        [[ $rc -eq 1 ]] && fallback && exit 0

        if [[ $rc -eq 10 ]]; then
            account=$(rofi -dmenu -theme ${dir}/text-input.rasi \
                    -theme-str "$(generate_placeholder_string "Enter account name...")"
            )
            [[ -z "$account" ]] && fallback && exit 0
        fi


        password=$(rofi -dmenu -theme ${dir}/text-input.rasi \
                -theme-str "$(generate_placeholder_string "Enter password name...")" \
                -theme-str "$(generate_placeholder_icon "")"
        )
        [[ -n $password ]] || (fallback && exit 0)

        (echo "$password" | pass insert -m "$service") && (echo "$ok" | notify-send -a "password-manager" "Password successfully added for $service")
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
