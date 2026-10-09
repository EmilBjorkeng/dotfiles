#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Ensure script is in ~/.dotfiles directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
EXPECTED_DIR="$HOME/.dotfiles"

# oh-my-zsh location (must match ZSH in zsh/.zshrc)
OMZ_DIR="$HOME/.local/share/oh-my-zsh"

COLOR="\e[36m"
RED="\e[31m"
NC="\e[0m"

# Counters
available=0
linked=0

log_warning() {
    echo -e "${RED}Warning:${NC} $1"
}

log_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Ensure script is in the ~/.dotfiles directory
validate_location() {
    if [ "$SCRIPT_DIR" != "$EXPECTED_DIR" ]; then
        log_error "This script must be run from $EXPECTED_DIR"
        echo -e "Current location: $SCRIPT_DIR"
        exit 1
    fi
}

# Pull updates from git
update_repository() {
    if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
        if [ $# -eq 0 ] || [ "$1" != "--no-git" ]; then
            echo -e "==> Pulling latest changes from Git repository..."
            if git pull origin main; then
                echo -e "Repository updated"
            else
                log_warning "Git pull failed, continuing..."
            fi
        fi
    fi
}

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        uname -s
    fi
}

link() {
    local src="$1"
    local dest="$2"
    local basename_dest
    basename_dest="$(basename "$dest")"

    available=$((available + 1))

    # Check if source exists
    if [ ! -e "$src" ]; then
        log_error "Source file/directory $src does not exist"
        return 1
    fi

    # Already exists and is correct symlink
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo -e "${COLOR}${basename_dest}${NC} already linked"
        linked=$((linked + 1))
        return 0
    fi

    # Create parent directory
    if ! mkdir -p "$(dirname "$dest")"; then
        log_error "Failed to create parent directory for $dest"
        return 1
    fi

    # Handle existing files/directories (including broken symlinks)
    if [ -L "$dest" ]; then
        log_warning "$dest is a symlink to $(readlink "$dest"), replacing..."
        rm "$dest"
    elif [ -e "$dest" ]; then
        local backup
        backup="$dest.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "$dest exists, backing up to $backup"
        if ! mv "$dest" "$backup"; then
            log_error "Failed to backup $dest"
            return 1
        fi
    fi

    # Create symlink
    if ln -s "$src" "$dest"; then
        echo -e "${COLOR}${basename_dest}${NC} linked"
        linked=$((linked + 1))
        return 0
    else
        log_error "Failed to link ${basename_dest}"
        return 1
    fi
}

# Remove symlinks left over from the old flat zsh layout
cleanup_old_links() {
    local old
    for old in .zsh_aliases .zsh_functions .zsh_compleations; do
        if [ -L "$HOME/$old" ] && [ "$(readlink "$HOME/$old")" = "$SCRIPT_DIR/$old" ]; then
            rm "$HOME/$old"
            echo -e "Removed old link ${COLOR}${old}${NC}"
        fi
    done
}

# Install yay AUR helper for Arch Linux
install_yay() {
    echo -e "\n==> Installing yay AUR helper..."

    # Check for required tools
    local missing_deps=()
    if ! command -v makepkg &> /dev/null; then
        missing_deps+=("base-devel")
    fi
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps
        deps="$(IFS=' '; echo "${missing_deps[*]}")"
        log_error "Missing dependencies: $deps"
        echo -e "Please install them first: sudo pacman -S $deps"
        return 1
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local status=0

    # Clone and build yay in a subshell, so the cd doesn't leak out
    if git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"; then
        if (cd "$tmp_dir/yay" && makepkg -si --noconfirm); then
            echo -e "${COLOR}yay${NC} installed successfully"
        else
            log_error "Failed to build yay"
            status=1
        fi
    else
        log_error "Failed to clone yay repository"
        status=1
    fi

    rm -rf "$tmp_dir"
    return $status
}

# Install oh-my-zsh
install_oh_my_zsh() {
    if [ -d "$OMZ_DIR" ]; then
        echo -e "${COLOR}oh-my-zsh${NC} already installed"
        return 0
    fi

    # Move an install from the old default location
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_warning "Found oh-my-zsh in ~/.oh-my-zsh, moving it to $OMZ_DIR"
        mkdir -p "$(dirname "$OMZ_DIR")"
        mv "$HOME/.oh-my-zsh" "$OMZ_DIR"
        return 0
    fi

    echo -e "\n==> Installing ${COLOR}oh-my-zsh${NC}..."

    # Check for required tools
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        log_error "Neither curl nor wget found. Please install one of them first."
        return 1
    fi

    if ! command -v zsh &> /dev/null; then
        log_error "zsh not found. Please install zsh first."
        return 1
    fi

    # Download the installer
    local url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    local install_script=""
    if command -v curl &> /dev/null; then
        install_script="$(curl -fsSL "$url")" || install_script=""
    else
        install_script="$(wget -qO- "$url")" || install_script=""
    fi

    if [ -z "$install_script" ]; then
        log_error "Failed to download oh-my-zsh installer"
        return 1
    fi

    # --keep-zshrc stops the installer from replacing the linked .zshrc
    mkdir -p "$(dirname "$OMZ_DIR")"
    if ZSH="$OMZ_DIR" sh -c "$install_script" "" --unattended --keep-zshrc; then
        echo -e "${COLOR}oh-my-zsh${NC} installed successfully"
        return 0
    else
        log_error "Failed to install oh-my-zsh"
        return 1
    fi
}

