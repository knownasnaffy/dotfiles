#!/bin/bash
set -e

# Variables
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
DOTFILES_DIR="$PWD"

log() { echo -e "[\033[1;32mINFO\033[0m] $1"; }
error() { echo -e "[\033[1;31mERROR\033[0m] $1"; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "$1 is not installed or not in PATH."
        exit 1
    fi
}

create_symlink() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ]; then
        log "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    ln -s "$src" "$dest"
    log "Symlink created: $dest -> $src"
}

install_programs() {
    # Check if the system is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "System is Ubuntu. Installing programs using apt-get..."
            # Install required programs
            sudo apt-get install zsh git neovim
        else
            echo "System is not Ubuntu. Skipping some installations."
        fi
    else
        echo "Unable to detect the operating system."
    fi

    install_oh_my_zsh() {
        if [ -d "$ZSH_DIR" ]; then
            log "Oh My Zsh already installed. Skipping..."
        else
            log "Installing Oh My Zsh..."
            git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
        fi
    }

    # Bun - Javascript runtime and package manager
    check_command bun || (log 'Installing bun' |
        curl -fsSL https://bun.sh/install | bash)
}

# Function to set up Zsh as the default shell
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

    # Define plugins and their URLs
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    )

    # Install plugins
    for plugin in "${!plugins[@]}"; do
        local plugin_path="$ZSH_CUSTOM/plugins/$plugin"
        if [ -d "$plugin_path" ]; then
            log "Plugin '$plugin' already installed. Skipping..."
        else
            log "Installing plugin '$plugin'..."
            git clone "${plugins[$plugin]}" "$plugin_path"
        fi
    done

    # Install Spaceship prompt theme
    local spaceship_path="$ZSH_CUSTOM/themes/spaceship-prompt"
    if [ -d "$spaceship_path" ]; then
        log "Spaceship prompt already installed. Skipping..."
    else
        log "Installing Spaceship prompt..."
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_path" --depth=1
        create_symlink "$spaceship_path/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    fi
}

link_dotfiles() {
    log "Settings symlinks for dotfiles"
    create_symlink $DOTFILES_DIR/.gitconfig ~/.gitconfig
    create_symlink $DOTFILES_DIR/.zshrc ~/.zshrc
    create_symlink $DOTFILES_DIR/.config/gh ~/.config/gh
}

switch_terminal() {
    # Get the current shell
    CURRENT_SHELL=$(basename "$SHELL")

    # Check if the current shell is Zsh
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        log "Current shell is $CURRENT_SHELL. Switching to Zsh..."

        # Check if Zsh is installed
        if command -v zsh &> /dev/null; then
            # Change the default shell to Zsh
            chsh -s "$(command -v zsh)"
            log "Default shell changed to Zsh. Restart your terminal to apply the changes."
        else
            error "Zsh is not installed. Please install it first and re-run this script."
            exit 1
        fi
    else
        log "Current shell is already Zsh."
    fi
}

main() {
    install_programs
    echo
    setup_zsh
    echo
    install_plugins
    echo
    link_dotfiles
    echo
    switch_terminal
}

main
