# Dotfiles Setup

This repository contains the dotfiles and setup scripts to configure and manage a personalized development environment. The setup automates the installation of essential tools, configuration of Zsh, Neovim, and other utilities, and ensures a consistent workflow by symlinking your custom dotfiles.

> **Note**: This setup is mainly designed for a **bare Arch Linux installation**.
> While it may work on other Linux distributions, it is optimized and tested for a minimal Arch setup.

## Features

- **Automated Program Installation**: Installs Zsh, Git, Neovim, and a wide range of essential tools and utilities.
- **Oh My Zsh Setup**: Installs and configures Oh My Zsh with essential plugins and the Spaceship prompt.
- **Neovim Configuration**: Installs a pre-configured Neovim setup, including Kickstart.nvim.
- **Dotfiles Management**: Automatically creates symbolic links for your dotfiles, ensuring a consistent environment across machines.
- **Cross-Platform Compatibility**: Supports various Linux distributions, including Arch-based systems like Manjaro and Ubuntu.
- **Backup Mechanism**: Existing files are backed up before replacement, ensuring you don’t lose any data.
- **Private Package Support**: Supports optional installation of private packages in a separate mode.

## Prerequisites

Before running the setup script, ensure the following:

- **Git** is installed (for cloning the repository).
- **Sudo access** is required to install programs and create system-level symlinks.
- **Zsh** should be installed or the script will install it.

## Installation

### 1. Clone the Repository
Clone the repository to your desired location:

```bash
# Clone the repository
git clone https://github.com/<your-username>/dotfiles.git
cd dotfiles
```

### 2. Run the Setup Script
Run the setup script to install the necessary programs and configure your environment:

```bash
# Execute the setup script
./setup.sh
```

Optionally, you can use the `-p` or `--private` flag to install private packages if necessary:

```bash
# Run with private packages
./setup.sh --private
```

## Manual Configuration

### 1. Remove Bootloader Warnings (for specific systems)

If you're using a bootloader like `systemd-boot`, you might want to remove warning messages during boot. Open the file `/boot/loader/entries/{date}_linux-{zen|dev}.conf` or a similar entry, and update the kernel options:

```diff
- options root=PARTUUID=f7372bdd-1ac2-4ba4-8e6d-d5f56b98092c zswap.enabled=0 rw rootfstype=f2fs
+ options root=PARTUUID=f7372bdd-1ac2-4ba4-8e6d-d5f56b98092c zswap.enabled=0 rw rootfstype=f2fs loglevel=3 quiet
```

### 2. Aerc setup instructions

When you add an email to the aerc, in the outgoing parameter of any of your gmail accounts, use the port 465 instead of 587. This is because the TLS connection refuses to connect for outgoing emails.

## Setup Details

### Programs Installed
The setup script installs the following programs:

- **Zsh**: A powerful shell for interactive use.
- **Git**: Version control tool for code management.
- **Neovim**: A modern, extensible Vim-based text editor.
- **Oh My Zsh**: A framework for managing Zsh configurations.
- **Other Utilities**:
  - **fzf**: A command-line fuzzy finder.
  - **GitHub CLI**: GitHub command-line tool for interacting with repositories.
  - **Rofi**: A window switcher and application launcher.
  - **Picom**: A compositor for X11.
  - **Polybar**: A highly customizable status bar for X11.
  - **Qutebrowser**: A keyboard-driven web browser.
  - **Fastfetch**: A fast system information tool.
  - And many others (see full list below).

### Dotfiles Managed
The setup script links the following files and directories from the repository to your system:

- `.gitconfig`: Global Git configuration.
- `.zshrc`: Zsh configuration.
- `.config/gh`: GitHub CLI configuration.
- `.config/ghostty`: Ghostty configuration for the terminal emulator.
- `.config/qutebrowser`: Configuration for the Qutebrowser browser.
- `.config/polybar`: Polybar configuration.
- `.config/picom`: Picom configuration.
- `.config/i3`: i3 window manager configuration.
- `.config/rofi`: Rofi configuration.
- `.config/fastfetch`: Fastfetch configuration.
- `.config/bat`: Bat configuration for viewing files.
- `.config/eza`: Eza configuration for improved `ls`.
- `.config/zathura`: PDF viewer configuration.
- `.config/yazi`: Yazi configuration for file management.
- `.config/pycodestyle`: Python style guide configuration.
- `.config/.lesskey`: Less command configuration.
- `.config/.Xresources`: X11 resource settings.
- `.zsh_functions`: Custom Zsh functions.

## Full Program List
Here’s a quick look at the programs installed by the script:

- **Neovim** and configuration (Kickstart.nvim)
- **Zsh** with Oh My Zsh
- **fzf** (fuzzy finder)
- **Ripgrep** (faster `grep` tool)
- **GitHub CLI**
- **Rofi** (launcher)
- **Polybar** (status bar)
- **Picom** (compositor)
- **Qutebrowser** (keyboard-driven browser)
- **Fastfetch** (system information tool)
- **Cowsay**, **fortune-mod**, **thefuck**, and **bat** for fun and productivity
- **Pipewire** and **WirePlumber** for audio handling
- And more utilities like **brightnessctl**, **yazi**, **zathura**, **i3lock-color**, **xdotool**, **dunst**, etc.

## Structure

```
.
├── .gitconfig          # Git configuration file
├── .zshrc              # Zsh configuration file
├── .config/gh          # GitHub CLI configuration
├── .config/ghostty     # Ghostty terminal configuration
├── .config/qutebrowser # Qutebrowser configuration
├── .config/polybar     # Polybar configuration
├── .config/picom       # Picom configuration
├── .config/i3          # i3 configuration
├── .config/rofi        # Rofi configuration
├── .config/fastfetch   # Fastfetch configuration
├── .config/bat         # Bat configuration
├── .config/eza         # Eza configuration
├── .config/zathura     # Zathura configuration
├── .config/yazi        # Yazi configuration
├── .zsh_functions      # Custom Zsh functions
├── setup.sh            # Main setup script
└── README.md           # Project documentation
```

## Troubleshooting

1. **Shell not switching to Zsh**:
   - Ensure Zsh is installed and available in your `PATH`.
   - Restart your terminal after running the script.

2. **Symlinks not created**:
   - Ensure there are no existing conflicting files or directories in the target locations.
   - Check that the paths in the repository match your system’s configuration.

3. **Backup Files**:
   - If an existing file is replaced by a symlink, it is renamed with a `.bak` suffix. Check for backups if any issues arise.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request to improve the project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
