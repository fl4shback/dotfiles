#!/usr/bin/env bash
echo "Bootstrap script. Please press return to start."
read -r -n 1

#### INSTALL HOMEBREW & XCODE TOOLS (necessary for git clone) ####
if [[ $OSTYPE =~ ^darwin ]] && [[ ! -f "$(which brew)" ]]; then
        echo "Install Homebrew & Xcode Command Line Tools."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#### CREATE DIRS, CLONE REPO & START MAIN INSTALL SCRIPT ####
# Should not be needed
# if [[ ! -d "$HOME/.config/dotfiles" ]]; then
#     mkdir "$HOME/.config/dotfiles"
# fi

git clone https://github.com/fl4shback/dotfiles.git "$HOME/.config/dotfiles"


# shellcheck disable=SC1091
source "$HOME/.config/dotfiles/bootstrap_main.sh"
