# Locations
ZSH_CONFIG=${${(%):-%x}:A:h}
export ZSH="$HOME/.local/share/oh-my-zsh"
ZSH_CACHE_DIR="$HOME/.cache/zsh"
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION"
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p "$ZSH_CACHE_DIR"

# oh-my-zsh
ZSH_THEME=""

typeset -U path fpath
fpath=("$ZSH_CONFIG/completions" $fpath)

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
)

source "$ZSH/oh-my-zsh.sh"

# Prompt: user@host:dir$
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Keybinds: up/down search history for what's already typed
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
unsetopt SHARE_HISTORY          # oh-my-zsh turns this on; keeps the up arrow local
unsetopt INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME  # Save each command (with duration) when it finishes
setopt EXTENDED_HISTORY         # Save timestamps
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicates
setopt HIST_IGNORE_SPACE        # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS       # Remove extra spaces
setopt HIST_SAVE_NO_DUPS        # Don't save duplicates to file
setopt HIST_VERIFY              # Show expanded history before executing

# Completion
setopt COMPLETE_IN_WORD         # Complete from both ends
setopt ALWAYS_TO_END            # Move cursor to end after completion
setopt AUTO_MENU                # Show completion menu on tab
setopt AUTO_LIST                # List choices on ambiguous completion
setopt AUTO_PARAM_SLASH         # Add slash after directory completions

# Other
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shell
setopt NO_BEEP                  # No beeping

unset LS_COLORS

for file in "$ZSH_CONFIG"/{aliases,functions,completions,local}.zsh; do
    [[ -r $file ]] && source "$file"
done
