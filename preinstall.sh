#!/usr/bin/env bash
echo "Bootstrap script for macOS. Please press any key to start."
read -r

# Install Homebrew
if [[ ! -f "$(which brew)" ]]; then
    echo "Install Homebrew & Xcode Command Line Tools."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed, skipping."
fi

if [[ ! -d "$HOME/.config/dotfiles" ]]; then
    mkdir "$HOME/.config/dotfiles"
fi
git clone https://github.com/fl4shback/dotfiles.git "$HOME/.config/dotfiles"
source "$HOME/.config/dotfiles/install.sh"