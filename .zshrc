# ─────────────────────────────────────────────────────────────────────────────
# Basic Oh-My-Zsh Setup
# ─────────────────────────────────────────────────────────────────────────────

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set the prompt theme
ZSH_THEME="spaceship"

# ─────────────────────────────────────────────────────────────────────────────
# Zsh Plugins Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Plugin-specific settings

# eza Plugin - options for directory listing
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' icons yes

# zsh-syntax
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89'

# List of enabled plugins
plugins=(
    aliases
    archlinux
    brew
    bun
    copyfile
    copypath
    dirhistory
    docker
    extract
    eza
    fzf
    gh
    git
    gitfast
    qrcode
    safe-paste
    sudo
    web-search
    wp-cli
    zoxide
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-interactive-cd
    zsh-syntax-highlighting
)

# ─────────────────────────────────────────────────────────────────────────────
# Source and initialize oh-my-zsh
# ─────────────────────────────────────────────────────────────────────────────

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source "$ZSH/oh-my-zsh.sh"

# ─────────────────────────────────────────────────────────────────────────────
# Spaceship Prompt Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Enable battery status in the prompt
SPACESHIP_BATTERY_SHOW="charged"
SPACESHIP_BATTERY_THRESHOLD=25
SPACESHIP_SUDO_SHOW=true

# Remove unused sections to keep prompt clean and fast
spaceship_cleanup=(
  node rust package hg bun deno ruby elm elixir xcode swift golang perl php
  haskell scala kotlin java dart julia crystal docker docker_compose aws
  gcloud azure conda uv dotnet ocaml vlang purescript erlang gleam
  kubectl ansible terraform pulumi ibmcloud nix_shell gnu_screen lua
)
spaceship remove "${spaceship_cleanup[@]}"

# ─────────────────────────────────────────────────────────────────────────────
# Key Bindings and Input Tweaks
# ─────────────────────────────────────────────────────────────────────────────

bindkey -e  # Use Emacs keybindings

# Custom sudo keybind
bindkey '^[s' sudo-command-line                     # Alt+w → delete word backward

# Custom word and line deletion
bindkey '^[w' backward-kill-word                     # Alt+w → delete word backward
bindkey '^[W' kill-whole-line                        # Alt+Shift+w → delete whole line
bindkey '^[D' kill-line                              # Alt+Shift+d → delete forward whole line

# Navigation and history search
bindkey '^[;' forward-char                           # Alt+; → move cursor right
bindkey '^[j' backward-char                          # Alt+j → move cursor left
bindkey '^[b' backward-word                          # Alt+Shift+b → move word left
bindkey '^[f' forward-word                           # Alt+Shift+f → move word right
bindkey '^[l' history-substring-search-up            # Alt+l → previous matching command
bindkey '^[k' history-substring-search-down          # Alt+k → next matching command
bindkey '^[o' dirhistory_zle_dirhistory_back         # Alt+o → previous directory
bindkey '^[i' dirhistory_zle_dirhistory_future       # Alt+i → next directory
bindkey '^[r' history-incremental-search-backward    # Alt+r → search history

# ─────────────────────────────────────────────────────────────────────────────
# History Substring Search Appearance
# ─────────────────────────────────────────────────────────────────────────────

export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=blue,fg=black,bold"
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=red,fg=black,bold"
export HISTORY_SUBSTRING_SEARCH_FUZZY="1"

# ─────────────────────────────────────────────────────────────────────────────
# User Environment Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Set default text editor
export EDITOR='nvim'
export VISUAL='ghostty -e nvim'
alias vi=nvim

# Alias to run a c++ file
makecpp() {
  eval "g++ -std=c++20 -Wall -Wextra -O2 ${1}.cpp -o ${1} && ./${1}"
}

# Paru aliases
alias prs="paru -S"
alias prss="paru -Ss"
alias prsi="paru -Si"
alias prsy="paru -Sy"
alias prqs="paru -Qs"

# Terminal and tools
export TERMINAL=ghostty
export PNPM_HOME="$HOME/.local/share/pnpm"
export ANDROID_HOME="/opt/android-sdk"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export GEM_HOME="$HOME/.local/share/gem/ruby/$(ruby -e 'print RbConfig::CONFIG["ruby_version"]' 2>/dev/null || echo 3.4.0)/bin"

