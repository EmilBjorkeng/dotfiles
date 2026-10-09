# Paths
export ZSH="$HOME/.local/share/oh-my-zsh"
ZSH_CONFIG="$HOME/.dotfiles/zsh"
ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p ${ZSH_COMPDUMP:h}

ZSH_THEME=""

typeset -U path fpath
fpath=("$ZSH_CONFIG/completions" $fpath)

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
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

# Keybinds
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

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
# setopt CORRECT                # Command correction
# setopt CORRECT_ALL            # Argument correction

# Other useful options
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shell
setopt NO_BEEP                  # No beeping
setopt MULTIOS                  # Multiple redirections
setopt PROMPT_SUBST             # Parameter expansion in prompts

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

unset LS_COLORS

for file in "$ZSH_CONFIG"/{aliases,functions,completions}.zsh; do
    [[ -r "$file" ]] && source "$file"
done

_jotta_ignore_hidden() {
    local -a keep pats
    local out p
    keep=(.dotfiles .ssh .zsh_history)
    out=$(jotta-cli ignores list 2>/dev/null) || return
    pats=(${${(f)out}#*> })
    for p in ~/.*(N:t); do
        (( ${keep[(Ie)$p]} )) && continue
        (( ${pats[(Ie)$p]} )) && continue
        jotta-cli ignores add --pattern "$p" >/dev/null 2>&1
    done
}
_jotta_ignore_hidden &!