# Install or update oh-my-zsh plugins
install_zsh_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$OMZ_DIR/custom}/plugins"

    echo -e "\n==> Installing ${COLOR}oh-my-zsh${NC} plugins..."

    if [ ! -d "$OMZ_DIR" ]; then
        log_warning "${COLOR}oh-my-zsh${NC} not found, skipping plugin installation"
        return 1
    fi

    mkdir -p "$plugins_dir"

    # name:url (the url is everything after the first colon)
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
        "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
    )

    local plugin_info plugin_name plugin_url plugin_dir
    for plugin_info in "${plugins[@]}"; do
        plugin_name="${plugin_info%%:*}"
        plugin_url="${plugin_info#*:}"
        plugin_dir="$plugins_dir/$plugin_name"

        if [ -d "$plugin_dir" ]; then
            echo -e "${COLOR}${plugin_name}${NC} already installed, updating..."
            git -C "$plugin_dir" pull --quiet || log_warning "Failed to update ${plugin_name}"
        else
            echo -e "Installing ${COLOR}${plugin_name}${NC}..."
            if git clone --quiet "$plugin_url" "$plugin_dir"; then
                echo -e "${COLOR}${plugin_name}${NC} installed"
            else
                log_error "Failed to install ${COLOR}${plugin_name}${NC}"
            fi
        fi
    done
}

# Link configuration files
link_configs() {
    local configs=(
        "zsh/.zshenv:$HOME/.zshenv"
        "zsh/.zprofile:$HOME/.zprofile"
        "zsh/.zshrc:$HOME/.zshrc"
        ".gitconfig:$HOME/.gitconfig"
        "nvim/:$HOME/.config/nvim"
        "clangd/:$HOME/.config/clangd"
        "eza/:$HOME/.config/eza"
    )

    echo -e "\n==> Creating symlinks..."
    local zshrc_linked=false
    local config src_file dest_file
    for config in "${configs[@]}"; do
        src_file="${config%%:*}"
        dest_file="${config#*:}"
        if link "$SCRIPT_DIR/$src_file" "$dest_file"; then
            if [ "$src_file" = "zsh/.zshrc" ]; then
                zshrc_linked=true
            fi
        fi
    done

    cleanup_old_links

    # oh-my-zsh and plugins are only needed when the zsh config is in place
    if $zshrc_linked; then
        if install_oh_my_zsh; then
            install_zsh_plugins || true
        fi
    fi
}

# Distribution-specific setup
setup_distro() {
    local distro="$1"

    case "$distro" in
        arch)
            if ! command -v yay &> /dev/null; then
                if install_yay; then
                    echo -e "${COLOR}yay${NC} setup completed"
                else
                    log_warning "${COLOR}yay${NC} installation failed, continuing..."
                fi
            else
                echo -e "${COLOR}yay${NC} already installed"
            fi

            local configs=(
                "hypr/:$HOME/.config/hypr"
                "waybar/:$HOME/.config/waybar"
                "swaync/:$HOME/.config/swaync"
                "alacritty/:$HOME/.config/alacritty"
                "wofi/:$HOME/.config/wofi"
            )

            echo -e "\n==> Creating Arch symlinks..."
            local config src_file dest_file
            for config in "${configs[@]}"; do
                src_file="${config%%:*}"
                dest_file="${config#*:}"
                link "$SCRIPT_DIR/$src_file" "$dest_file" || true
            done
            ;;
    esac
}

main() {
    echo -e "==> Starting dotfiles installation..."
    echo ""

    validate_location
    update_repository "$@"

    local distro
    distro="$(detect_distro)"
    echo -e "Detected distribution: ${COLOR}${distro}${NC}"

    setup_distro "$distro"
    link_configs

    echo ""
    if [ $linked -eq $available ]; then
        echo -e "Installation complete! ${COLOR}All${NC} $linked/$available symlinks created successfully."
    else
        log_warning "Installation complete with issues: $linked/$available symlinks succeeded."
    fi
}

# Run main function with all arguments
main "$@"
