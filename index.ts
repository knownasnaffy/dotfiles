#!/usr/bin/env bun

import { $ } from "bun";
import { existsSync, readlinkSync, mkdirSync } from "fs";
import { dirname, resolve } from "path";
import { fileURLToPath } from "url";

// ─────────────────────────────────────────────────────────────────────────────
// Core System Variables
// ─────────────────────────────────────────────────────────────────────────────

const HOME = process.env.HOME!;
const ZSH_DIR = `${HOME}/.oh-my-zsh`;
const ZSH_CUSTOM = `${ZSH_DIR}/custom`;
const DOTFILES_DIR = resolve(dirname(fileURLToPath(import.meta.url)));
const NVIM_CONFIG_DIR = `${process.env.XDG_CONFIG_HOME || `${HOME}/.config`}/nvim`;

let POSTNOTES = "";
let SKIPPED_SYMLINKS = 0;

// ─────────────────────────────────────────────────────────────────────────────
// Logging Helpers
// ─────────────────────────────────────────────────────────────────────────────

const yellowText = (text: string) => `\x1b[1;33m${text}\x1b[0m`;
const redText = (text: string) => `\x1b[1;31m${text}\x1b[0m`;
const greenText = (text: string) => `\x1b[1;32m${text}\x1b[0m`;

const log = (msg: string) => console.log(`[${greenText("INFO")}] ${msg}`);
const error = (msg: string) => console.log(`[${redText("ERROR")}] ${msg}`);

