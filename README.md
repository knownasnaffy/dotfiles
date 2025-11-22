# Dotfiles Setup

Personal Arch Linux dotfiles + bootstrap script. Automates installing core tooling (shell, editors, CLI utilities, desktop bits), sets sane defaults, and symlinks configs safely (with backups). Includes optional private package mode.

> Target: **Minimal Arch install (with AUR)**
> Script assumes `pacman` + AUR helper (`paru`). Other distros are NOT supported by the current script (README previously overstated this).

## Key Features

- Automated install of base packages, AUR apps, developer tooling, fonts.
- Safe idempotent symlinking (backs up existing files with numbered .bak suffixes).
- Opinionated Zsh setup (Oh My Zsh + plugins + Spaceship theme).
- Neovim bootstrap (kickstart.nvim clone, auto-replaced if different repo).
- Post-install desktop defaults (qutebrowser, zathura, display/login assets).
- Optional private mode: `--private` installs extra packages.

## Prerequisites

- Arch Linux (or derivative with pacman + ability to build AUR packages).
- sudo access.
- git, curl (will install if missing in base step).

## Quick Start

```bash
git clone https://github.com/<your-username>/dotfiles.git
cd dotfiles
./setup.sh            # standard
./setup.sh --private  # include private extras
```

The script will:
1. Install base compilers & tools (`pacman -Sy zsh make gcc ripgrep unzip git xclip neovim base-devel`).
2. Install / build `paru` if missing.
3. Sync + install large program set via `paru` (see list below).
4. Install Homebrew (if absent) then bun, pipx, fnm, cargo battery-notify.
5. Setup Oh My Zsh plugins + Spaceship prompt.
6. Link dotfiles (user + select /etc configs via sudo symlinks).
7. Run post-install tweaks (bat cache, xdg defaults, enable `ly`).

## Package Highlights

AUR + repo installs include (subset):
- Shell/tools: zsh, fzf, ripgrep, bat, eza, zoxide, btop, eva, jq, brightnessctl.
- Terminal/UI: ghostty, rofi (+ greenclip), polybar, picom, dunst, i3-wm, i3lock-color, keyd.
- Fonts & visuals: ttf-hack-nerd, noto-fonts-emoji, fastfetch, ueberzug.
- Apps: qutebrowser, zathura (+ poppler), spotifyd, flameshot, pass.
- Audio: pipewire, wireplumber, pipewire-pulse, pipewire-alsa, alsa-utils.
- Misc/fun: thefuck, cowsay, fortune-mod.
- Dev extras: bun, fnm (Node LTS), pipx, cargo battery-notify.

Private mode adds: jrnl (and can be extended).

## Managed Dotfiles / Configs

User-level symlinks:
- .gitconfig, .zshrc, .zsh_functions
- ~/.config: gh, ghostty, qutebrowser, picom, polybar, i3, rofi, fastfetch, bat, eza, zathura, yazi, pycodestyle, battery-notify, spotifyd, systemd, dunst, btop, greenclip.toml, BeeperTexts (custom.css, config.json), fonts (under .local/share/fonts)
- ~/.Xresources, ~/.lesskey

System-level (sudo) symlinks:
- /etc/X11/xorg.conf.d/30-touchpad.conf
- /etc/ly/config.ini
- /etc/keyd

If a target exists it is renamed to `filename.bak` (or numbered `.bakN`).

## Neovim Setup Logic
If an existing `~/.config/nvim` is a git repo pointing to `knownasnaffy/kickstart.nvim`, it is kept. Any other existing config is removed then the kickstart repo is cloned.

## Boot & Memory Notes
ZRAM + optional swapfile instructions (for half-RAM zram + 2G fallback file) are documented below.

### ZRAM Quick Reference
```bash
paru -S zram-generator
sudo nvim /etc/systemd/zram-generator.conf
# contents:
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
sudo systemctl daemon-reexec
sudo systemctl restart systemd-zram-setup@zram0
swapon --show
```
Optional swapfile:
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw,pri=10 0 0' | sudo tee -a /etc/fstab
```

## Aerc Tip
Use port 465 (implicit TLS) for Gmail outgoing instead of 587 if STARTTLS fails.

## Structure (simplified)
```
.
├── setup.sh
├── README.md
├── images/
│   ├── fastfetch.png
│   └── tokyonight-wallpaper.png
├── etc/
│   ├── X11/...
│   ├── keyd/...
│   └── ly/config.ini
└── .config/...
```

Fastfetch example (images/fastfetch.png):
![Fastfetch](images/fastfetch.png)

## Troubleshooting
1. Shell still bash: log out or run `chsh $(id -un) --shell $(command -v zsh)` manually.
2. Symlink missing: check permissions (sudo for /etc) and ensure parent directories exist.
3. Neovim config not replaced: remove existing `~/.config/nvim` and rerun.
4. `ly` not starting: `sudo systemctl enable ly && sudo systemctl start ly`.

## Extending
Add new config under repo then append a `create_symlink` (or `create_sudo_symlink`) call in `link_dotfiles()` maintaining grouping. Keep changes minimal & idempotent.

## License
No license file currently included. Add one (MIT, etc.) if you intend to share/reuse.

---
Previously claimed cross-distro support was removed to match actual script behavior.

