#!/bin/bash
#
# https://github.com/claudiodangelis/rofi-todo
#
# this script manages a simple to-do list stored locally
# it allows adding and removing to-do entries
#
# dependencies: rofi

TODO_FILE="${TODO_FILE:-$HOME/.todos}"

todo_help="Type something with a \"+\" prefix and press <b>Enter</b> to add a new item"

if [[ ! -a "${TODO_FILE}" ]]; then
    touch "${TODO_FILE}"
fi

ROFI_DATA_DIR="$HOME/notes"
COUNTER_FILE="$ROFI_DATA_DIR/.unpushed-commits"

# initialize counter on script start
if [[ ! -f "$COUNTER_FILE" ]]; then
    echo 0 > "$COUNTER_FILE"
fi

unpushed_commits=$(cat "$COUNTER_FILE")

git_commit() {
    (
        cd "$ROFI_DATA_DIR" || exit 1

        git add "$1" >/dev/null 2>&1
        git commit -m "$2" >/dev/null 2>&1

        count=$(cat "$COUNTER_FILE")
        count=$((count + 1))
        echo "$count" > "$COUNTER_FILE"

        if [[ "$count" -ge 5 ]]; then
            git push >/dev/null 2>&1
            echo 0 > "$COUNTER_FILE"
        fi
    )
}

function add_todo() {
    echo "$(date '+%d %b %Y') $*" >> "${TODO_FILE}"
    git_commit "${TODO_FILE}" "Add todo: ${TODO_FILE}"
}

toggle_todo() {
    local clicked="$*"

    # remove rofi markup if present
    local clean
    clean="$(echo "$clicked" | sed -E 's|^<s>(.*)</s>$|\1|')"

    if grep -Fxq "<s>${clean}</s>" "$TODO_FILE"; then
        # currently done -> unmark
        sed -i "s|^<s>${clean}</s>$|${clean}|" "$TODO_FILE"
    elif grep -Fxq "${clean}" "$TODO_FILE"; then
        # currently not done -> mark
        sed -i "s|^${clean}$|<s>${clean}</s>|" "$TODO_FILE"
    fi

    git_commit "${TODO_FILE}" "Toggle todo: ${clean}"
}

function get_todos() {
    echo -en "\0markup-rows\x1ftrue\n"
    echo -en "\0message\x1f$todo_help\n"
    echo "$(cat "${TODO_FILE}" | sort)"
}

if [[ -z "$*" ]]; then
    get_todos
else
    line="$*"

    if [[ "$line" == +* ]]; then
        line="${line#+}"
        line="$(echo "$line" | sed 's/^[[:space:]]*//')"
        add_todo "$line"
    else
        toggle_todo "$line"
    fi

    get_todos
fi
