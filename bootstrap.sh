#!/usr/bin/env bash
PACKAGES=(
    "expect"
    "rsync"
    "git"
    "zsh"
)

install_package() {
    if type brew &> /dev/null; then
        # macOS
        brew install "$@"
    elif type apt-get &> /dev/null; then
        # Debian-based
        sudo apt-get install -y "$@"
    elif type dnf &> /dev/null; then
        # Fedora-based
        sudo dnf install -y "$@"
    elif type yum &> /dev/null; then
        # Red Hat-based
        sudo yum install -y "$@"
    elif type apk &> /dev/null; then
        # Alpine Linux
        sudo apk add --no-cache "$@"
    elif type pacman &> /dev/null; then
        # Arch-based
        sudo pacman -Syu --noconfirm "$@"
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
if [[ $OSTYPE =~ ^darwin ]] && ! type brew >/dev/null 2>&1; then
    echo "Install Homebrew & Xcode Command Line Tools."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#### INSTALL NEEDED PACKAGES ####
for package in "${PACKAGES[@]}"; do
    if ! type "$package" >/dev/null 2>&1; then
        installpack+=("$package")
    else
        echo "already present $package"
    fi
done

if [[ "${#installpack[@]}" -gt 0 ]]; then
    install_package "${installpack[@]}"
    unset installpack
fi

#### CREATE DIRS, CLONE REPO & START MAIN INSTALL SCRIPT ####
# Should not be needed
# if [[ ! -d "$HOME/.config/dotfiles" ]]; then
#     mkdir "$HOME/.config/dotfiles"
# fi
if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
    git clone https://github.com/fl4shback/dotfiles.git "$HOME/.config/dotfiles"
else
    git -C "$SCRIPT_DIR" fetch && git -C "$SCRIPT_DIR" pull
fi

# shellcheck disable=SC1091
source "$HOME/.config/dotfiles/bootstrap_main.sh"
