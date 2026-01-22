#!/bin/bash

# Rofi styles
dir="$HOME/.config/rofi/launchers/type-1"
theme='dmenu'

INTERFACE="wlan0"
CACHE=/tmp/iwd_last_scan       # file stores Unix epoch of last scan
COOLDOWN=15                    # seconds between scans

now=$(date +%s)
last=0 && [[ -f $CACHE ]] && read -r last <"$CACHE"
delta=$(( now - last ))

if (( delta >= COOLDOWN )); then
    iwctl station "$INTERFACE" scan 2>/dev/null || true
    sleep 1
    echo "$now" >"$CACHE"
fi

# Scan and get network SSIDs
NETWORKS=$(iwctl station "$INTERFACE" get-networks | sed 's/\x1b\[[0-9;]*m//g' | tail -n +5 | head -n -1 | rev | cut -c9- | rev
)

# Show networks in rofi
SSID=$(echo "$NETWORKS" | rofi \
        -dmenu \
        -p "Connect to WiFi" \
    -theme ${dir}/${theme}.rasi | awk '{
        if ($1 == ">")
                printf "> %s\n", $2;
        else
                printf "- %s\n", $1;
}')

    [ -z "$SSID" ] && exit 1

    if [[ "$SSID" == "> "* ]]; then
        yes=' Yes'
        no=' No'

        selected=$(
            echo -e "$no\n$yes" | rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
                -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
                -theme-str 'listview {columns: 2; lines: 1;}' \
                -theme-str 'element-text {horizontal-align: 0.5;}' \
                -theme-str 'textbox {horizontal-align: 0.5;}' \
                -dmenu \
                -p 'Confirmation' \
                -mesg 'Disconnect?' \
                -theme $HOME/.config/rofi/applets/type-1/style-2.rasi
        )
        if [[ $selected == $yes ]]; then
            iwctl station $INTERFACE disconnect
            echo "Disconnected"
            exit 0
        else
            echo "Not disconnecting"
            exit 0
        fi
    fi

    if iwctl known-networks list | sed 's/\x1b\[[0-9;]*m//g' | awk '{ print ($1 == ">" ? $2 : $1) }' | grep -Fxq "$( echo $SSID  | cut -c3- | awk '{print $1}')"; then
        iwctl station $INTERFACE connect $(echo $SSID | cut -c3- | awk '{print $1}')
    else
        echo "Unrecognized: $(echo $SSID | cut -c3- | awk '{print $1}')"
        PASS=$(rofi -dmenu -p "Password for $(echo $SSID | cut -c3- | awk '{print $1}')" -password -theme ${dir}/password.rasi)
        iwctl --passphrase="$PASS" station "$INTERFACE" connect "$(echo $SSID | cut -c3- | awk '{print $1}')"
    fi
