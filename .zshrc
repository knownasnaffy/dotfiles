# Path to my Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Prompt theme
ZSH_THEME="spaceship"

# Spaceship specific config
# Enable battery status
SPACESHIP_BATTERY_SHOW="charged"
SPACESHIP_BATTERY_THRESHOLD=25

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

FRONTEND_SEARCH_FALLBACK='duckduckgo'

zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' icons yes

# Oh My Zsh plugins
plugins=(
    aliases
    alias-finder
    archlinux
    brew
    bun # Code completion
    copyfile # Copy target file content
    copypath # Copy taeget path
    dirhistory
    docker
    extract
    eza
    fzf
    gh # Code completion
    git
    gitfast
    qrcode
    safe-paste
    sudo # Double escape to prefix with sudo
    web-search
    wp-cli
    zoxide # Auto jumps
    zsh-autosuggestions # Command completion
    zsh-history-substring-search # Up arrow key for search
    zsh-interactive-cd # Use fzf for entering directories
    zsh-syntax-highlighting # Command syntax colors
)

source $ZSH/oh-my-zsh.sh

spaceship remove node rust package hg bun deno ruby elm elixir xcode swift golang perl php haskell scala kotlin java dart julia crystal docker docker_compose aws gcloud azure conda uv dotnet ocaml vlang purescript erlang gleam  hg bun deno ruby elm elixir xcode swift golang perl php haskell scala kotlin java dart julia crystal docker docker_compose aws gcloud azure conda uv dotnet ocaml vlang purescript erlang gleam kubectl ansible terraform pulumi ibmcloud nix_shell gnu_screen lua

bindkey -e  # Use Emacs keybindings (default)

# Delete a whole word when pressing ctrl+backspace
bindkey '^[w' backward-kill-word    # Alt+w → Delete word backward
bindkey '^[W' kill-whole-line  # Alt+Shift+W → Delete whole line
bindkey '^[D' kill-line  # A+S+d → Delete forward whole line
bindkey '^[;' forward-char          # Alt+; → Right Arrow
bindkey '^[l' history-substring-search-up     # Alt+l → Up Arrow
bindkey '^[k' history-substring-search-down   # Alt+k → Down Arrow
bindkey '^[j' backward-char          # Alt+j → Left Arrow
bindkey '^[B' backward-word  # Alt+Shift+B → Move one word left
bindkey '^[F' forward-word   # Alt+Shift+F → Move one word right
bindkey '^[o' dirhistory_zle_dirhistory_back          # Previous directory in history (Alt+o)
bindkey '^[i' dirhistory_zle_dirhistory_future           # Next directory in history (Alt+i)
bindkey '^[r' history-incremental-search-backward  # Alt+R → Search history

export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=blue,fg=black,bold"
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=red,fg=black,bold"
export HISTORY_SUBSTRING_SEARCH_FUZZY="1"

# User configuration

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

alias vi=nvim

export TERMINAL=ghostty

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

#  TODO: Move custom aliases to $ZSH_CUSTOM

export PNPM_HOME="$HOME/.local/share/pnpm"

# Define an array of directories to add to the PATH
path_directories=(
  "$HOME/.local/bin"
  "$HOME/.bun/bin" # Bun
  "/root/.local/share/gem/ruby/3.2.0/bin" # Gem modules (system-wide)
  "$HOME/.local/share/gem/ruby/3.3.0/bin" # Gem modules (user-specific)
  "$HOME/.java/jre1.8.0_431/bin" # Java
  "$HOME/.local/share/webstorm/bin" # Webstorm
  $PNPM_HOME # Pnpm
)

# Iterate over the array and add each directory to PATH
for dir in "${path_directories[@]}"; do
  [[ -d $dir ]] && [[ ":$PATH:" != *":$dir:"* ]] && export PATH="$dir:$PATH"
done

# NVM related config
source /usr/share/nvm/init-nvm.sh

# Too lazy to remove the '$ ' from the copied online code snippets
alias '$'='_execute_command'

_execute_command() {
    local cmd="${*}"  # Capture all arguments
    eval "$cmd"       # Execute the command
}

alias 'space'='_add_space'

_add_space() {
    echo '\n\n\n\n\n\n\n\n'
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# completions
[ -s "$HOME/.zsh_functions/_ghostty" ] && source "$HOME/.zsh_functions/_ghostty"
[ -s "$HOME/.zsh_functions/_gitpod" ] && source "$HOME/.zsh_functions/_gitpod"
[ -s "$HOME/.zsh_functions/_mods" ] && source "$HOME/.zsh_functions/_mods"
[ -s "$HOME/.zsh_functions/_alacritty" ] && source "$HOME/.zsh_functions/_alacritty"

# Custom alias for ranger file manager
function fm() {
	local tmp="$(mktemp -t ranger_cd.XXX)" cwd
	ranger --choosedir="$tmp" -- "${@:-$PWD}"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Taskwarrior related variables
export TASKRC=~/.config/taskwarrior/taskrc TASKDATA=~/.local/share/taskwarrior

alias tt=taskwarrior-tui
alias t=task

# Don't log commands starting with a space
setopt HIST_IGNORE_SPACE

# Don't log jrnl commands by prefixing with a space
alias jrnl=" jrnl"

# Fun commands
alias wisdom="fortune | cowsay"

# Print system information
fastfetch

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

alias gp=gitpod

eval $(thefuck --alias)

# export BAT_THEME=base16
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

alias preview="fzf --preview \"bat --color=always --style=numbers --line-range=:500 {}\""

# Fzf config
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

eval "$(register-python-argcomplete pipx)"

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
