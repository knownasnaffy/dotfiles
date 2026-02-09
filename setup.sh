# ─────────────────────────────────────────────────────────────────────────────
# Core System Variables
# ─────────────────────────────────────────────────────────────────────────────

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
POSTNOTES=""
SKIPPED_SYMLINKS=0

# ─────────────────────────────────────────────────────────────────────────────
# Logging Helpers
# ─────────────────────────────────────────────────────────────────────────────

yellow_text() {
    echo -e "\033[1;33m$1\033[0m"
}

red_text() {
    echo -e "\033[1;31m$1\033[0m"
}

green_text() {
    echo -e "\033[1;32m$1\033[0m"
}

log() {
    echo -e "[$(green_text INFO)] $1"
}

error() {
    echo -e "[$(red_text ERROR)] $1"
}

check_command() {
    command -v "$1" &>/dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
# Symlink Management
# ─────────────────────────────────────────────────────────────────────────────

create_symlink() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" == "$src" ]; then
        ((SKIPPED_SYMLINKS++))
        return
    fi

    if [ -e "$dest" ]; then
        local backup="${dest}.bak"
        local count=1
        while [ -e "$backup" ]; do
            backup="${dest}.bak${count}"
            ((count++))
        done
        log "Backing up existing $dest to $backup"
        mv "$dest" "$backup"
    fi

    ln -s "$src" "$dest"
    log "Symlink created: $dest -> $src"
}

create_sudo_symlink() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" == "$src" ]; then
        ((SKIPPED_SYMLINKS++))
        return
    fi

    if [ -e "$dest" ]; then
        local backup="${dest}.bak"
        local count=1
        while [ -e "$backup" ]; do
            backup="${dest}.bak${count}"
            ((count++))
        done
        log "Backing up existing $dest to $backup"
        sudo mv "$dest" "$backup"
    fi

    sudo ln -s "$src" "$dest"
    log "Symlink created: $dest -> $src"
}

# ─────────────────────────────────────────────────────────────────────────────
# Installation Scripts
# ─────────────────────────────────────────────────────────────────────────────

#  TODO: Pending setups:
#        - ydotool
#        - sddm

setup_network() {
    log "Setting up an internet connection"

    sudo mkdir -p "/etc/systemd/network"

    sudo cp "$DOTFILES_DIR/etc/systemd/network/20-wired.network" "/etc/systemd/network/20-wired.network"
    sudo cp "$DOTFILES_DIR/etc/systemd/network/25-wireless.network" "/etc/systemd/network/25-wireless.network"

    sudo systemctl enable --now systemd-resolved systemd-networkd iwd

    log "Checking network connectivity..."

    # Check wired: any interface with carrier?
    if ip link show | awk '/state UP/ {print $2}' | grep -qE 'enp|eth|eno'; then
        log "Wired interface is up (carrier detected)."
        return 0
    fi

    # Check iwd: any station connected?
    if command -v iwctl >/dev/null 2>&1; then
        if iwctl station list | grep -q "connected"; then
            log "Wireless network connected via iwd."
            return 0
        fi
    fi

    error "No active network connection detected."
    log "Please connect to a wired or wireless network (via iwctl) and rerun the script."
    exit 1
}

install_oh_my_zsh() {
    if [ ! -d "$ZSH_DIR" ]; then
        log "Installing Oh My Zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR/"
    else
        log "Oh My Zsh already installed. Skipping..."
    fi
}

install_neovim_config() {
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        if [ -d "$NVIM_CONFIG_DIR/.git" ]; then
            REMOTE_URL=$(git -C "$NVIM_CONFIG_DIR" remote get-url origin 2>/dev/null || echo "")
            if [[ "$REMOTE_URL" == *"knownasnaffy/nvim"* ]]; then
                log "Neovim configuration already exists and is from the correct repository. Skipping..."
                return
            fi
            log "Neovim configuration exists but is from a different repository. Removing it..."
        else
            log "Neovim configuration exists but is not a Git repository. Removing it..."
        fi
        rm -rf "$NVIM_CONFIG_DIR"
    fi

    log "Cloning Neovim configuration..."
    git clone https://github.com/knownasnaffy/nvim.git "$NVIM_CONFIG_DIR"
}

install_paru() {
    log "Install base packages"
    sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git neovim base-devel

    check_command paru || (
        log "Install paru..."
        git clone https://aur.archlinux.org/paru.git ~/code/clones/paru
        cd ~/code/clones/paru
        makepkg -si
    )
}

