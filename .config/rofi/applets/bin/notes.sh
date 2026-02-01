#!/bin/bash
#
# https://github.com/christianholman/rofi_notes
#
# this script allows writing and reading simple notes that are stored locally
#
# dependencies: rofi
#
# Thanks rofi-desktop


themes_dir="$HOME/.config/rofi/launchers/type-1"
dmenu_theme="$themes_dir/dmenu.rasi"
text_input_theme="$themes_dir/text-input.rasi"

rofi_dmenu() {
    rofi -dmenu -theme "$dmenu_theme" $@
}

rofi_title_input() {
    rofi -dmenu -theme "$text_input_theme" -theme-str "entry { placeholder: \"Enter title...\"; }" $@
}

rofi_confirm() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -mesg "$1" \
        -theme $HOME/.config/rofi/applets/type-1/style-2.rasi
}

generate_placeholder_string() {
    echo "entry { placeholder: \"$1\"; }"
}

ROFI_DATA_DIR="$HOME/notes"
NOTES_AUTHOR="Barinderpreet Singh"
NOTES_EDITOR="ghostty -e nvim"

notes_folder="$ROFI_DATA_DIR/quick"

if [[ ! -d "${notes_folder}" ]]; then
    mkdir -p "$notes_folder"
fi

get_notes() {
    ls "${notes_folder}"
}

edit_note() {
    note_location=$1
    $NOTES_EDITOR "$note_location"
}

delete_note() {
    local note=$1
    local action=$(echo -e "Yes\nNo" | rofi_confirm "Are you sure you want to delete $note? ")

    case $action in
        "Yes")
            rm "$notes_folder/$note"
            cd $ROFI_DATA_DIR && git add ./quick && git commit -m "Delete quick note: $note"
            main
            ;;
        "No")
            main
    esac
}

note_context() {
    local note=$1
    local note_location="$notes_folder/$note"
    local action=$(echo -e "Edit\nDelete" | rofi_confirm "$note")
    case $action in
        "Edit")
            edit_note "$note_location"
            cd $ROFI_DATA_DIR && git add ./quick && git commit -m "Edit quick note: $note"
            exit 0 ;;
        "Delete")
            delete_note "$note"
            exit 0 ;;
    esac

    exit 0
}

new_note() {
    local title=$(rofi_title_input)

    rc=$?

    [[ $rc -eq 1 ]] && (main; exit 0)
    [[ -n $title ]] || (main; exit 0)

    case "$title" in
        "Cancel")
            main
            exit 0
            ;;
        *)
            local file=$(echo "$title" | sed 's/ /_/g;s/\(.*\)/\L\1/g')
            local template=$(cat <<- END
---
title: $title
date: $(date --rfc-3339=seconds)
author: $NOTES_AUTHOR
---

# $title
END
            )

            note_location="$notes_folder/$file.md"
            if [ "$title" != "" ]; then
                echo "$template" > "$note_location" | edit_note "$note_location"
                cd $ROFI_DATA_DIR && git add ./quick && git commit -m "Add quick note: $file.md"
                exit 0
            fi
            ;;
    esac
}

main()
{
    local all_notes="$(get_notes)"
    local first_menu="New Note"

    if [ "$all_notes" ];then
        first_menu="New Note\n${all_notes}"
    fi

    local note=$(echo -e "$first_menu"  | rofi_dmenu -i -p "Notes")

    case $note in
        "New Note")
            new_note
            ;;
        "")
            exit 0 ;;
        *)
            note_context "$note" && exit 0 # handle esc key in note_context
    esac

    exit 0
}


main
