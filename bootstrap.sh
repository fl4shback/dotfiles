#!/usr/bin/env bash

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "Error: This script should not be run as root"
   echo "Package managers will request sudo when needed"
   exit 1
fi

CONFIG_DIR="$HOME/.config"
PACKAGES=(
    "expect"
    "rsync"
    "git"
    "zsh"
    "fastfetch"
)

install_package() {
    if command -v brew &> /dev/null; then
        # macOS
        brew install "$@"
    elif command -v apt-get &> /dev/null; then
        # Debian-based
        sudo apt-get install -y "$@"
    elif command -v dnf &> /dev/null; then
        # Fedora-based
        sudo dnf install -y "$@"
    elif command -v yum &> /dev/null; then
        # Red Hat-based
        sudo yum install -y "$@"
    elif command -v apk &> /dev/null; then
        # Alpine Linux
        sudo apk add --no-cache "$@"
    elif command -v pacman &> /dev/null; then
        # Arch-based
        sudo pacman -S --noconfirm "$@"
    else
        echo "Error: Unsupported Package manager, please update script."
        return 1
    fi
}

echo "Bootstrap script. Please press return to start."
read -r -n 1

#### macOS INSTALL BREW & XCODE TOOLS ####
# macOS doesn't come with git preinstalled, we need to install XCode Command Line Tools
# This is handled automatically by the Brew install which is needed later anyway
if [[ $OSTYPE =~ ^darwin ]] && ! command -v brew >/dev/null 2>&1; then
    echo "Install Homebrew & Xcode Command Line Tools."
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "Error: Homebrew installation failed"
        exit 1
    fi
fi

#### INSTALL NEEDED PACKAGES ####
installpack=()
for package in "${PACKAGES[@]}"; do
    if ! command -v "$package" >/dev/null 2>&1; then
        installpack+=("$package")
    fi
done

if [[ "${#installpack[@]}" -gt 0 ]]; then
    install_package "${installpack[@]}"
fi

#### CREATE DIRS, CLONE REPO & START MAIN INSTALL SCRIPT ####
if [[ ! -d "$CONFIG_DIR/dotfiles/.git" ]]; then
    git clone https://github.com/fl4shback/dotfiles.git "$HOME/.config/dotfiles"
else
    git -C "$CONFIG_DIR/dotfiles/" fetch && git -C "$CONFIG_DIR/dotfiles/" pull
fi

# shellcheck disable=SC1091
source "$HOME/.config/dotfiles/bootstrap_main.sh"
