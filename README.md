# Arch Linux
1. Install git.
```bash
sudo pacman -S git --needed
```
2. Clone repo into new hidden directory.
```bash
# Use SSH (if set up)...
git clone git@github.com:EmilBjorkeng/dotfiles.git ~/.dotfiles
# ...or use HTTPS and switch remotes later.
git clone https://github.com/EmilBjorkeng/dotfiles.git ~/.dotfiles
```
3. Create symlinks in the Home directory to the real files in the repo.
```
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.bashrc ~/.bashrc
ln -s ~/.dotfiles/.bash_commands ~/.bash_commands
ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases
``` 
