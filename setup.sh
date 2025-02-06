#!/bin/bash
set -e

#  TODO: Add an option to get arguments and if the -p argument is present, only
#        then will you install the packages that are supposed to be installed
#        on my private pc

#  TODO: Separate config files and personal data files. Make a separate file
#        for data files/folders like taskwarrior, jrnl and qutebrowser bookmarks

# Variables
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
DOTFILES_DIR="$PWD"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

log() { echo -e "[\033[1;32mINFO\033[0m] $1"; }
error() { echo -e "[\033[1;31mERROR\033[0m] $1"; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "$1 is not installed or not in PATH."
        return false
    fi
}

#  TODO: Instead of just backing it up, create a logic to check if it's a symlink
#        and is already pointing to the src location and then create a backup if
#        it's not and if it is, just skip
create_symlink() {
    local src="$1"
    local dest="$2"
    local backup="${dest}.bak"
    local count=1

    if [ -e "$dest" ]; then
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
    if [ -d "$ZSH_DIR" ]; then
        log "Oh My Zsh already installed. Skipping..."
    else
        log "Installing Oh My Zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR/"
    fi
}

install_neovim_config() {
    # Check if the directory exists and is not empty
    if [ -d "$NVIM_CONFIG_DIR" ] && [ "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]; then
        log "Neovim configuration directory is not empty. Deleting it..."
        rm -rf "$NVIM_CONFIG_DIR"
    fi

    # Clone the Neovim configuration
    log "Cloning Neovim configuration..."
    git clone https://github.com/knownasnaffy/kickstart.nvim.git "$NVIM_CONFIG_DIR"
    log "Neovim configuration installed."
}

install_gh() {
    # Ensure wget is installed
    if ! command -v wget >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y wget
    fi

    # Set variables
    KEYRING_DIR="/etc/apt/keyrings"
    KEYRING_PATH="$KEYRING_DIR/githubcli-archive-keyring.gpg"
    REPO_LIST="/etc/apt/sources.list.d/github-cli.list"
    GH_REPO="https://cli.github.com/packages"
    ARCH=$(dpkg --print-architecture)

    # Create keyring directory if not exists
    sudo mkdir -p -m 755 "$KEYRING_DIR"

    # Download and install GPG key
    wget -qO- "$GH_REPO/githubcli-archive-keyring.gpg" | sudo tee "$KEYRING_PATH" >/dev/null
    sudo chmod go+r "$KEYRING_PATH"

    # Add repository if not already added
    if ! grep -q "^deb .*githubcli" "$REPO_LIST" 2>/dev/null; then
        echo "deb [arch=$ARCH signed-by=$KEYRING_PATH] $GH_REPO stable main" | sudo tee "$REPO_LIST" >/dev/null
    fi

    # Install GitHub CLI
    sudo apt-get update -qq && sudo apt-get install -y gh
}

install_programs() {
    # Check if the system is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "System is Ubuntu. Installing programs using apt-get..."
            # Install required programs
            install_gh
            sudo apt-get install -y zsh make gcc ripgrep unzip git xclip neovim fzf
        elif [[ "$ID" == "manjaro" ]]; then
            echo "System is Manjaro. Installing programs using pacman..."
            # Install required programs
            sudo pacman -S --noconfirm zsh make gcc ripgrep unzip git xclip neovim fzf github-cli
        else
            echo "System is not Ubuntu or Manjaro. Skipping some installations."
        fi
    else
        echo "Unable to detect the operating system."
    fi

    # Install Oh My Zsh
    install_oh_my_zsh

    # Configure neovim
    install_neovim_config

    # Zoxide - Autojump
    check_command zoxide || (log 'Installing zoxide' |
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh)

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
    create_symlink $DOTFILES_DIR/.config/qutebrowser ~/.config/qutebrowser
    create_symlink $DOTFILES_DIR/.zsh_functions ~/.zsh_functions
}

# Add yazi installation along with it's config files. Make sure to install yazi-git or latest nightly for plugins to work

main() {
    install_programs
    echo
    setup_zsh
    echo
    install_plugins
    echo
    link_dotfiles
}

main
