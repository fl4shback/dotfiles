#!/usr/bin/env bash
#### GLOBAL VARIABLES ####
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
BACKUP_DIR="$SCRIPT_DIR/backup"
# SSH_DIR="$HOME/.ssh"
CONFIG_DIR="$HOME/.config"

APPS=(
    "http://files.dahua.support/Oprogramowanie/SmartPSS%20Apple/General_SMARTPSS-MAC-arm64_ChnEng_IS_V2.003.0000006.0.R.20211213.tar.gz"
    "https://www.dropbox.com/s/c51t7y5kh7za2kl/Deluge.app.7z"
    "https://www.pixeleyes.co.nz/automounter/helper/AutoMounterHelper.dmg"
    "https://cherpake.com/downloads/Remote-for-Mac-6303.pkg.zip"
)
FONTS=(
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
)
DOTFILES=(
    ".tmux.conf"
    ".gitconfig"
)
ZSHFILES=(
    ".p10k.zsh"
    ".zshrc"
)

if [[ $(uname -m) == "arm64" ]]; then
    export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH
else
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
fi

GNULN="$(brew --prefix)/opt/coreutils/libexec/gnubin/ln"
GNUPG="$(brew --prefix)/bin/gpg"

#### BREW DISABLE ANALYTICS & INSTALL PACKAGES ####
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
if [[ ! -f "$SCRIPT_DIR/Dl.lock" ]]; then
    for entry in "${APPS[@]}"
    do
        echo "Downloading $entry"
        curl -sSLO --output-dir "$HOME/Downloads" "$entry"
    done
    touch "$SCRIPT_DIR/Dl.lock"
else
    echo "Dl.lock file is present, skipping manual downloads"
fi

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

#### INSTALL FONTS ####
for font in "${FONTS[@]}"; do
    strip_url=${font##*/}
    file_name=${strip_url//%20/ }
    curl -sSL "$font" -o "$HOME/Library/Fonts/$file_name"
done

#### CHECK BACKUP DIR ####
if [[ ! -d $BACKUP_DIR ]]; then
    echo "Please import backup folder and press return to continue"
    open "$SCRIPT_DIR"
    read -r -n 1
fi

#### IMPORT & TRUST GPG KEYS ####
if [[ -d "$BACKUP_DIR/gpg" ]]; then
    echo "Import and trust GPG Keys"
    gpg --import-options restore --import "$BACKUP_DIR/gpg/private.gpg"
    gpg --import-options restore --import "$BACKUP_DIR/gpg/public.gpg"
    PUBID=$("gpg" --list-keys --keyid-format LONG | awk '/pub/{if (length($2) > 0) print $2}')
    SECID=$("gpg" --list-secret-keys --keyid-format LONG | awk '/sec/{if (length($2) > 0) print $2}')
    expect -c "spawn "gpg" --edit-key ${PUBID##*/} trust quit; send ""5\ry\r""; expect eof"
    expect -c "spawn "gpg" --edit-key ${SECID##*/} trust quit; send ""5\ry\r""; expect eof"

fi

#### IMPORT SSH KEYS ####
if [[ -d "$BACKUP_DIR/.ssh" ]]; then
    echo "Import SSH Config & Keys"
    rsync -a "$BACKUP_DIR/.ssh" "$HOME"
fi

#### SYMLINK .extras FILE ####
if [[ -f $BACKUP_DIR/.extras ]]; then
    ln -rs "$BACKUP_DIR/.extras" "$CONFIG_DIR/zsh/.extras"
fi

#### SYMLINK karabiner FILE ####
if [[ ! -d "$CONFIG_DIR/karabiner" ]]; then
    mkdir "$CONFIG_DIR/karabiner"
    ln -rs "$SCRIPT_DIR/karabiner.json" "$CONFIG_DIR/karabiner/karabiner.json"
fi