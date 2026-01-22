#!/bin/bash

shopt -s nullglob globstar

# Rofi styles
dir="$HOME/.config/rofi/launchers/type-1"
theme='dmenu'

if [[ -z $WAYLAND_DISPLAY && -z $DISPLAY ]]; then
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

password=$(printf '%s\n' "${password_files[@]}" | rofi \
        -dmenu \
        -theme ${dir}/${theme}.rasi \
    "$@")

[[ -n $password ]] || exit 0

if [[ $password == otp/* ]]; then
    pass otp -c "$password" 2>/dev/null
else
    pass show -c "$password" 2>/dev/null
fi