const checkCommand = async (cmd: string): Promise<boolean> => {
  try {
    await $`command -v ${cmd}`.quiet();
    return true;
  } catch {
    return false;
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// Symlink Management
// ─────────────────────────────────────────────────────────────────────────────

const createSymlink = async (src: string, dest: string) => {
  if (existsSync(dest)) {
    try {
      const link = readlinkSync(dest);
      if (link === src) {
        SKIPPED_SYMLINKS++;
        return;
      }
    } catch {}

    let backup = `${dest}.bak`;
    let count = 1;
    while (existsSync(backup)) {
      backup = `${dest}.bak${count}`;
      count++;
    }
    log(`Backing up existing ${dest} to ${backup}`);
    await $`mv ${dest} ${backup}`;
  }

  await $`ln -s ${src} ${dest}`;
  log(`Symlink created: ${dest} -> ${src}`);
};

const createSudoSymlink = async (src: string, dest: string) => {
  if (existsSync(dest)) {
    try {
      const link = readlinkSync(dest);
      if (link === src) {
        SKIPPED_SYMLINKS++;
        return;
      }
    } catch {}

    let backup = `${dest}.bak`;
    let count = 1;
    while (existsSync(backup)) {
      backup = `${dest}.bak${count}`;
      count++;
    }
    log(`Backing up existing ${dest} to ${backup}`);
    await $`sudo mv ${dest} ${backup}`;
  }

  await $`sudo ln -s ${src} ${dest}`;
  log(`Symlink created: ${dest} -> ${src}`);
};

// ─────────────────────────────────────────────────────────────────────────────
// Installation Scripts
// ─────────────────────────────────────────────────────────────────────────────

//  TODO: Pending setups:
//        - ydotool
//        - sddm

const setupNetwork = async () => {
  log("Setting up an internet connection");

  await $`sudo mkdir -p /etc/systemd/network`;

  await $`sudo cp ${DOTFILES_DIR}/etc/systemd/network/20-wired.network /etc/systemd/network/20-wired.network`;
  await $`sudo cp ${DOTFILES_DIR}/etc/systemd/network/25-wireless.network /etc/systemd/network/25-wireless.network`;

  await $`sudo systemctl enable --now systemd-resolved systemd-networkd iwd`;

  log("Checking network connectivity...");

  try {
    const ipLink = await $`ip link show`.text();
    if (/state UP/.test(ipLink) && /enp|eth|eno/.test(ipLink)) {
      log("Wired interface is up (carrier detected).");
      return;
    }
  } catch {}

  if (await checkCommand("iwctl")) {
    try {
      const iwctlList = await $`iwctl station list`.text();
      if (/connected/.test(iwctlList)) {
        log("Wireless network connected via iwd.");
        return;
      }
    } catch {}
  }

  error("No active network connection detected.");
  log("Please connect to a wired or wireless network (via iwctl) and rerun the script.");
  process.exit(1);
};

const installOhMyZsh = async () => {
  if (!existsSync(ZSH_DIR)) {
    log("Installing Oh My Zsh...");
    await $`git clone https://github.com/ohmyzsh/ohmyzsh.git ${ZSH_DIR}/`;
  } else {
    log("Oh My Zsh already installed. Skipping...");
  }
};

const installNeovimConfig = async () => {
  if (existsSync(NVIM_CONFIG_DIR)) {
    if (existsSync(`${NVIM_CONFIG_DIR}/.git`)) {
      try {
        const remoteUrl = await $`git -C ${NVIM_CONFIG_DIR} remote get-url origin`.text();
        if (remoteUrl.includes("knownasnaffy/nvim")) {
          log("Neovim configuration already exists and is from the correct repository. Skipping...");
          return;
        }
        log("Neovim configuration exists but is from a different repository. Removing it...");
      } catch {
        log("Neovim configuration exists but is not a Git repository. Removing it...");
      }
    } else {
      log("Neovim configuration exists but is not a Git repository. Removing it...");
    }
    await $`rm -rf ${NVIM_CONFIG_DIR}`;
  }

  log("Cloning Neovim configuration...");
  await $`git clone https://github.com/knownasnaffy/nvim.git ${NVIM_CONFIG_DIR}`;
};

const installParu = async () => {
  log("Install base packages");
  await $`sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git neovim base-devel`;

  if (!(await checkCommand("paru"))) {
    log("Install paru...");
    await $`git clone https://aur.archlinux.org/paru.git ~/code/clones/paru`;
    await $`cd ~/code/clones/paru && makepkg -si`;
  }
};

const installPrograms = async () => {
  await installParu();

  log("Installing other programs...");

  await $`paru -Syu --noconfirm`;

  await $`paru -Sy --noconfirm github-cli fastfetch qutebrowser rofi ttf-hack-nerd ghostty task brightnessctl pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils inotify-tools jq eva bat zoxide 7zip yazi zathura noto-fonts-emoji xdg-user-dirs udisks2 pass eza aichat zathura-pdf-poppler ly playerctl keyd btop ueberzug man-db imagemagick pass-otp oath-toolkit rofi-calc quickshell inter-font cava`;

  await $`paru -Sy --noconfirm hyprland hyprlock hyprpicker hyprpolkitagent waybar swaync uwsm qt6-wayland swayosd grim slurp satty wf-recorder wl-clipboard cliphist wev showmethekey ydotool hyprshade xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-termfilechooser-hunkyburrito-git`;

  await $`paru -Sy --noconfirm beeper-v4-bin hyprshutdown-git hyprquickframe-git quicksnip-git`;

  await installOhMyZsh();
  await installNeovimConfig();

  if (!(await checkCommand("brew"))) {
    log("Installing homebrew...");
    await $`NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`;
  }

  await $`eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install oven-sh/bun/bun pipx fnm`;
  await $`pipx install argcomplete`;
  await $`eval fnm install --lts`;
};

const installPlugins = async () => {
  log("Installing Oh My Zsh plugins and themes...");

  const plugins: Record<string, string> = {
    "zsh-autosuggestions": "https://github.com/zsh-users/zsh-autosuggestions",
    "zsh-history-substring-search": "https://github.com/zsh-users/zsh-history-substring-search",
    "zsh-syntax-highlighting": "https://github.com/zsh-users/zsh-syntax-highlighting",
    "zsh-completions": "https://github.com/zsh-users/zsh-completions",
  };

  for (const [plugin, url] of Object.entries(plugins)) {
    const pluginPath = `${ZSH_CUSTOM}/plugins/${plugin}`;
    if (existsSync(pluginPath)) {
      log(`Plugin '${plugin}' already installed. Skipping...`);
    } else {
      await $`git clone ${url} ${pluginPath}`;
    }
  }

  const spaceshipPath = `${ZSH_CUSTOM}/themes/spaceship-prompt`;
  if (existsSync(spaceshipPath)) {
    log("Spaceship prompt already installed. Skipping...");
  } else {
    await $`git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${spaceshipPath} --depth=1`;
    await createSymlink(`${spaceshipPath}/spaceship.zsh-theme`, `${ZSH_CUSTOM}/themes/spaceship.zsh-theme`);
  }
};

const installPrivatePackages = async () => {
  log("Installing private PC packages...");
  await $`sudo pacman -Sy --noconfirm jrnl`;
};

// ─────────────────────────────────────────────────────────────────────────────
// Config & Symlinking Section
// ─────────────────────────────────────────────────────────────────────────────

const createDirectories = () => {
  mkdirSync(`${HOME}/code/projects`, { recursive: true });
  mkdirSync(`${HOME}/code/clones`, { recursive: true });
};

const linkDotfiles = async () => {
  log("Setting up symlinks for dotfiles...");

  mkdirSync(`${HOME}/.config`, { recursive: true });
  mkdirSync(`${HOME}/.config/BeeperTexts`, { recursive: true });
  mkdirSync(`${HOME}/.local/bin`, { recursive: true });

  await createSymlink(`${DOTFILES_DIR}/.gitconfig`, `${HOME}/.gitconfig`);
  await createSymlink(`${DOTFILES_DIR}/.gitattributes`, `${HOME}/.gitattributes`);
  await createSymlink(`${DOTFILES_DIR}/.zshrc`, `${HOME}/.zshrc`);
  await createSymlink(`${DOTFILES_DIR}/.config/aerc`, `${HOME}/.config/aerc`);
  await createSymlink(`${DOTFILES_DIR}/.config/hypr`, `${HOME}/.config/hypr`);
  await createSymlink(`${DOTFILES_DIR}/.config/waybar`, `${HOME}/.config/waybar`);
  await createSymlink(`${DOTFILES_DIR}/.config/gh`, `${HOME}/.config/gh`);
  await createSymlink(`${DOTFILES_DIR}/.config/ghostty`, `${HOME}/.config/ghostty`);
  await createSymlink(`${DOTFILES_DIR}/.config/qutebrowser`, `${HOME}/.config/qutebrowser`);
  await createSymlink(`${DOTFILES_DIR}/.config/rofi`, `${HOME}/.config/rofi`);
  await createSymlink(`${DOTFILES_DIR}/.config/fastfetch`, `${HOME}/.config/fastfetch`);
  await createSymlink(`${DOTFILES_DIR}/.config/bat`, `${HOME}/.config/bat`);
  await createSymlink(`${DOTFILES_DIR}/.config/eza`, `${HOME}/.config/eza`);
  await createSymlink(`${DOTFILES_DIR}/.config/zathura`, `${HOME}/.config/zathura`);
  await createSymlink(`${DOTFILES_DIR}/.config/yazi`, `${HOME}/.config/yazi`);
  await createSymlink(`${DOTFILES_DIR}/.config/pycodestyle`, `${HOME}/.config/pycodestyle`);
  await createSymlink(`${DOTFILES_DIR}/.config/systemd`, `${HOME}/.config/systemd`);
  await createSymlink(`${DOTFILES_DIR}/.config/btop`, `${HOME}/.config/btop`);
  await createSymlink(`${DOTFILES_DIR}/.config/swaync`, `${HOME}/.config/swaync`);
  await createSymlink(`${DOTFILES_DIR}/.config/xdg-desktop-portal-termfilechooser`, `${HOME}/.config/xdg-desktop-portal-termfilechooser`);
  await createSymlink(`${DOTFILES_DIR}/.config/bluetuith`, `${HOME}/.config/bluetuith`);
  await createSymlink(`${DOTFILES_DIR}/.config/mpv`, `${HOME}/.config/mpv`);
  await createSymlink(`${DOTFILES_DIR}/.config/swayosd`, `${HOME}/.config/swayosd`);
  await createSymlink(`${DOTFILES_DIR}/.config/swayimg`, `${HOME}/.config/swayimg`);
  await createSymlink(`${DOTFILES_DIR}/.config/quickshell`, `${HOME}/.config/quickshell`);
  await createSymlink(`${DOTFILES_DIR}/.config/.lesskey`, `${HOME}/.lesskey`);
  await createSymlink(`${DOTFILES_DIR}/.zsh_functions`, `${HOME}/.zsh_functions`);

  await createSymlink(`${DOTFILES_DIR}/.config/BeeperTexts/custom.css`, `${HOME}/.config/BeeperTexts/custom.css`);
  await createSymlink(`${DOTFILES_DIR}/.config/BeeperTexts/config.json`, `${HOME}/.config/BeeperTexts/config.json`);

  await createSymlink(`${DOTFILES_DIR}/.local/bin/qutebrowser.sh`, `${HOME}/.local/bin/qutebrowser`);
  await createSymlink(`${DOTFILES_DIR}/.local/bin/crypt.sh`, `${HOME}/.local/bin/crypt`);
  await createSymlink(`${DOTFILES_DIR}/.local/bin/git-status.sh`, `${HOME}/.local/bin/git-status`);
  await createSymlink(`${DOTFILES_DIR}/.local/bin/start-hotspot.sh`, `${HOME}/.local/bin/start-hotspot`);
  await createSymlink(`${DOTFILES_DIR}/.local/bin/stop-hotspot.sh`, `${HOME}/.local/bin/stop-hotspot`);
  await createSymlink(`${DOTFILES_DIR}/.local/bin/slurp.sh`, `${HOME}/.local/bin/slurp`);

  await createSymlink(`${DOTFILES_DIR}/.local/share/fonts`, `${HOME}/.local/share/fonts`);

  await createSymlink(`${DOTFILES_DIR}/media/pictures/fastfetch.png`, `${HOME}/Pictures/fastfetch.png`);
  await createSymlink(`${DOTFILES_DIR}/media/pictures/wallpaper-mask-layer.png`, `${HOME}/Pictures/wallpaper-mask-layer.png`);
  await createSymlink(`${DOTFILES_DIR}/media/pictures/wallpaper-background-layer.jpg`, `${HOME}/Pictures/wallpaper-background-layer.jpg`);
  await createSymlink(`${DOTFILES_DIR}/media/music/notification-1.mp3`, `${HOME}/Music/notification-1.mp3`);
  await createSymlink(`${DOTFILES_DIR}/media/music/notification-2.mp3`, `${HOME}/Music/notification-2.mp3`);
  await createSymlink(`${DOTFILES_DIR}/media/music/windows-connected.mp3`, `${HOME}/Music/windows-connected.mp3`);
  await createSymlink(`${DOTFILES_DIR}/media/music/windows-disconnected.mp3`, `${HOME}/Music/windows-disconnected.mp3`);
  await createSymlink(`${DOTFILES_DIR}/media/music/battery-warning.mp3`, `${HOME}/Music/battery-warning.mp3`);
  await createSymlink(`${DOTFILES_DIR}/media/music/battery-critical.mp3`, `${HOME}/Music/battery-critical.mp3`);

  await createSudoSymlink(`${DOTFILES_DIR}/etc/ly/config.ini`, "/etc/ly/config.ini");
  await createSudoSymlink(`${DOTFILES_DIR}/etc/keyd`, "/etc/keyd");
};

// ─────────────────────────────────────────────────────────────────────────────
// Shell & Postinstall Setup
// ─────────────────────────────────────────────────────────────────────────────

const setupZsh = async () => {
  const shell = await $`basename $SHELL`.text();
  if (shell.trim() !== "zsh") {
    log("Setting Zsh as the default shell...");
    const username = await $`id -un`.text();
    const zshPath = await $`command -v zsh`.text();
    await $`sudo chsh ${username.trim()} --shell ${zshPath.trim()}`;
  } else {
    log("Zsh is already the default shell.");
  }
};

const postInstallScripts = async () => {
  await $`bat cache --build`;

  if (await checkCommand("xdg-settings")) {
    await $`xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop`;
  }

  if (await checkCommand("xdg-mime")) {
    await $`xdg-mime default org.pwmt.zathura.desktop application/pdf`;
    await $`xdg-mime default nvim.desktop text/plain inode/text application/x-empty`;
    await $`xdg-mime default swayimg.desktop image/jpeg image/png image/gif image/bmp image/webp image/svg+xml`;
  }

  try {
    await $`systemctl is-enabled keyd`.quiet();
  } catch {
    await $`sudo systemctl enable keyd`;
  }

  POSTNOTES += `${yellowText("Ly was not started.")} You can enable and start it with: systemctl enable --now ly@tty2.service\n`;

  await $`fnm completions --shell zsh > ~/.zsh_functions/_fnm`;
};

const createCleanupScript = () => {
  log("Cleanup script is pending. Complete it dude!");
};

// ─────────────────────────────────────────────────────────────────────────────
// Entrypoint
// ─────────────────────────────────────────────────────────────────────────────

const main = async () => {
  let privateMode = false;
  const flags: string[] = [];

  const args = process.argv.slice(2);
  for (const arg of args) {
    switch (arg) {
      case "-p":
      case "--private":
        privateMode = true;
        break;
      case "-nw":
        flags.push("setup_network");
        break;
      case "-pi":
        flags.push("post_install_scripts");
        break;
      case "-ln":
        flags.push("link_dotfiles");
        break;
      case "-zsh":
        flags.push("setup_zsh");
        break;
      case "-plugins":
        flags.push("install_plugins");
        break;
      case "-progs":
        flags.push("install_programs");
        break;
      case "-dirs":
        flags.push("create_directories");
        break;
    }
  }

  const runFunction = async (name: string, fn: () => void | Promise<void>) => {
    if (flags.length === 0 || flags.includes(name)) {
      await fn();
    }
  };

  await runFunction("setup_network", setupNetwork);
  await runFunction("create_directories", createDirectories);
  await runFunction("install_programs", installPrograms);
  await runFunction("setup_zsh", setupZsh);
  await runFunction("install_plugins", installPlugins);
  await runFunction("link_dotfiles", linkDotfiles);
  await runFunction("post_install_scripts", postInstallScripts);
  createCleanupScript();

  if (privateMode) {
    await installPrivatePackages();
  }

  if (SKIPPED_SYMLINKS > 0) {
    POSTNOTES += `${SKIPPED_SYMLINKS} symlink(s) were skipped because they already existed`;
  }

  console.log(POSTNOTES);
};

main().catch((err) => {
  error(`Fatal error: ${err.message}`);
  process.exit(1);
});
