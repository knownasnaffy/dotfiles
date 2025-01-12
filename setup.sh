# Package(s) to install (modify as needed)
PROGRAMS=("zsh", "git", "neovim")

# Function to install programs
install_programs() {
    for program in "${PROGRAMS[@]}"; do
        echo "Installing $program..."
        if ! $INSTALL_CMD "$program" -y; then
            echo "Failed to install $program. Skipping..."
        fi
    done
}

# Check for pacman or apt-get
if command -v pacman &> /dev/null; then
    echo "Detected Arch-based system. Using pacman."
    INSTALL_CMD="sudo pacman -S --needed"
elif command -v apt-get &> /dev/null; then
    echo "Detected Ubuntu-based system. Using apt-get."
    INSTALL_CMD="sudo apt-get install"
else
    echo "Error: Neither pacman nor apt-get found. Exiting."
    exit 1
fi

# Install programs
install_programs

# Final message
echo "Installation complete. Please verify the programs are installed."

# Function to set up Zsh as the default shell
setup_zsh() {
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        echo "Setting Zsh as the default shell..."
        chsh -s "$(command -v zsh)"
    else
        echo "Zsh is already the default shell."
    fi
}

ln -s $PWD/.gitconfig ~/.gitconfig
ln -s $PWD/.zshrc ~/.zshrc
ln -s $PWD/gh ~/.config/gh

# Oh my zsh
sh -c "$(curl -fsSL https://install.ohmyz.sh/)"

# Zsh plugins - autosuggestions, history substring search, syntax highlinghting.
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Spaceship prompt theme
git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1
ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship.zsh-theme

# Bun - Javascript runtime and package manager
curl -fsSL https://bun.sh/install | bash
