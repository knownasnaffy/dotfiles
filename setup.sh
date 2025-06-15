#!/bin/bash
set -e

# Variables
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
DOTFILES_DIR="$PWD"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
POSTNOTES=""

log() { echo -e "[\033[1;32mINFO\033[0m] $1"; }
error() { echo -e "[\033[1;31mERROR\033[0m] $1"; }

check_command() {
    command -v "$1" &>/dev/null
}

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

create_directories() {
    mkdir -p ~/code/projects ~/code/clones
}

create_cleanup_script() {
    #  TODO: Create a temp file in a .cache folder or so and add the `rm` command to delete this directory if it isn't in the ~/code/projects/dotfiles folder
    log "Cleanup script is pending. Complete it dude!"
}

install_paru() {
    log "Install base packages"
    sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git xclip neovim base-devel

    check_command paru || (log "Install paru..." &&
        git clone https://aur.archlinux.org/paru.git ~/code/clones/paru && cd ~/code/clones/paru && makepkg -si)
}

install_programs() {
    install_paru

    log "Installing other programs..."
    paru -Syu --noconfirm
    paru -Sy --noconfirm fzf github-cli fortune-mod cowsay fastfetch qutebrowser rofi polybar feh picom ttf-hack-nerd ghostty task maim brightnessctl pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils inotify-tools jq eva thefuck bat zoxide 7zip yazi zathura i3lock-color noto-fonts-emoji dunst xdotool xdg-user-dirs udisks2 pass xorg-xrandr eza aichat beeper-v4-bin zathura-pdf-poppler rofi-greenclip ly i3-wm

    install_oh_my_zsh
    install_neovim_config

    check_command brew || (log "Installing homebrew..."
    #  FIXME: Fix this Script
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install oven-sh/bun/bun pipx fnm

    # For pipx completions
    pipx install argcomplete

    # Install latest stable nodejs
    eval fnm install --lts
}

post_install_scripts() {
    bat cache --build
    check_command xdg-settings && xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
    check_command xdg-settings && xdg-mime default org.pwmt.zathura.desktop application/pdf
    if ! systemctl is-enabled ly &>/dev/null; then
        sudo systemctl enable ly
    fi
    if ! systemctl is-active docker &>/dev/null; then
        POSTNOTES+=$(log "Ly is not running. You can start it with: systemctl start ly\n")
    fi
}

setup_zsh() {
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        log "Setting Zsh as the default shell..."
        sudo chsh "$(id -un)" --shell "$(command -v zsh)"
    else
        log "Zsh is already the default shell."
    fi
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
        [ -d "$plugin_path" ] && log "Plugin '$plugin' already installed. Skipping..." || git clone "${plugins[$plugin]}" "$plugin_path"
    done

    local spaceship_path="$ZSH_CUSTOM/themes/spaceship-prompt"
    [ -d "$spaceship_path" ] && log "Spaceship prompt already installed. Skipping..." || git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_path" --depth=1 && create_symlink "$spaceship_path/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
}

link_dotfiles() {
    log "Setting up symlinks for dotfiles..."
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
    create_symlink "$DOTFILES_DIR/.config/.lesskey" "$HOME/.lesskey"
    create_symlink "$DOTFILES_DIR/.config/.Xresources" "$HOME/.Xresources"
    create_symlink "$DOTFILES_DIR/.config/greenclip.toml" "$HOME/.config/greenclip.toml"
    create_symlink "$DOTFILES_DIR/.zsh_functions" "$HOME/.zsh_functions"
    create_symlink "$DOTFILES_DIR/.local/share/fonts" "$HOME/.local/share/fonts"
    create_sudo_symlink "$DOTFILES_DIR/etc/X11/xorg.config.d/30-touchpad.conf" "/etc/X11/xorg.conf.d/30-touchpad.conf"
    create_sudo_symlink "$DOTFILES_DIR/etc/ly/config.ini" "/etc/ly/config.ini"
}

install_private_packages() {
    log "Installing private PC packages..."
    sudo pacman -Sy --noconfirm jrnl
}

main() {
    PRIVATE_MODE=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--private) PRIVATE_MODE=true ;;
        esac
        shift
    done

    create_directories
    install_programs
    setup_zsh
    install_plugins
    link_dotfiles
    post_install_scripts
    create_cleanup_script

    $PRIVATE_MODE && install_private_packages

    echo $POSTNOTES
}

main "$@"
