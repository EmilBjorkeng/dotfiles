#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main

echo '1) Linux minimal (gitconfig)'
echo '2) Arch Linux (Minimal[1], bashrc+)'
echo '3) Arch Hyprland (Arch[2], hypr, waybar, alacritty, fuzzel)'
read -p "Enter a selection (default=1): " sel
echo ''

case $sel in
    # Linux minimal
	"1" | "" )
        echo 'Creating symlinks...'
		if ln -s ~/.dotfiles/.gitconfig ~/.gitconfig; then
            echo '.gitconfig linked'
        fi

        echo ''
        echo 'Symlinks created' ;;
    # Arch Linux
	"2" )
        echo 'Creating symlinks...'
		if ln -s ~/.dotfiles/.gitconfig ~/.gitconfig; then
            echo '.gitconfig linked'
        fi
		if ln -s ~/.dotfiles/.bashrc ~/.bashrc; then
            echo '.bashrc linked'
        fi
		if ln -s ~/.dotfiles/.bash_commands ~/.bash_commands; then
            echo '.bash_commands linked'
        fi
		if ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases; then
            echo '.bash_aliases linked'
        fi
        
        echo ''
        echo 'Symlinks created' ;;
    # Arch Hyprland
	"3" )
        echo 'Installing software...'
        sudo pacman -S hyprland waybar alacritty fuzzel --needed
        echo 'Software installed'
        echo ''

        echo 'Creating symlinks...'
		if ln -s ~/.dotfiles/.gitconfig ~/.gitconfig; then
            echo '.gitconfig linked'
        fi
		if ln -s ~/.dotfiles/.bashrc ~/.bashrc; then
            echo '.bashrc linked'
        fi
        if ln -s ~/.dotfiles/.bash_commands ~/.bash_commands; then
            echo '.bash_commands linked'
        fi
        if ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases; then
            echo '.bash_aliases linked'
        fi
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
        
        echo ''
        echo 'Symlinks created' ;;
	* )
		echo 'Aborting Install...' ;;
esac
