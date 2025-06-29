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
    i3-msg exit
fi