install_programs() {
    install_paru

    log "Installing other programs..."

    # Update existing base system
    paru -Syu --noconfirm

    # Pacman packages
    paru -Sy --noconfirm \
        github-cli fastfetch qutebrowser rofi ttf-hack-nerd \
        ghostty task brightnessctl pipewire pipewire-pulse pipewire-alsa wireplumber \
        alsa-utils inotify-tools jq eva bat zoxide 7zip yazi zathura \
        noto-fonts-emoji xdg-user-dirs udisks2 pass eza aichat \
        zathura-pdf-poppler ly playerctl keyd btop ueberzug man-db imagemagick \
        pass-otp oath-toolkit rofi-calc quickshell inter-font

    # Hyprland / Wayland stack
    paru -Sy --noconfirm \
        hyprland hyprlock hyprpicker hyprpolkitagent \
        waybar swaync uwsm qt6-wayland swayosd \
        grim slurp satty wf-recorder wl-clipboard cliphist \
        wev showmethekey ydotool hyprshade \
        xdg-desktop-portal xdg-desktop-portal-hyprland \
        xdg-desktop-portal-termfilechooser-hunkyburrito-git

    # AUR packages
    paru -Sy --noconfirm \
        beeper-v4-bin hyprshutdown-git hyprquickframe-git quicksnip-git

    install_oh_my_zsh
    install_neovim_config

    check_command brew || (
        log "Installing homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    )

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install oven-sh/bun/bun pipx fnm
    pipx install argcomplete
    eval fnm install --lts
}

install_plugins() {
    log "Installing Oh My Zsh plugins and themes..."

    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
    )

    for plugin in "${!plugins[@]}"; do
        local plugin_path="$ZSH_CUSTOM/plugins/$plugin"
        [ -d "$plugin_path" ] && log "Plugin '$plugin' already installed. Skipping..." \
            || git clone "${plugins[$plugin]}" "$plugin_path"
    done

    local spaceship_path="$ZSH_CUSTOM/themes/spaceship-prompt"

    [ -d "$spaceship_path" ] && log "Spaceship prompt already installed. Skipping..." \
        || git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_path" --depth=1 \
        && create_symlink "$spaceship_path/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
}

install_private_packages() {
    log "Installing private PC packages..."
    sudo pacman -Sy --noconfirm jrnl
}

# ─────────────────────────────────────────────────────────────────────────────
# Config & Symlinking Section
# ─────────────────────────────────────────────────────────────────────────────

create_directories() {
    mkdir -p ~/code/projects ~/code/clones
}

link_dotfiles() {
    log "Setting up symlinks for dotfiles..."

    mkdir -p \
        "$HOME/.config" \
        "$HOME/.config/BeeperTexts" \
        "$HOME/.local/bin"

    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/.gitattributes" "$HOME/.gitattributes"
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/.config/aerc" "$HOME/.config/aerc" # personal
    create_symlink "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr" # personal
    create_symlink "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar" # personal
    create_symlink "$DOTFILES_DIR/.config/gh" "$HOME/.config/gh"
    create_symlink "$DOTFILES_DIR/.config/ghostty" "$HOME/.config/ghostty" # desktop
    create_symlink "$DOTFILES_DIR/.config/qutebrowser" "$HOME/.config/qutebrowser" # desktop
    create_symlink "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi" # desktop
    create_symlink "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
    create_symlink "$DOTFILES_DIR/.config/bat" "$HOME/.config/bat"
    create_symlink "$DOTFILES_DIR/.config/eza" "$HOME/.config/eza"
    create_symlink "$DOTFILES_DIR/.config/zathura" "$HOME/.config/zathura" # desktop
    create_symlink "$DOTFILES_DIR/.config/yazi" "$HOME/.config/yazi"
    create_symlink "$DOTFILES_DIR/.config/pycodestyle" "$HOME/.config/pycodestyle"
    create_symlink "$DOTFILES_DIR/.config/systemd" "$HOME/.config/systemd"
    create_symlink "$DOTFILES_DIR/.config/btop" "$HOME/.config/btop"
    create_symlink "$DOTFILES_DIR/.config/swaync" "$HOME/.config/swaync"
    create_symlink "$DOTFILES_DIR/.config/xdg-desktop-portal-termfilechooser" "$HOME/.config/xdg-desktop-portal-termfilechooser"
    create_symlink "$DOTFILES_DIR/.config/bluetuith" "$HOME/.config/bluetuith"
    create_symlink "$DOTFILES_DIR/.config/mpv" "$HOME/.config/mpv"
    create_symlink "$DOTFILES_DIR/.config/swayosd" "$HOME/.config/swayosd"
    create_symlink "$DOTFILES_DIR/.config/swayimg" "$HOME/.config/swayimg"
    create_symlink "$DOTFILES_DIR/.config/quickshell" "$HOME/.config/quickshell"
    create_symlink "$DOTFILES_DIR/.config/.lesskey" "$HOME/.lesskey"
    create_symlink "$DOTFILES_DIR/.zsh_functions" "$HOME/.zsh_functions"

    create_symlink "$DOTFILES_DIR/.config/BeeperTexts/custom.css" "$HOME/.config/BeeperTexts/custom.css" # personal, desktop
    create_symlink "$DOTFILES_DIR/.config/BeeperTexts/config.json" "$HOME/.config/BeeperTexts/config.json" # personal, desktop

    create_symlink "$DOTFILES_DIR/.local/bin/qutebrowser.sh" "$HOME/.local/bin/qutebrowser"
    create_symlink "$DOTFILES_DIR/.local/bin/crypt.sh" "$HOME/.local/bin/crypt"
    create_symlink "$DOTFILES_DIR/.local/bin/git-status.sh" "$HOME/.local/bin/git-status"
    create_symlink "$DOTFILES_DIR/.local/bin/start-hotspot.sh" "$HOME/.local/bin/start-hotspot" # personal
    create_symlink "$DOTFILES_DIR/.local/bin/stop-hotspot.sh" "$HOME/.local/bin/stop-hotspot" # personal
    create_symlink "$DOTFILES_DIR/.local/bin/slurp.sh" "$HOME/.local/bin/slurp"

    create_symlink "$DOTFILES_DIR/.local/share/fonts" "$HOME/.local/share/fonts" # desktop

    create_symlink "$DOTFILES_DIR/media/pictures/wallpaper.jpg" "$HOME/Pictures/wallpaper.jpg" # desktop
    create_symlink "$DOTFILES_DIR/media/pictures/fastfetch.png" "$HOME/Pictures/fastfetch.png" # desktop
    create_symlink "$DOTFILES_DIR/media/music/notification-1.mp3" "$HOME/Music/notification-1.mp3" # desktop
    create_symlink "$DOTFILES_DIR/media/music/notification-2.mp3" "$HOME/Music/notification-2.mp3" # desktop
    create_symlink "$DOTFILES_DIR/media/music/windows-connected.mp3" "$HOME/Music/windows-connected.mp3" # desktop
    create_symlink "$DOTFILES_DIR/media/music/windows-disconnected.mp3" "$HOME/Music/windows-disconnected.mp3" # desktop
    create_symlink "$DOTFILES_DIR/media/music/battery-warning.mp3" "$HOME/Music/battery-warning.mp3" # desktop
    create_symlink "$DOTFILES_DIR/media/music/battery-critical.mp3" "$HOME/Music/battery-critical.mp3" # desktop

    create_sudo_symlink "$DOTFILES_DIR/etc/ly/config.ini" "/etc/ly/config.ini" # desktop
    # not creating a folder for ly beforehand as it is supposed to hold more than just a
    # config file, so if the installation fails, there is no point in creating
    # the config folder as it will interrupt in the installation later
    create_sudo_symlink "$DOTFILES_DIR/etc/keyd" "/etc/keyd" # desktop
}

