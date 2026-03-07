# ─────────────────────────────────────────────────────────────────────────────
# Basic Oh-My-Zsh Setup
# ─────────────────────────────────────────────────────────────────────────────

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set the prompt theme
ZSH_THEME=""

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

# List of enabled plugins ~30ms
plugins=(
    aliases
    copypath
    dirhistory
    extract
    eza
    fzf
    gitfast
    history-substring-search
    safe-paste
    sudo
    zoxide
    zsh-autosuggestions
    zsh-interactive-cd
    zsh-syntax-highlighting
)

# ─────────────────────────────────────────────────────────────────────────────
# Source and Initialize Oh-My-Zsh
# ─────────────────────────────────────────────────────────────────────────────

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source "$ZSH/oh-my-zsh.sh" # ~70ms

# ─────────────────────────────────────────────────────────────────────────────
# Custom Prompt Theme
# ─────────────────────────────────────────────────────────────────────────────

PROMPT=$'\n%{$fg_bold[cyan]%}$( \
  local branch=$(git_prompt_info); \
  [[ -n $branch ]] && echo "%c %F{white}on %F{magenta}$branch %F{red}$(git_prompt_status)%f" || echo "%~" \
)\n%(?.%F{green}➜%f.%F{red}➜%f) %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

RPROMPT=''

ZSH_THEME_GIT_PROMPT_ADDED=" "
ZSH_THEME_GIT_PROMPT_MODIFIED=" "
ZSH_THEME_GIT_PROMPT_DELETED=" "
ZSH_THEME_GIT_PROMPT_RENAMED=" "
ZSH_THEME_GIT_PROMPT_UNMERGED=" "
ZSH_THEME_GIT_PROMPT_UNTRACKED=""

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
export VISUAL="$TERMINAL -e nvim"
alias vi=nvim

# Terminal and tools
export PNPM_HOME="$HOME/.local/share/pnpm"
export ANDROID_HOME="/opt/android-sdk"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export GEM_HOME="$HOME/.local/share/gem/ruby/3.4.0/bin"

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

# Lazy load fnm
fnm() {
  unset -f fnm node npx npm corepack
  eval "$(command fnm env)"
  fnm "$@"
}

node() {
  unset -f fnm node npx npm corepack
  eval "$(command fnm env)"
  node "$@"
}

npm() {
  unset -f fnm node npx npm corepack
  eval "$(command fnm env)"
  npm "$@"
}

npx() {
  unset -f fnm node npx npm corepack
  eval "$(command fnm env)"
  npx "$@"
}

corepack() {
  unset -f fnm node npx npm corepack
  eval "$(command fnm env)"
  corepack "$@"
}

# Load Homebrew if installed ~10ms
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ─────────────────────────────────────────────────────────────────────────────
# Custom Aliases and Functions
# ─────────────────────────────────────────────────────────────────────────────

# Fastfetch alias
alias ff=fastfetch

# Alias to run a c++ file
makecpp() {
  g++ -std=c++20 -Wall -Wextra -O2 "$1.cpp" -o "$1" && "./$1"
}

# Paru aliases
alias prs="paru -S"
alias prss="paru -Ss"
alias prsi="paru -Si"
alias prsy="paru -Sy"
alias prsyu="paru -Syu"
alias prqs="paru -Qs"
alias prqi="paru -Qi"
alias prrns="paru -Rns"

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

# Git-related
function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

alias gcm='git commit --message'
alias gcam='git commit --all --message'

# ─────────────────────────────────────────────────────────────────────────────
# Appearance Enhancements
# ─────────────────────────────────────────────────────────────────────────────

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
# Shell Integration
# ─────────────────────────────────────────────────────────────────────────────

function precmd {
    if ! builtin zle; then
        print -n "\e]133;D\e\\"
    fi
    print -Pn "\e]133;A\e\\"
}

function preexec {
    print -n "\e]133;C\e\\"
}

# ─────────────────────────────────────────────────────────────────────────────
# Custom Completion Scripts
# ─────────────────────────────────────────────────────────────────────────────

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
