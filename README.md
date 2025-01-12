# Dotfiles Setup

This repository contains the dotfiles and setup scripts to configure and manage a development environment. It automates the installation of essential programs, plugins, and symlinking of configuration files.

---

## Features

- **Automated Program Installation**: Installs Zsh, Git, Neovim, and other required tools based on the detected operating system.
- **Oh My Zsh Setup**: Installs and configures Oh My Zsh with plugins and the Spaceship prompt.
- **Dotfiles Management**: Automatically creates symbolic links for your dotfiles.
- **Cross-Platform Compatibility**: Supports Ubuntu and other Linux distributions.

---

## Prerequisites

- Git must be installed.
- Sudo access is required to install programs.

---

## Installation

### 1. Clone the Repository
```bash
# Clone the repository to your desired location
git clone https://github.com/<your-username>/dotfiles.git
cd dotfiles
```

### 2. Run the Setup Script
```bash
# Execute the setup script
bash setup.sh
```

---

## Setup Details

### Programs Installed
The setup script installs the following programs:
- Zsh
- Git
- Neovim
- [Oh My Zsh](https://ohmyz.sh)
- Plugins:
  - zsh-autosuggestions
  - zsh-history-substring-search
  - zsh-syntax-highlighting
- Spaceship prompt theme

### Dotfiles Managed
The script links the following files and directories from the repository to your system:
- `.gitconfig`
- `.zshrc`
- `.config/gh`

---

## Structure

```
.
├── .gitconfig          # Git configuration file
├── .zshrc              # Zsh configuration file
├── .config/gh          # GitHub CLI configuration directory
├── setup.sh            # Main setup script
└── README.md           # Project documentation
```

---

## Troubleshooting

1. **Shell not switching to Zsh**:
   - Ensure Zsh is installed and available in your PATH.
   - Restart your terminal after running the script.

2. **Symlinks not created**:
   - Verify the paths in the repository match your intended structure.
   - Ensure there are no conflicting files or directories.

3. **Backup Files**:
   - If an existing file is replaced, it is renamed with a `.bak` suffix. Check for these backups if any issues arise.

---

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request to improve the project.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

