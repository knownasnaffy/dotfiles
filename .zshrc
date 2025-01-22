# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# lukerandall
# ZSH_THEME="random"
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

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Delete a whole word when pressing ctrl+backspace
bindkey '^H' backward-kill-word

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    aliases
    bun # Code completion
    copyfile
    copypath
    dirhistory
    gh # Code completion
    sudo
    web-search
    z
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-interactive-cd
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PNPM_HOME="/home/knownasnaffy/.local/share/pnpm"

# Define an array of directories to add to the PATH
path_directories=(
  "$HOME/.bun/bin" # Bun
  "/root/.local/share/gem/ruby/3.2.0/bin" # Gem modules (system-wide)
  "/home/knownasnaffy/.local/share/gem/ruby/3.3.0/bin" # Gem modules (user-specific)
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
[ -s "/home/knownasnaffy/.bun/_bun" ] && source "/home/knownasnaffy/.bun/_bun"
