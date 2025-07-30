#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Ensure script is in ~/.dotfiles directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
EXPECTED_DIR="$HOME/.dotfiles"
if [ "$SCRIPT_DIR" != "$EXPECTED_DIR" ]; then
    echo -e "\e[31mError:\e[0m This script must be run from $EXPECTED_DIR"
    echo "Current location: $SCRIPT_DIR"
    exit 1
fi

# Pull updates from git
if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    if [ $# -eq 0 ] || [ "$1" != "--no-git" ]; then
        echo "==> Pulling latest changes from Git repository..."
        git pull origin main || echo "Warning: Git pull failed, continuing..."
    fi
fi

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO=$(uname -s)
fi

COLOR="\e[36m"
RED="\e[31m"
NC="\e[0m"

available=0
linked=0

link() {
    src="$1"
    dest="$2"
    available=$((available + 1))

    # Already exists (Symlink)
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo -e "${COLOR}$(basename "$dest")${NC} already linked"
        linked=$((linked + 1))
        return
    fi

    mkdir -p "$(dirname "$dest")"

    # Already exists (Not symlink)
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo -e "${RED}Warning:${NC} $dest exists and is not a symlink. Skipping."
        return
    fi

    # Linking
    if ln -sf "$src" "$dest"; then
        echo -e "${COLOR}$(basename "$dest")${NC} linked"
        linked=$((linked + 1))
    else
        echo -e "${RED}Failed${NC} to link ${COLOR}$(basename "$dest")${NC}"
    fi
}

install_yay() {
    echo -e "\n==> Installing yay"

    # Check for required tools
    if ! command -v makepkg &> /dev/null; then
        echo -e "${RED}Error:${NC} makepkg not found. Please install base-devel first:"
        echo "  sudo pacman -S base-devel"
        return 1
    fi

    # Check for git (needed for cloning)
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error:${NC} git not found. Please install git first:"
        echo "  sudo pacman -S git"
        return 1
    fi

    local tmp_dir="$SCRIPT_DIR/tmp"

    # Clone with error handling
    if ! git clone https://aur.archlinux.org/yay.git "$tmp_dir"; then
        echo -e "${RED}Error:${NC} Failed to clone yay repository"
        return 1
    fi

    cd "$tmp_dir"

    if makepkg -si --noconfirm; then
        echo -e "${COLOR}yay${NC} installed"
        cd "$SCRIPT_DIR"
        rm -rf "$tmp_dir"
        return 0
    else
        echo -e "${RED}Failed${NC} to install ${COLOR}yay${NC}"
        cd "$SCRIPT_DIR"
        rm -rf "$tmp_dir"
        return 1
    fi
}

case "$DISTRO" in
    arch)
        # yay
        if ! command -v yay &> /dev/null; then
            install_yay || echo -e "${RED}Warning:${NC} Failed to install yay, continuing..."
        else
            echo -e "${COLOR}yay${NC} already installed"
        fi
        ;;
esac

echo -e "\n==> Creating symlinks: .zshrc"
link "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
link "$SCRIPT_DIR/.zsh_aliases"  "$HOME/.zsh_aliases"
link "$SCRIPT_DIR/.zsh_commands" "$HOME/.zsh_commands"

link "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
link "$SCRIPT_DIR/nvim/" "$HOME/.config/nvim"

echo -e "\nLinking Complete: [$linked/$available] symlinks succeeded."
