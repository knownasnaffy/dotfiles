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

ROFI_DATA_DIR="$HOME/notes"
NOTES_AUTHOR="Barinderpreet Singh"
NOTES_EDITOR="ghostty -e nvim"

COUNTER_FILE="$ROFI_DATA_DIR/.unpushed-commits"

# initialize counter on script start
if [[ ! -f "$COUNTER_FILE" ]]; then
    echo 0 > "$COUNTER_FILE"
fi

unpushed_commits=$(cat "$COUNTER_FILE")

git_commit() {
    (
        cd "$ROFI_DATA_DIR" || exit 1
        git add ./quick
        git commit -m "$1"

        # increment counter
        count=$(cat "$COUNTER_FILE")
        count=$((count + 1))
        echo "$count" > "$COUNTER_FILE"

        # push after 5 commits
        if [[ "$count" -ge 5 ]]; then
            git push
            echo 0 > "$COUNTER_FILE"
        fi
    )
}

notes_folder="$ROFI_DATA_DIR/quick"

if [[ ! -d "${notes_folder}" ]]; then
    mkdir -p "$notes_folder"
fi

get_notes() {
    find "$notes_folder" -maxdepth 1 -type f -printf '%f\n' | sort
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
            git_commit "Delete quick note: $note"
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
            git_commit "Edit quick note: $note"
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
            local file=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_')
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
                echo "$template" > "$note_location"; edit_note "$note_location"
                git_commit "Add quick note: $file.md"
                exit 0
            fi
            ;;
    esac
}

main() {
    mapfile -t notes < <(get_notes)

    menu=("New Note" "${notes[@]}")

    note=$(printf '%s\n' "${menu[@]}" | rofi_dmenu -i -p "Notes")

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
