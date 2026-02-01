#!/usr/bin/bash

scripts_dir="$HOME/.config/rofi/applets/bin"
themes_dir="$HOME/.config/rofi/launchers/type-1"
dmenu_theme="$themes_dir/dmenu.rasi"
text_input_theme="$themes_dir/text-input.rasi"

# ---- Define your records here ----
# Format: "Label:::command"
records=(
    "Calculator:::rofi -modi calc -show calc -theme \"$dmenu_theme\""
    "Edit dotfiles:::ghostty -e zsh -c \"cd ~/code/projects/dotfiles && nvim\""
    "Unicode Characters:::$scripts_dir/characters.sh"
    "Toggle Light Mode:::hyprshade toggle invert"
    "Toggle Reader Mode:::hyprshade toggle blue-light-filter"
    "Toggle Vibrant Mode:::hyprshade toggle vibrance"
    "Timer:::rofi -show timer -modi timer:$scripts_dir/timer.sh -theme \"$dmenu_theme\""
    "Quick Notes:::$scripts_dir/notes.sh"
)

# ---- Build the menu from labels ----
labels=()
for r in "${records[@]}"; do
    labels+=( "${r%%:::*}" )
done

choice=$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i -p "Run" -theme "$dmenu_theme")

[[ -z "${choice:-}" ]] && exit 0

# ---- Find and run the matching command ----
for r in "${records[@]}"; do
    label="${r%%:::*}"
    cmd="${r#*:::}"
    if [[ "$label" == "$choice" ]]; then
        eval "$cmd" &
        exit 0
    fi
done
