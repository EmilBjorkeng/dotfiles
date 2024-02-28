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
3.1. For automatic install run the bootstrap script.
```bash
cd .dotfiles
./bootstrap.sh
```

3.2. For manual install run the command for all the dotfiles you want linked.
```bash
# Change FILENAME with the name of the dotfile you want
ln -s ~/.dotfiles/.FILENAME ~/.FILENAME
```