# Add important paths
path_directories=(
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  "$HOME/.cargo/bin"
  "$HOME/flutter/bin"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$JAVA_HOME/bin"
  "$HOME/.local/share/webstorm/bin"
  $PNPM_HOME
  $GEM_HOME
)

for dir in "${path_directories[@]}"; do
  [[ -d $dir ]] && [[ ":$PATH:" != *":$dir:"* ]] && export PATH="$dir:$PATH"
done

# Compilation cache for completions
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/"

# Set Homebrew auto update to once per week
# 60 seconds × 60 minutes × 24 hours × 7 days = 604800 seconds
export HOMEBREW_AUTO_UPDATE_SECS=$((60 * 60 * 24 * 7))

# ─────────────────────────────────────────────────────────────────────────────
# Lazy Loading for Tools
# ─────────────────────────────────────────────────────────────────────────────

# Lazy load 'thefuck' correction tool
thefuck_lazy_load() {
  unalias fuck
  eval $(thefuck --alias)
  fuck "$@"
}
alias fuck=thefuck_lazy_load

# ─────────────────────────────────────────────────────────────────────────────
# Custom Aliases and Functions
# ─────────────────────────────────────────────────────────────────────────────

# Remove '$ ' from copied command snippets
alias '$'='_execute_command'
_execute_command() {
    local cmd="${*}"
    eval "$cmd"
}

# Insert blank space into terminal
space() {
    echo '\n\n\n\n\n\n\n\n'
}

# Launch file manager (yazi) and return to new cwd
fm() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# eza aliases
alias l='ls -a'

# Hledger config
export LEDGER_FILE=~/finance/2025.journal

# Preview files easily with bat+fzf
alias preview="fzf --preview \"bat --color=always --style=numbers --line-range=:500 {}\""

# JRNL secret logs
alias jrnl=" jrnl" # Leading space ensures it doesn't enter shell history

# ─────────────────────────────────────────────────────────────────────────────
# Appearance Enhancements
# ─────────────────────────────────────────────────────────────────────────────

# Load fnm
eval "`fnm env`"

# Load Homebrew if installed
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Set man pages viewer to use bat
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

# Customize FZF interface
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#283457 \
  --color=bg:#16161e \
  --color=border:#7dcfff \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#e0af68 \
  --color=hl+:#9ece6a \
  --color=hl:#9ece6a \
  --color=info:#414868 \
  --color=marker:#ff007c \
  --color=pointer:#7aa2f7 \
  --color=prompt:#bb9af7 \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#a9b1d6 \
  --color=separator:#414868 \
  --color=spinner:#ff007c \
  --bind=alt-k:down,alt-l:up,alt-f:page-down,alt-b:page-up,alt-q:abort,alt-w:backward-kill-word,alt-j:backward-char
"

# ─────────────────────────────────────────────────────────────────────────────
# Ghostty Shell Integration
# ─────────────────────────────────────────────────────────────────────────────

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
    source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# ─────────────────────────────────────────────────────────────────────────────
# Custom Completion Scripts
# ─────────────────────────────────────────────────────────────────────────────

[ -s "$HOME/.zsh_functions/_ghostty" ] && source "$HOME/.zsh_functions/_ghostty"
[ -s "$HOME/.zsh_functions/_gitpod" ] && source "$HOME/.zsh_functions/_gitpod"
[ -s "$HOME/.zsh_functions/_mods" ] && source "$HOME/.zsh_functions/_mods"
[ -s "$HOME/.zsh_functions/_pipx" ] && source "$HOME/.zsh_functions/_pipx"
[ -s "$HOME/.zsh_functions/_fnm" ] && source "$HOME/.zsh_functions/_fnm"

# ─────────────────────────────────────────────────────────────────────────────
# Special Key Bindings
# ─────────────────────────────────────────────────────────────────────────────

# Bind A+A+E (Alt+e) to run AI Chat on current buffer
_aichat_zsh() {
    if [[ -n "$BUFFER" ]]; then
        local _old=$BUFFER
        BUFFER+="  "
        zle end-of-line
        zle -I && zle redisplay
        BUFFER=$(aichat -e "$_old")
        zle end-of-line
    fi
}
zle -N _aichat_zsh
bindkey '\ee' _aichat_zsh

# ─────────────────────────────────────────────────────────────────────────────
# Shell Behavior Tweaks
# ─────────────────────────────────────────────────────────────────────────────

# Don't save commands starting with a space in history
setopt HIST_IGNORE_SPACE
