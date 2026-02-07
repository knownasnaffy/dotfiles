#!/usr/bin/env bash
# Author   : adapted from Aditya Shakya (adi1090x)
# Purpose  : Control spotifyd via playerctl from a Rofi menu
# Requires : playerctl, notify-send, rofi

# ------------------------------------------------------------
# 1.  Theme / layout handling (unchanged)
# ------------------------------------------------------------
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

if [[ $theme == *'type-1'* || $theme == *'type-3'* || $theme == *'type-5'* ]]; then
    list_col='1'; list_row='6'
else
    list_col='6'; list_row='1'
fi

layout=$(grep 'USE_ICON' <"$theme" | cut -d'=' -f2)

# ------------------------------------------------------------
# 2.  Gather spotifyd status via playerctl
# ------------------------------------------------------------
PLAYER="spotifyd"
status=$(playerctl -p "$PLAYER" status 2>/dev/null)      # Playing | Paused | Stopped
artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)

if [[ -z $status ]]; then
    prompt='Offline'
    mesg='spotifyd is Offline'
else
    prompt="$artist"
    mesg="$title :: $status"
fi

# Loop / shuffle state for highlighting
loop_state=$(playerctl -p "$PLAYER" loop 2>/dev/null)        # None | Track | Playlist :contentReference[oaicite:0]{index=0}
shuffle_state=$(playerctl -p "$PLAYER" shuffle 2>/dev/null)  # On | Off | Toggle :contentReference[oaicite:1]{index=1}

# ------------------------------------------------------------
# 3.  Menu options (icons unchanged)
# ------------------------------------------------------------
if [[ $layout == 'NO' ]]; then
    [[ $status == 'Playing' ]] && option_1=" Pause"  || option_1=" Play"
    option_2=" Stop"
    option_3=" Previous"
    option_4=" Next"
    option_5=" Repeat"
    option_6=" Shuffle"
else
    [[ $status == 'Playing' ]] && option_1="" || option_1=""
    option_2=""
    option_3=""
    option_4=""
    option_5=""
    option_6=""
fi

# ------------------------------------------------------------
# 4.  Highlight active / urgent toggles
# ------------------------------------------------------------
active=''; urgent=''

# Repeat (loop)
case "$loop_state" in
    Playlist|Track) active="-a 4" ;;
    None)           urgent="-u 4" ;;
    *)              option_5=" Parsing Error" ;;
esac

# Shuffle
case "$shuffle_state" in
    On)  [[ $active  ]] && active+=",5"  || active="-a 5" ;;
    Off) [[ $urgent ]] && urgent+=",5" || urgent="-u 5" ;;
    *)   option_6=" Parsing Error" ;;
esac

# ------------------------------------------------------------
# 5.  Rofi wrapper
# ------------------------------------------------------------
rofi_cmd() {
    rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        $active $urgent \
        -markup-rows \
        -theme "$theme"
}

run_rofi() {
    printf '%s\n%s\n%s\n%s\n%s\n%s' \
        "$option_1" "$option_2" "$option_3" "$option_4" "$option_5" "$option_6" | rofi_cmd
}

# ------------------------------------------------------------
# 6.  Command handlers
# ------------------------------------------------------------
notify() {
    notify-send -u low -t 1000 " $(playerctl -p "$PLAYER" metadata artist) – $(playerctl -p "$PLAYER" metadata title)"
}

toggle_loop() {
    case $(playerctl -p "$PLAYER" loop) in
        None)      playerctl -p "$PLAYER" loop Playlist ;;
        Playlist|Track) playerctl -p "$PLAYER" loop None ;;
    esac
}

toggle_shuffle() {
    playerctl -p "$PLAYER" shuffle Toggle 2>/dev/null || {
        # Fall back if Toggle not supported
        [[ $(playerctl -p "$PLAYER" shuffle) == 'On' ]] && \
            playerctl -p "$PLAYER" shuffle Off || playerctl -p "$PLAYER" shuffle On
    }
}

run_cmd() {
    case "$1" in
        --opt1) playerctl -p "$PLAYER" play-pause && notify ;;
        --opt2) playerctl -p "$PLAYER" stop ;;
        --opt3) playerctl -p "$PLAYER" previous && notify ;;
        --opt4) playerctl -p "$PLAYER" next && notify ;;
        --opt5) toggle_loop ;;
        --opt6) toggle_shuffle ;;
    esac
}

# ------------------------------------------------------------
# 7.  Main
# ------------------------------------------------------------
chosen=$(run_rofi)
case "$chosen" in
    "$option_1") run_cmd --opt1 ;;
    "$option_2") run_cmd --opt2 ;;
    "$option_3") run_cmd --opt3 ;;
    "$option_4") run_cmd --opt4 ;;
    "$option_5") run_cmd --opt5 ;;
    "$option_6") run_cmd --opt6 ;;
esac
