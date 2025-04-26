# ─────────────────────────────────────────────────────────────────────────────
# Basic Oh-My-Zsh Setup
# ─────────────────────────────────────────────────────────────────────────────

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set the prompt theme
ZSH_THEME="spaceship"

# Source Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# ─────────────────────────────────────────────────────────────────────────────
# Spaceship Prompt Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Enable battery status in the prompt
SPACESHIP_BATTERY_SHOW="charged"
SPACESHIP_BATTERY_THRESHOLD=25

# Remove unused sections to keep prompt clean and fast
spaceship_cleanup=(
  node rust package hg bun deno ruby elm elixir xcode swift golang perl php
  haskell scala kotlin java dart julia crystal docker docker_compose aws
  gcloud azure conda uv dotnet ocaml vlang purescript erlang gleam
  kubectl ansible terraform pulumi ibmcloud nix_shell gnu_screen lua
)
spaceship remove "${spaceship_cleanup[@]}"

# ─────────────────────────────────────────────────────────────────────────────
# Zsh Plugins Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Plugin-specific settings

# Alias Finder Plugin - enable extended search
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

# eza Plugin - options for directory listing
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' icons yes

# List of enabled plugins
plugins=(
    aliases
    alias-finder
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
# Key Bindings and Input Tweaks
# ─────────────────────────────────────────────────────────────────────────────

bindkey -e  # Use Emacs keybindings

# Custom word and line deletion
bindkey '^[w' backward-kill-word                     # Alt+w → delete word backward
bindkey '^[W' kill-whole-line                        # Alt+Shift+w → delete whole line
bindkey '^[D' kill-line                              # Alt+Shift+d → delete forward whole line

# Navigation and history search
bindkey '^[;' forward-char                           # Alt+; → move cursor right
bindkey '^[j' backward-char                          # Alt+j → move cursor left
bindkey '^[B' backward-word                          # Alt+Shift+b → move word left
bindkey '^[F' forward-word                           # Alt+Shift+f → move word right
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
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
alias vi=nvim

# Terminal and tools
export TERMINAL=ghostty
export PNPM_HOME="$HOME/.local/share/pnpm"
export ANDROID_HOME="$HOME/Android/Sdk"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"

# Add important paths
path_directories=(
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  "$HOME/.cargo/bin"
  "$HOME/flutter/bin"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$JAVA_HOME/bin"
  "/root/.local/share/gem/ruby/3.2.0/bin"
  "$HOME/.local/share/gem/ruby/3.3.0/bin"
  "$HOME/.java/jre1.8.0_431/bin"
  "$HOME/.local/share/webstorm/bin"
  $PNPM_HOME
)

for dir in "${path_directories[@]}"; do
  [[ -d $dir ]] && [[ ":$PATH:" != *":$dir:"* ]] && export PATH="$dir:$PATH"
done

# Compilation cache for completions
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/"

# ─────────────────────────────────────────────────────────────────────────────
# Lazy Loading for Tools
# ─────────────────────────────────────────────────────────────────────────────

# Lazy load NVM
nvm_lazy_load() {
  unset -f nvm nvm_lazy_load
  source /usr/share/nvm/init-nvm.sh
  nvm "$@"
}
alias nvm=nvm_lazy_load
alias node=nvm_lazy_load
alias npm=nvm_lazy_load
alias npx=nvm_lazy_load

# Lazy load 'thefuck' correction tool
thefuck_lazy_load() {
  unset -f fuck thefuck_lazy_load
  eval $(thefuck --alias)
  fuck "$@"
}
alias fuck=thefuck_lazy_load

# Lazy load pipx autocomplete
_lazy_pipx() {
  eval "$(register-python-argcomplete pipx)"
  compdef _pipx pipx
  zle redisplay
}
compdef _lazy_pipx pipx

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
alias 'space'='_add_space'
_add_space() {
    echo '\n\n\n\n\n\n\n\n'
}

# Launch file manager (yazi) and return to new cwd
function fm() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Taskwarrior TUI aliases
export TASKRC="$HOME/.config/taskwarrior/taskrc"
export TASKDATA="$HOME/.local/share/taskwarrior"
alias tt=taskwarrior-tui
alias t=task

# Gitpod alias
alias gp=gitpod

# Preview files easily with bat+fzf
alias preview="fzf --preview \"bat --color=always --style=numbers --line-range=:500 {}\""

# Print a fortune message with cowsay
alias wisdom="fortune | cowsay"

# JRNL secret logs
alias jrnl=" jrnl" # Leading space ensures it doesn't enter shell history

# ─────────────────────────────────────────────────────────────────────────────
# Appearance Enhancements
# ─────────────────────────────────────────────────────────────────────────────

# Fetch system information on shell startup
fastfetch

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
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
  --bind=alt-k:down,alt-l:up,alt-f:page-down,alt-b:page-up,alt-q:abort,alt-w:backward-kill-word,alt-j:backward-char
"

# ─────────────────────────────────────────────────────────────────────────────
# Custom Completion Scripts
# ─────────────────────────────────────────────────────────────────────────────

[ -s "$HOME/.zsh_functions/_ghostty" ] && source "$HOME/.zsh_functions/_ghostty"
[ -s "$HOME/.zsh_functions/_gitpod" ] && source "$HOME/.zsh_functions/_gitpod"
[ -s "$HOME/.zsh_functions/_mods" ] && source "$HOME/.zsh_functions/_mods"

# ─────────────────────────────────────────────────────────────────────────────
# Special Key Bindings
# ─────────────────────────────────────────────────────────────────────────────

# Bind A+A+E (Alt+e) to run AI Chat on current buffer
_aichat_zsh() {
    if [[ -n "$BUFFER" ]]; then
        local _old=$BUFFER
        BUFFER+="⌛"
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
