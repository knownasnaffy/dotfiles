#!/usr/bin/bash

scripts_dir="$HOME/.config/rofi/applets/bin"
themes_dir="$HOME/.config/rofi/launchers/type-1"
dmenu_theme="$themes_dir/dmenu.rasi"

keycode() {
    case "$1" in
        CTRL) echo 29 ;;
        SHIFT) echo 42 ;;
        ALT) echo 56 ;;
        SUPER) echo 125 ;;

        A) echo 30 ;;
        J) echo 36 ;;
        L) echo 38 ;;
        K) echo 37 ;;
        T) echo 20 ;;

        F13) echo 183 ;;
        F14) echo 184 ;;
        F15) echo 185 ;;
        F16) echo 186 ;;
        F17) echo 187 ;;
        F18) echo 188 ;;
        F19) echo 189 ;;
        F20) echo 190 ;;
        F21) echo 191 ;;
        F22) echo 192 ;;
        F23) echo 193 ;;
        F24) echo 194 ;;

        *) echo "Unknown key: $1" >&2; exit 1 ;;
    esac
}

press_combo() {
    IFS='+' read -ra keys <<< "$1"
    codes=()

    for k in "${keys[@]}"; do
        codes+=( "$(keycode "$k")" )
    done

    # press
    for c in "${codes[@]}"; do
        ydotool key "$c:1"
    done

    # release reverse
    for (( i=${#codes[@]}-1; i>=0; i-- )); do
        ydotool key "${codes[$i]}:0"
    done
}

# -----------------------------
# Detect focused window (Hyprland)
# -----------------------------
focused_class="$(hyprctl activewindow -j | jq -r '.class // empty')"
focussed_addr="$(hyprctl activewindow -j | jq -r '.address')"

# -----------------------------
# Context actions (per app)
# -----------------------------
context_records=()

case "$focused_class" in
    com.mitchellh.ghostty)
        context_records+=(
            "Ghostty: Previous Prompt:::press_combo CTRL+SHIFT+L"
            "Ghostty: Next Prompt:::press_combo CTRL+SHIFT+K"
            "Ghostty: Screenshot → text file:::press_combo SUPER+CTRL+SHIFT+J"
            "Ghostty: Select all:::press_combo CTRL+SHIFT+A"
        )
        ;;

    qutebrowser)
        context_records+=(
            "Qutebrowser: Open Downloads:::ghostty -e yazi ~/Downloads"
            "Qutebrowser: Duplicate Tab:::qutebrowser :tab-clone"
            "Qutebrowser: Toggle Tabs:::qutebrowser ':config-cycle tabs.show always never'"
            "Qutebrowser: Toggle Status Bar:::qutebrowser ':config-cycle statusbar.show always never'"
            "Qutebrowser: Toggle Images:::qutebrowser ':config-cycle content.images true false'"
        )
        ;;
esac

# Add a visual divider if context actions exist
if [[ ${#context_records[@]} -gt 0 ]]; then
    context_records+=("──────────:::true")
fi

# -----------------------------
# Global records (your originals)
# -----------------------------
records=(
    "Calculator:::rofi -modi calc -show calc -theme \"$dmenu_theme\""
    "Edit dotfiles:::ghostty -e zsh -c \"cd ~/code/projects/dotfiles && nvim\""
    "Unicode Characters:::$scripts_dir/characters.sh"
    "Toggle Shaders:::$scripts_dir/shader-toggle.sh"
    "Timer:::rofi -show timer -modi timer:$scripts_dir/timer.sh -theme \"$dmenu_theme\""
    "Quick Notes:::$scripts_dir/notes.sh"
    "Todo List:::$scripts_dir/todo.sh"
    "Screen Ruler:::notify-send \"Point, Dimensions: \$(~/.local/bin/slurp)\""
    "Pin Window:::~/.config/hypr/scripts/pin-window.sh $focussed_addr"
    "Resize Window:::hyprctl dispatch submap resize"
)

# -----------------------------
# Merge context + global
# -----------------------------
all_records=( "${context_records[@]}" "${records[@]}" )

# -----------------------------
# Build menu
# -----------------------------
labels=()
for r in "${all_records[@]}"; do
    labels+=( "${r%%:::*}" )
done

choice=$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i -p "Run" -theme "$dmenu_theme")
[[ -z "${choice:-}" ]] && exit 0

# -----------------------------
# Execute selection
# -----------------------------
for r in "${all_records[@]}"; do
    label="${r%%:::*}"
    cmd="${r#*:::}"
    if [[ "$label" == "$choice" ]]; then
        eval "$cmd" &
        exit 0
    fi
done
