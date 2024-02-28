#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main

echo '1) Linux minimal (gitconfig)'
echo '2) Arch Linux (Minimal, bashrc)'
read -p "Enter a selection (default=1): " sel
echo ''

case $sel in
	"1" | "" )
        echo 'Creating symlinks...'
		ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
        echo '.gitconfig linked'

        echo ''
        echo 'Symlinks created' ;;
	"2" )
        echo 'Creating symlinks...'
		ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
        echo '.gitconfig linked'
		ln -s ~/.dotfiles/.bashrc ~/.bashrc
        echo '.bashrc linked'
		ln -s ~/.dotfiles/.bash_commands ~/.bash_commands
        echo '.bash_commands linked'
		ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases
        echo '.bash_aliases linked'
        
        echo ''
        echo 'Symlinks created' ;;
	* )
		echo 'Aborting Install...' ;;
esac
