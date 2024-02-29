#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")";

if [ $# -eq 0 -o "$1" != "--no-git" ]; then
    git pull origin main
fi

echo '1) Minimal (gitconfig, nvim)'
echo '2) Base Install (Minimal, yay, bashrc+)'
echo '3) Hyprland (Base Install, hypr, waybar, alacritty, fuzzel)'
read -p "Enter a selection (default=2): " sel
echo ''

minimal () { 
    if ln -s ~/.dotfiles/.gitconfig ~/.gitconfig; then
        echo '.gitconfig linked'
    fi
    if ln -s ~/.dotfiles/nvim/ ~/.config/; then
        echo '.config/nvim/ linked'
    fi
}

base () {
	if ln -s ~/.dotfiles/.bashrc ~/.bashrc; then
        echo '.bashrc linked'
    fi
	if ln -s ~/.dotfiles/.bash_commands ~/.bash_commands; then
        echo '.bash_commands linked'
    fi
	if ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases; then
        echo '.bash_aliases linked'
    fi
}

yay () {
    echo 'Installing yay...'
    git clone https://aur.archlinux.org/yay.git ~/.dotfiles/tmp
    cd tmp
    makepkg -si
    cd ..
    sudo rm -r tmp
}

hypr () {
    if ln -s ~/.dotfiles/hypr/ ~/.config/; then
        echo '.config/hypr/ linked'
    fi
	if ln -s ~/.dotfiles/waybar/ ~/.config/; then
        echo '.config/waybar/ linked'
    fi
	if ln -s ~/.dotfiles/alacritty/ ~/.config/; then
        echo '.config/alacritty/ linked'
    fi
    if ln -s ~/.dotfiles/fuzzel/ ~/.config/; then
        echo '.config/fuzzel/ linked'
    fi
}

case $sel in
    # Minimal
	"1" )
        echo 'Creating symlinks...'
        minimal

        echo ''
        echo 'Symlinks created' ;;
    # Base Install
	"2" | "" )
        echo 'Installing software...'
        yay
        
        echo ''
        echo 'Creating symlinks...'
        minimal
        base

        echo ''
        echo 'Symlinks created' ;;
    # Hyprland
	"3" )
        echo 'Installing software...'
        sudo pacman -S hyprland waybar alacritty fuzzel wl-clipboard --needed
        yay
        
        echo ''
        echo 'Creating symlinks...'
		minimal
		base
        hypr

        echo ''
        echo 'Symlinks created' ;;
	* )
		echo 'Aborting Install...' ;;
esac
