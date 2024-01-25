#!/usr/bin/env bash
echo "Bootstrap script. Please press return to start."
read -r -n 1

#### macOS INSTALL BREW & XCODE TOOLS ####
# macOS doesn't come with git preinstalled, we need to install XCode Command Line Tools
# This is handled automatically by the Brew install which is needed later anyway
if [[ $OSTYPE =~ ^darwin ]] && ! type brew >/dev/null 2>&1; then
    echo "Install Homebrew & Xcode Command Line Tools."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#### Linux INSTALL GIT IF NEEDED ####
# Inspired from https://ilhicas.com/2018/08/08/bash-script-to-install-packages-multiple-os.html
function install_package () {
    declare -A osInfo;
    osInfo[/etc/debian_version]="apt-get install -y"
    osInfo[/etc/alpine-release]="apk --update add"
    osInfo[/etc/centos-release]="yum install -y"
    osInfo[/etc/fedora-release]="dnf install -y"

    for f in "${!osInfo[@]}"
    do
        if [[ -f $f ]];then
            package_manager=${osInfo[$f]}
        fi
    done

    $package_manager "$@"
}
if ! type git >/dev/null 2>&1; then
    install_package git
fi

#### CREATE DIRS, CLONE REPO & START MAIN INSTALL SCRIPT ####
# Should not be needed
# if [[ ! -d "$HOME/.config/dotfiles" ]]; then
#     mkdir "$HOME/.config/dotfiles"
# fi

git clone https://github.com/fl4shback/dotfiles.git "$HOME/.config/dotfiles"

# shellcheck disable=SC1091
source "$HOME/.config/dotfiles/bootstrap_main.sh"
