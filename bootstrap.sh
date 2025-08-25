#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Ensure script is in ~/.dotfiles directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
EXPECTED_DIR="$HOME/.dotfiles"
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
    local basename_dest="$(basename "$dest")"

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

    # Handle existing files/directories
    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then
            log_warning "$dest is a symlink to $(readlink "$dest"), replacing..."
            rm "$dest"
        else
            # Backup existing file
            local backup="$dest.backup.$(date +%Y%m%d_%H%M%S)"
            log_warning "$dest exists, backing up to $backup"
            if ! mv "$dest" "$backup"; then
                log_error "Failed to backup $dest"
                return 1
            fi
        fi
    fi

    # Create symlink
    if ln -sf "$src" "$dest"; then
        echo -e "${COLOR}${basename_dest}${NC} linked"
        linked=$((linked + 1))
        return 0
    else
        log_error "Failed to link ${basename_dest}"
        return 1
    fi
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
        log_error "Missing dependencies: ${missing_deps[*]}"
        echo -e "Please install them first: sudo pacman -S ${missing_deps[*]}"
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    local original_dir="$PWD"

    # Cleanup function
    cleanup_yay() {
        cd "$original_dir"
        rm -rf "$tmp_dir"
    }

    # Set trap for cleanup
    trap cleanup_yay EXIT

    # Clone and build yay
    if git clone https://aur.archlinux.org/yay.git "$tmp_dir"; then
        cd "$tmp_dir"
        if makepkg -si --noconfirm; then
            echo -e "${COLOR}yay${NC} installed successfully"
            return 0
        else
            log_error "Failed to build yay"
            return 1
        fi
    else
        log_error "Failed to clone yay repository"
        return 1
    fi
}

# Install oh-my-zsh



install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${COLOR}oh-my-zsh${NC} already installed"
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

    # Download and install oh-my-zsh
    local install_script
    if command -v curl &> /dev/null; then
        install_script=$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)
    else
        install_script=$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)
    fi

    if [ -n "$install_script" ]; then
        # Run the installer in unattended mode
        sh -c "$install_script" "" --unattended
        if [ $? -eq 0 ]; then
            echo -e "${COLOR}oh-my-zsh${NC} installed successfully"
            return 0
        else
            log_error "Failed to install oh-my-zsh"
            return 1
        fi
    else
        log_error "Failed to download oh-my-zsh installer"
        return 1
    fi
}

# Install oh-my-zsh plugins
install_zsh_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plugins_dir="$zsh_custom/plugins"

    echo -e "\n==> Installing ${COLOR}oh-my-zsh${NC} plugins..."

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_warning "${COLOR}oh-my-zsh${NC} not found, skipping plugin installation"
        return 1
    fi

    mkdir -p "$plugins_dir"

    # Array of plugins to install
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
        "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
    )

    for plugin_info in "${plugins[@]}"; do
        local plugin_name="${plugin_info%%:*}"
        local plugin_url="${plugin_info##*:}"
        local plugin_dir="$plugins_dir/$plugin_name"

        if [ -d "$plugin_dir" ]; then
            echo -e "${COLOR}${plugin_name}${NC} already installed, updating..."
            cd "$plugin_dir" && git pull
        else
            echo -e "Installing ${COLOR}$plugin_name${NC}..."
            if git clone "$plugin_url" "$plugin_dir"; then
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
        ".zshrc:$HOME/.zshrc"
        ".zsh_aliases:$HOME/.zsh_aliases"
        ".zsh_functions:$HOME/.zsh_functions"
        ".zsh_compleations:$HOME/.zsh_compleations"
        ".gitconfig:$HOME/.gitconfig"
        "nvim/:$HOME/.config/nvim"
    )

    echo -e "\n==> Creating symlinks..."

    local zsh_was_linked=false
    for config in "${configs[@]}"; do
        local src_file="${config%%:*}"
        local dest_file="${config##*:}"

        if link "$SCRIPT_DIR/$src_file" "$dest_file"; then
            if [[ "$src_file" == ".zshrc" ]]; then
                zsh_was_linked=true
            fi
        fi
    done

    # Install zsh plugins if .zshrc was newly linked
    if $zsh_was_linked; then
        # Install oh-my-zsh first ig not present
        install_oh_my_zsh
        install_zsh_plugins
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
            ;;
    esac
}

main() {
    echo -e "==> Starting dotfiles installation..."
    echo ""

    validate_location
    update_repository "$@"

    local distro
    distro=$(detect_distro)
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
