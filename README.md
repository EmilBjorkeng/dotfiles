# dotfiles
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
3. Create the symlinks.

For automatic install run the bootstrap script.
```bash
cd .dotfiles
./bootstrap.sh
```

For manual install run a link command for all the dotfiles you want linked.
```bash
# FILES: Change FILENAME with the name of the dotfile you want
ln -s ~/.dotfiles/.FILENAME ~/.FILENAME
# FOLDERS: Change FOLDERNAME with the name of the config folder you want
ln -s ~/.dotfiles/FOLDERNAME/ ~/.config/
```
