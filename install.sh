#!/usr/bin/env bash
echo "Bootstrap script for macOS. Please press any key to start."
read -r

#### GLOBAL VARIABLES ####
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
BACKUP_DIR="$SCRIPT_DIR/backup"
# SSH_DIR="$HOME/.ssh"
CONFIG_DIR="$XDG_CONFIG_HOME"
APPS=(
    "https://dahuawiki.com/images/Files/Software/OSX/General_SMARTPSS-MAC_ChnEng_IS_V2.003.0000005.0.R.20210129.tar.gz"
    "https://www.dropbox.com/s/c51t7y5kh7za2kl/Deluge.app.7z"
    "https://www.pixeleyes.co.nz/automounter/helper/AutoMounterHelper.dmg"
    "https://cherpake.com/downloads/Remote-for-Mac-6303.pkg.zip"
)
DOTFILES=(
    ".tmux.conf"
    ".gitconfig"
)
ZSHFILES=(
    ".p10k.zsh"
    ".zshrc"
    ".extras"
)

#### HOMEBREW, XCODE TOOLS & MAS ####
# Install Homebrew
if [[ ! -f "$(which brew)" ]]; then
    echo "Install Homebrew & Xcode Command Line Tools."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed, skipping."
fi

# Disable analytics
if [[ "$(brew analytics state)" = "Analytics are disabled." ]]; then
    echo "Hombrew analytics are off."
else
    brew analytics off
    echo "Disabled Hombrew analytics."
fi

# Install packages; casks and mas apps
if [[ ! -f "$SCRIPT_DIR/Brewfile.lock.json" ]]; then
    echo "Installing Homebrew packages from Brewfile"
    brew bundle install --file "$SCRIPT_DIR/Brewfile"
else
    echo "Brewfile.lock exists, skipping brew packages installation"
fi

#### DOWNLOAD APPS ####
# Place urls in APPS array in GLOBAL VARIABLES
for entry in "${APPS[@]}"
do
    echo "Downloading $entry"
    curl -sSLO --output-dir "$HOME/Downloads" "$entry"
done

#### INSTALL DOTFILES ####
# Create symlinks for dotfiles
for file in "${DOTFILES[@]}"; do
    ln -rs "$SCRIPT_DIR/$file" "$HOME/$file"
done

#### INSTALL ZSH FILES ####
# ZSH dotfiles
if [[ ! -d "$CONFIG_DIR/zsh" ]]; then
    mkdir "$CONFIG_DIR/zsh"
fi

# Symlink home zshenv file
ln -rs "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"

# Symlink other zsh files
for file in "${ZSHFILES[@]}"; do
    ln -rs "$SCRIPT_DIR/$file" "$CONFIG_DIR/zsh/$file"
done

# ZSH Plugins
git clone https://github.com/romkatv/powerlevel10k.git "$CONFIG_DIR/zsh/plugins/powerlevel10k"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CONFIG_DIR/zsh/plugins/zsh-syntax-highlighting"

#### IMPORT & TRUST GPG KEYS ####
if [[ -d "$BACKUP_DIR/gpg" ]]; then
    echo "Import and trust GPG Keys"
    gpg --import-options restore --import "$BACKUP_DIR/private.gpg"
    gpg --import-options restore --import "$BACKUP_DIR/public.gpg"
    PUBID=$(gpg --list-keys --keyid-format LONG | awk '/pub/{if (length($2) > 0) print $2}')
    SECID=$(gpg --list-secret-keys --keyid-format LONG | awk '/sec/{if (length($2) > 0) print $2}')
    expect -c "spawn gpg --edit-key ${PUBID##*/} trust quit; send ""5\ry\r""; expect eof"
    expect -c "spawn gpg --edit-key ${SECID##*/} trust quit; send ""5\ry\r""; expect eof"

fi

#### IMPORT SSH KEYS ####
if [[ -d "$BACKUP_DIR/.ssh" ]]; then
    echo "Import SSH Config & Keys"
    rsync -a "$BACKUP_DIR/.ssh" "$HOME"
fi