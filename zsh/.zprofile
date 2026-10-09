typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" $path)

export LANG=en_GB.UTF-8

if (( $+commands[nvim] )); then
    export EDITOR=nvim
elif (( $+commands[vim] )); then
    export EDITOR=vim
else
    export EDITOR=nano
fi
export VISUAL=$EDITOR

# Start Hyprland when logging in on tty1
if [[ -z $WAYLAND_DISPLAY && -z $DISPLAY && $TTY == /dev/tty1 ]] \
    && (( $+commands[start-hyprland] )); then
    exec start-hyprland
fi
