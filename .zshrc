# Path to my Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Prompt theme
ZSH_THEME="spaceship"

# Spaceship specific config
# Disable rust section
SPACESHIP_RUST_SHOW=false
# Disable package section for all package managers
SPACESHIP_PACKAGE_SHOW=false
# Disable Node.js section
SPACESHIP_NODE_SHOW=false
# Enable battery status
SPACESHIP_BATTERY_SHOW="charged"
SPACESHIP_BATTERY_THRESHOLD=25
# Enabled timestamps
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_FORMAT='%D{%d %b}, %T'

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Delete a whole word when pressing ctrl+backspace
bindkey '^H' backward-kill-word

# Oh My Zsh plugins
plugins=(
    aliases
    bun # Code completion
    copyfile # Copy target file content
    copypath # Copy taeget path
    dirhistory
    gh # Code completion
    sudo # Double escape to prefix with sudo
    web-search
    zoxide # Auto jumps
    zsh-autosuggestions # Command completion
    zsh-history-substring-search # Up arrow key for search
    zsh-interactive-cd # Use fzf for entering directories
    zsh-syntax-highlighting # Command syntax colors
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

#  TODO: Move custom aliases to $ZSH_CUSTOM

export PNPM_HOME="$HOME/.local/share/pnpm"

# Define an array of directories to add to the PATH
path_directories=(
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
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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

# Alias zoxide to the default change directory command
alias cd=z
