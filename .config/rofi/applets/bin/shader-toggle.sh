#!/usr/bin/bash

themes_dir="$HOME/.config/rofi/launchers/type-1"
dmenu_theme="$themes_dir/dmenu.rasi"

# ---- Define label:::command pairs ----
records=(
    "Invert Colors:::hyprshade toggle invert"
    "Blue Light:::hyprshade toggle blue-light-filter"
    "Vibrance:::hyprshade toggle vibrance"
    "Retro:::hyprshade toggle retro"
)

while true; do
    current_shader=$(hyprshade current 2>/dev/null)

    # Build label list with indicator
    labels=()
    for r in "${records[@]}"; do
        label="${r%%:::*}"
        shader_name=$(echo "$r" | awk -F'toggle ' '{print $2}')

        if [[ "$shader_name" == "$current_shader" ]]; then
            labels+=( "󰄬 $label" )
        else
            labels+=( "  $label" )
        fi
    done

    choice=$(printf '%s\n' "${labels[@]}" | rofi -dmenu -p "Shaders" -theme "$dmenu_theme")
    rc=$?

    [[ $rc -eq 1 || -z "${choice:-}" ]] && exit 0

    # Strip indicator before matching
    clean_choice=$(echo "$choice" | sed 's/^..//')

    for r in "${records[@]}"; do
        label="${r%%:::*}"
        cmd="${r#*:::}"
        if [[ "$label" == "$clean_choice" ]]; then
            eval "$cmd"
            break
        fi
    done
done