# ─────────────────────────────────────────────────────────────────────────────
# Shell & Postinstall Setup
# ─────────────────────────────────────────────────────────────────────────────

setup_zsh() {
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        log "Setting Zsh as the default shell..."
        sudo chsh "$(id -un)" --shell "$(command -v zsh)"
    else
        log "Zsh is already the default shell."
    fi
}

post_install_scripts() {
    bat cache --build
    check_command xdg-settings && xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
    check_command xdg-mime && (
        xdg-mime default org.pwmt.zathura.desktop application/pdf

        xdg-mime default nvim.desktop text/plain inode/text application/x-empty

        xdg-mime default swayimg.desktop image/jpeg image/png image/gif image/bmp image/webp image/svg+xml
    )

    if ! systemctl is-enabled keyd &>/dev/null; then
        sudo systemctl enable keyd
    fi

    POSTNOTES+=$(log "$(yellow_text "Ly was not started.") You can enable and start it with: systemctl enable --now ly@tty2.service\n")

    fnm completions --shell zsh > ~/.zsh_functions/_fnm
}

create_cleanup_script() {
    log "Cleanup script is pending. Complete it dude!"
}

# ─────────────────────────────────────────────────────────────────────────────
# Entrypoint
# ─────────────────────────────────────────────────────────────────────────────

main() {
    PRIVATE_MODE=false
    FLAGS=()

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--private) PRIVATE_MODE=true ;;
            -nw) FLAGS+=("setup_network") ;;
            -pi) FLAGS+=("post_install_scripts") ;;
            -ln) FLAGS+=("link_dotfiles") ;;
            -zsh) FLAGS+=("setup_zsh") ;;
            -plugins) FLAGS+=("install_plugins") ;;
            -progs) FLAGS+=("install_programs") ;;
            -dirs) FLAGS+=("create_directories") ;;
        esac
        shift
    done

    # Function runner helper
    run_function() {
        local func=$1
        if [ ${#FLAGS[@]} -eq 0 ]; then
            # Run all functions in original sequence if no flags
            $func
        else
            # Run only if function is in FLAGS
            for f in "${FLAGS[@]}"; do
                if [ "$f" == "$func" ]; then
                    $func
                    break
                fi
            done
        fi
    }

    # Run functions accordingly (only create_cleanup_script always runs)
    run_function setup_network
    run_function create_directories
    run_function install_programs
    run_function setup_zsh
    run_function install_plugins
    run_function link_dotfiles
    run_function post_install_scripts
    create_cleanup_script
    $PRIVATE_MODE && install_private_packages

    if (( SKIPPED_SYMLINKS > 0 )); then
        POSTNOTES+="$SKIPPED_SYMLINKS symlink(s) were skipped because they already existed"
    fi

    echo $POSTNOTES
}

main "$@"
