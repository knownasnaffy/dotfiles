#!/bin/bash
set -e

# Variables
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
DOTFILES_DIR="$PWD"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

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

install_gh_ubuntu() {
    local KEYRING_DIR="/etc/apt/keyrings"
    local KEYRING_PATH="$KEYRING_DIR/githubcli-archive-keyring.gpg"
    local REPO_LIST="/etc/apt/sources.list.d/github-cli.list"
    local GH_REPO="https://cli.github.com/packages"
    local ARCH

    check_command dpkg && ARCH=$(dpkg --print-architecture) || return

    sudo mkdir -p -m 755 "$KEYRING_DIR"
    wget -qO- "$GH_REPO/githubcli-archive-keyring.gpg" | sudo tee "$KEYRING_PATH" >/dev/null
    sudo chmod go+r "$KEYRING_PATH"

    if ! grep -q "^deb .*githubcli" "$REPO_LIST" 2>/dev/null; then
        echo "deb [arch=$ARCH signed-by=$KEYRING_PATH] $GH_REPO stable main" | sudo tee "$REPO_LIST" >/dev/null
    fi

    sudo apt-get update -qq && sudo apt-get install -y gh
}

install_programs() {
    log "Detected Manjaro. Installing programs..."
    sudo pamac update --no-confirm
    sudo pamac install --no-confirm zsh make gcc ripgrep unzip git xclip neovim fzf github-cli nvm fortune-mod base-devel fortune-mod cowsay fastfetch qutebrowser rofi polybar feh picom ttf-hack-nerd ghostty task maim brightnessctl pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils inotify-tools jq eva thefuck bat zoxide

    install_oh_my_zsh
    install_neovim_config

    check_command bun || (log 'Installing bun...' && curl -fsSL https://bun.sh/install | bash)

    check_command brew || (log "Installing homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install gitpod-io/tap/gitpod pipx
}

setup_zsh() {
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        log "Setting Zsh as the default shell..."
        chsh -s "$(command -v zsh)"
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
    create_symlink "$DOTFILES_DIR/.config/.lesskey" "$HOME/.lesskey"
    create_symlink "$DOTFILES_DIR/.zsh_functions" "$HOME/.zsh_functions"
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

    install_programs
    setup_zsh
    install_plugins
    link_dotfiles

    $PRIVATE_MODE && install_private_packages
}

main "$@"
