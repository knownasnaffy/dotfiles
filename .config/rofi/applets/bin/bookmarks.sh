#!/usr/bin/env bash

BOOKMARKS="$HOME/.local/share/bookmarks.json"
dir="$HOME/.config/rofi/launchers/type-1"

ok=' OK'

# TODO: Add a check for bookmark file, use touch if file doesn't exist, mkdir if folder doesn't

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

placeholder() {
    echo "entry { placeholder: \"$1\"; }"
}

fetch_meta() {
    html=$(curl -Ls "$1" || true)
    title=$(echo "$html" | grep -iPo '(?<=<title>)(.*?)(?=</title>)' | head -n1)
    desc=$(echo "$html" | grep -iPo '<meta name="description" content="\K[^"]+' | head -n1)
    printf '%s|||%s' "$title" "$desc"
}

list_titles() {
    jq -r '.[] | .title' "$BOOKMARKS"
}

get_url_by_title() {
    jq -r --arg t "$1" '.[] | select(.title==$t) | .url' "$BOOKMARKS"
}

add_bookmark() {
    url=$(rofi -dmenu -theme ${dir}/text-input.rasi \
        -theme-str "$(placeholder "Enter URL...")")
    [[ -z "$url" ]] && exit 0

    meta=$(fetch_meta "$url")
    title=${meta%%|||*}
    desc=${meta##*|||}

    [[ -z "$title" ]] && title="$url"

    jq --arg url "$url" \
        --arg title "$title" \
        --arg desc "$desc" \
    '. += [{
         id: (now|tostring),
         url: $url,
         title: $title,
         description: $desc
       }]' "$BOOKMARKS" > "$BOOKMARKS.tmp" && mv "$BOOKMARKS.tmp" "$BOOKMARKS"

    echo "$ok" | feedback "Bookmark added"
}

delete_bookmark() {
    choice=$(list_titles | rofi -dmenu -theme ${dir}/dmenu.rasi -p "Delete")
    [[ -z "$choice" ]] && exit 0

    jq --arg t "$choice" 'del(.[] | select(.title==$t))' \
        "$BOOKMARKS" > "$BOOKMARKS.tmp" && mv "$BOOKMARKS.tmp" "$BOOKMARKS"

    echo "$ok" | feedback "Deleted"
}

edit_bookmark() {
    choice=$(list_titles | rofi -dmenu -theme ${dir}/dmenu.rasi -p "Refetch metadata")
    [[ -z "$choice" ]] && exit 0

    url=$(get_url_by_title "$choice")
    meta=$(fetch_meta "$url")
    new_title=${meta%%|||*}
    new_desc=${meta##*|||}

    [[ -z "$new_title" ]] && new_title="$url"

    jq --arg old "$choice" \
        --arg nt "$new_title" \
        --arg nd "$new_desc" \
    '(.[] | select(.title==$old)) |=
        (.title=$nt | .description=$nd)' \
        "$BOOKMARKS" > "$BOOKMARKS.tmp" && mv "$BOOKMARKS.tmp" "$BOOKMARKS"

    echo "$ok" | feedback "Metadata refreshed"
}

main_menu() {
    choice=$(list_titles | rofi -dmenu \
            -theme ${dir}/dmenu.rasi \
            -kb-custom-1 'Alt+a' \
            -kb-custom-2 'Alt+e' \
        -kb-custom-3 'Alt+x')

    case $? in
        0)
            [[ -z "$choice" ]] && exit 0
            url=$(get_url_by_title "$choice")
            xdg-open "$url"
            ;;
        10) add_bookmark ;;
        11) edit_bookmark ;;
        12) delete_bookmark ;;
    esac
}

main_menu
