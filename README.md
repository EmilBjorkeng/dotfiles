# dotfiles
### 1. Update system
```bash
# Arch
sudo pacman -Syu
# Ubuntu
sudo apt-get update && sudo apt-get upgrade
```
### 2. Install git and base development packages
```bash
# Arch
sudo pacman -S git base-devel --needed
# Ubuntu
sudo apt-get install git build-essential
```
### 3. Clone repo into new hidden directory
```bash
# Use SSH (if set up)...
git clone git@github.com:EmilBjorkeng/dotfiles.git ~/.dotfiles
# ...or use HTTPS and switch remotes later.
git clone https://github.com/EmilBjorkeng/dotfiles.git ~/.dotfiles
```
Set up SSH
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "emil.bjorkeng@gmail.com"

# Start the SSH agent
eval "$(ssh-agent -s)"

# Add private key to the SSH agent
ssh-add ~/.ssh/id_ed25519

# Display the public key
cat ~/.ssh/id_ed25519.pub
# Copy everything starting from 'ssh-ed25519' including the email

# Add the key to:
# Github > Setting > SSH and GPG Keys > New SSH Key

# Test the SSH connection (optional)
ssh -T git@github.com
```

### 4. Create the symlinks

For automatic install run bootstrap script
```bash
cd ~/.dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

For manual install run linking command for all dotfiles or config folders you want linked
```bash
# FILES: Replace FILENAME with the name of the dotfile you want
ln -sf ~/.dotfiles/.FILENAME ~/
# FOLDERS: Replace FOLDERNAME with the name of the config folder you want
ln -sf ~/.dotfiles/FOLDERNAME/ ~/.config/
```
