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

    # Oh my zsh
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

    # Bun - Javascript runtime and package manager
    # curl -fsSL https://bun.sh/install | bash
}

# Function to set up Zsh as the default shell
setup_zsh() {
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        echo "Setting Zsh as the default shell..."
        chsh -s "$(command -v zsh)"
    else
        echo "Zsh is already the default shell."
    fi
}

install_plugins() {
    echo "Installing ohmyzsh plugins"

    # Zsh plugins - autosuggestions, history substring search, syntax highlinghting.
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Spaceship prompt theme
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1
    ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship.zsh-theme
}

link_dotfiles() {
    echo "Settings symlinks for dotfiles"
    rm ~/.zshrc
    ln -s $PWD/.gitconfig ~/.gitconfig
    ln -s $PWD/.zshrc ~/.zshrc
    ln -s $PWD/gh ~/.config/gh
}

switch_terminal() {
    # Get the current shell
    CURRENT_SHELL=$(basename "$SHELL")

    # Check if the current shell is Zsh
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        echo "Current shell is $CURRENT_SHELL. Switching to Zsh..."

        # Check if Zsh is installed
        if command -v zsh &> /dev/null; then
            # Change the default shell to Zsh
            chsh -s "$(command -v zsh)"
            echo "Default shell changed to Zsh. Restart your terminal to apply the changes."
        else
            echo "Zsh is not installed. Please install it first and re-run this script."
            exit 1
        fi
    else
        echo "Current shell is already Zsh."
    fi
}

main() {
    install_programs
    setup_zsh
    install_plugins
    link_dotfiles
    switch_terminal
}

main
