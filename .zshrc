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

if command -v nvim >/dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
elif command -v vim >/dev/null; then
    export EDITOR='vim'
    export VISUAL='vim'
else
    export EDITOR='nano'
    export VISUAL='nano'
fi

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

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
setopt NULL_GLOB                # Delete glob patterns that don't match

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

for file in ~/.zsh/{aliases,functions,completions}.zsh; do
    [[ -r "$file" ]] && source "$file"
done
