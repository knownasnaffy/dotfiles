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

log() {
    echo -e "[\033[1;32mINFO\033[0m] $1"
}

error() {
    echo -e "[\033[1;31mERROR\033[0m] $1"
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
        fzf github-cli fastfetch jq eva thefuck bat zoxide 7zip yazi xdotool xdg-user-dirs pass eza aichat xorg-xrandr \
        btop ueberzug

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

    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/.config/gh" "$HOME/.config/gh"
    create_symlink "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
    create_symlink "$DOTFILES_DIR/.config/bat" "$HOME/.config/bat"
    create_symlink "$DOTFILES_DIR/.config/eza" "$HOME/.config/eza"
    create_symlink "$DOTFILES_DIR/.config/yazi" "$HOME/.config/yazi"
    create_symlink "$DOTFILES_DIR/.config/pycodestyle" "$HOME/.config/pycodestyle"
    create_symlink "$DOTFILES_DIR/.config/systemd" "$HOME/.config/systemd"
    create_symlink "$DOTFILES_DIR/.config/dunst" "$HOME/.config/dunst"
    create_symlink "$DOTFILES_DIR/.config/btop" "$HOME/.config/btop"
    create_symlink "$DOTFILES_DIR/.config/.lesskey" "$HOME/.lesskey"
    create_symlink "$DOTFILES_DIR/.config/.Xresources" "$HOME/.Xresources"
    create_symlink "$DOTFILES_DIR/.zsh_functions" "$HOME/.zsh_functions"

    create_symlink "$DOTFILES_DIR/.local/bin/crypt.sh" "$HOME/.local/bin/crypt"
    create_symlink "$DOTFILES_DIR/.local/bin/git-status.sh" "$HOME/.local/bin/git-status"

    create_symlink "$DOTFILES_DIR/.local/share/fonts" "$HOME/.local/share/fonts"
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
            -pi) FLAGS+=("post_install_scripts") ;;
            -ln) FLAGS+=("link_dotfiles") ;;
            -zsh) FLAGS+=("setup_zsh") ;;
            -plugins) FLAGS+=("install_plugins") ;;
            -progs) FLAGS+=("install_programs") ;;
            -dirs) FLAGS+=("create_directories") ;;
                # Add more flags and corresponding function names here as needed
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
