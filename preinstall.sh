#!/usr/bin/env bash
echo "Bootstrap script for macOS. Please press return to start."
read -r -n 1

#### INSTALL HOMEBREW & XCODE TOOLS (necessary for git clone) ####
if [[ ! -f "$(which brew)" ]]; then
    echo "Install Homebrew & Xcode Command Line Tools."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed, skipping."
fi

#### CREATE DIRS, CLONE REPO & START MAIN INSTALL SCRIPT ####
if [[ ! -d "$HOME/.config/dotfiles" ]]; then
    mkdir "$HOME/.config/dotfiles"
fi

git clone https://github.com/fl4shback/dotfiles.git "$HOME/.config/dotfiles"

source "$HOME/.config/dotfiles/install.sh"