# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
#ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Enable colors
autoload -U colors && colors

PS1="%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ "

export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Directory navigation
setopt AUTO_CD                  # Just type directory name to cd
setopt AUTO_PUSHD               # Push directories to stack automatically
setopt PUSHD_IGNORE_DUPS        # Don't push duplicates
setopt PUSHD_SILENT             # Don't print stack after pushd/popd

# Globbing
setopt EXTENDED_GLOB            # Extended globbing patterns
setopt GLOB_DOTS                # Include dotfiles in globs
setopt NUMERIC_GLOB_SORT        # Sort numeric filenames numerically
setopt NO_CASE_GLOB             # Case-insensitive globbing

# History
setopt EXTENDED_HISTORY         # Save timestamps in history
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicates first
setopt HIST_IGNORE_DUPS         # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicates
setopt HIST_IGNORE_SPACE        # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS       # Remove extra spaces
setopt HIST_SAVE_NO_DUPS        # Don't save duplicates to file
setopt HIST_VERIFY              # Show expanded history before executing
setopt INC_APPEND_HISTORY       # Add commands immediately
setopt SHARE_HISTORY            # Share history between sessions

# Completion
setopt COMPLETE_IN_WORD         # Complete from both ends
setopt ALWAYS_TO_END            # Move cursor to end after completion
setopt AUTO_MENU                # Show completion menu on tab
setopt AUTO_LIST                # List choices on ambiguous completion
setopt AUTO_PARAM_SLASH         # Add slash after directory completions

# Correction
setopt CORRECT                  # Command correction
# setopt CORRECT_ALL            # Argument correction

# Other useful options
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shell
setopt NO_BEEP                  # No beeping
setopt MULTIOS                  # Multiple redirections
setopt PROMPT_SUBST             # Parameter expansion in prompts

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Load and initialize compleation system
autoload -Uz compinit
compinit

# Completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Group matches and describe
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy matching
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -cF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

alias yay='yay --color=auto'
alias ping='ping -c 5'

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
[ -f ~/.zsh_functions ] && source ~/.zsh_functions
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
