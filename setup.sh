# ─────────────────────────────────────────────────────────────────────────────
# Core System Variables
# ─────────────────────────────────────────────────────────────────────────────

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
POSTNOTES=""

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
        log "Symlink already exists: $dest -> $src. Skipping..."
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
        log "Symlink already exists: $dest -> $src. Skipping..."
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
            if [[ "$REMOTE_URL" == *"knownasnaffy/kickstart.nvim"* ]]; then
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
    git clone https://github.com/knownasnaffy/kickstart.nvim.git "$NVIM_CONFIG_DIR"
}

install_paru() {
    log "Install base packages"
    sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git xclip neovim base-devel

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
    paru -Syu --noconfirm

    paru -Sy --noconfirm \
        fzf github-cli fastfetch qutebrowser rofi polybar feh picom ttf-hack-nerd \
        ghostty task flameshot brightnessctl pipewire pipewire-pulse pipewire-alsa wireplumber \
        alsa-utils inotify-tools jq eva thefuck bat zoxide 7zip yazi zathura \
        noto-fonts-emoji dunst xdotool xdg-user-dirs udisks2 pass eza aichat \
        zathura-pdf-poppler ly i3-wm xorg-server xorg-xinit xorg-xrandr \
        spotifyd playerctl keyd btop ueberzug man-db imagemagick

    paru -Sy --noconfirm \
        i3lock-color rofi-greenclip beeper-v4-bin

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
    cargo install battery-notify
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
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/.config/gh" "$HOME/.config/gh"
    create_symlink "$DOTFILES_DIR/.config/ghostty" "$HOME/.config/ghostty"
    create_symlink "$DOTFILES_DIR/.config/qutebrowser" "$HOME/.config/qutebrowser"
    create_symlink "$DOTFILES_DIR/.config/picom" "$HOME/.config/picom"
    create_symlink "$DOTFILES_DIR/.config/polybar" "$HOME/.config/polybar"
    create_symlink "$DOTFILES_DIR/.config/i3" "$HOME/.config/i3"
    create_symlink "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi"
    create_symlink "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
    create_symlink "$DOTFILES_DIR/.config/bat" "$HOME/.config/bat"
    create_symlink "$DOTFILES_DIR/.config/eza" "$HOME/.config/eza"
    create_symlink "$DOTFILES_DIR/.config/zathura" "$HOME/.config/zathura"
    create_symlink "$DOTFILES_DIR/.config/yazi" "$HOME/.config/yazi"
    create_symlink "$DOTFILES_DIR/.config/pycodestyle" "$HOME/.config/pycodestyle"
    create_symlink "$DOTFILES_DIR/.config/battery-notify" "$HOME/.config/battery-notify"
    create_symlink "$DOTFILES_DIR/.config/spotifyd" "$HOME/.config/spotifyd"
    create_symlink "$DOTFILES_DIR/.config/systemd" "$HOME/.config/systemd"
    create_symlink "$DOTFILES_DIR/.config/dunst" "$HOME/.config/dunst"
    create_symlink "$DOTFILES_DIR/.config/btop" "$HOME/.config/btop"
    create_symlink "$DOTFILES_DIR/.config/.lesskey" "$HOME/.lesskey"
    create_symlink "$DOTFILES_DIR/.config/.Xresources" "$HOME/.Xresources"
    create_symlink "$DOTFILES_DIR/.config/greenclip.toml" "$HOME/.config/greenclip.toml"
    create_symlink "$DOTFILES_DIR/.zsh_functions" "$HOME/.zsh_functions"

    create_symlink "$DOTFILES_DIR/.config/BeeperTexts/custom.css" "$HOME/.config/BeeperTexts/custom.css"
    create_symlink "$DOTFILES_DIR/.config/BeeperTexts/config.json" "$HOME/.config/BeeperTexts/config.json"

    create_symlink "$DOTFILES_DIR/.local/bin/crypt.sh" "$HOME/.local/bin/crypt"
    create_symlink "$DOTFILES_DIR/.local/bin/git-status.sh" "$HOME/.local/bin/git-status"
    create_symlink "$DOTFILES_DIR/.local/bin/start-hotspot.sh" "$HOME/.local/bin/start-hotspot"
    create_symlink "$DOTFILES_DIR/.local/bin/stop-hotspot.sh" "$HOME/.local/bin/stop-hotspot"

    create_symlink "$DOTFILES_DIR/.local/share/fonts" "$HOME/.local/share/fonts"

    create_sudo_symlink "$DOTFILES_DIR/etc/X11/xorg.config.d/30-touchpad.conf" "/etc/X11/xorg.conf.d/30-touchpad.conf"
    create_sudo_symlink "$DOTFILES_DIR/etc/ly/config.ini" "/etc/ly/config.ini"
    # not creating a folder for ly beforehand as it is supposed to hold more than just a
    # config file, so if the installation fails, there is no point in creating
    # the config folder as it will interrupt in the installation later
    create_sudo_symlink "$DOTFILES_DIR/etc/keyd" "/etc/keyd"
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
    check_command xdg-settings && xdg-mime default org.pwmt.zathura.desktop application/pdf

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

    echo $POSTNOTES
}

main "$@"
