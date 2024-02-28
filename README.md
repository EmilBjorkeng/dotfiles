# dotfiles
1. Update system.
```
sudo pacman -Syu
```
2. Install git and base development packages.
```bash
sudo pacman -S git base-devel --needed
```
3. Clone repo into new hidden directory.
```bash
# Use SSH (if set up)...
git clone git@github.com:EmilBjorkeng/dotfiles.git ~/.dotfiles
# ...or use HTTPS and switch remotes later.
git clone https://github.com/EmilBjorkeng/dotfiles.git ~/.dotfiles
```
4. Create the symlinks.

For automatic install run bootstrap script.
```bash
cd ~/.dotfiles
./bootstrap.sh
```

For manual install run linking command for all dotfiles or config folders you want linked.
```bash
# FILES: Replace FILENAME with the name of the dotfile you want
ln -s ~/.dotfiles/.FILENAME ~/
# FOLDERS: Replace FOLDERNAME with the name of the config folder you want
ln -s ~/.dotfiles/FOLDERNAME/ ~/.config/
```
