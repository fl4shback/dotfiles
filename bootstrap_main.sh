#!/usr/bin/env bash
#### GLOBAL VARIABLES ####
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
BACKUP_DIR="$SCRIPT_DIR/backup"
CONFIG_DIR="$HOME/.config"

# Apps to download that are not tracked by package managers
APPS=(
    "https://www.pixeleyes.co.nz/automounter/helper/AutoMounterHelper.dmg"
    "https://downloads.cherpake.com/Remote-for-Mac-7513.pkg.zip"
)
# Fonts needed for zsh theme powerlevel10k
FONTS=(
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
)

# Symlink mappings: "source_file" or "source_file:custom/dest/path"
# Default destination is $HOME/source_file
# Use colon to specify different destination (relative to $HOME or absolute)
SYMLINKS=(
    ".gitconfig"
    ".gitconfig_fl4shforward"
    ".tmux.conf"
    ".vimrc"
    ".zshenv"
    "config.jsonc:.config/fastfetch/config.jsonc"
    ".p10k.zsh:.config/zsh/.p10k.zsh"
    ".zshrc:.config/zsh/.zshrc"
    "karabiner.json:.config/karabiner/karabiner.json"
)

safe_symlink() {
    local source="$1"
    local dest="$2"
    local dest_dir

    dest_dir="$(dirname "$dest")"

    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
    fi

    if [[ -e "$dest" ]] && [[ ! -L "$dest" ]]; then
        echo "Warning: $dest exists and is not a symlink, skipping"
    else
        ln -sf "$source" "$dest"
    fi
}

cross_open() {
    # Takes 2 args $1 is path $2 is message to display in tty
    if [[ $OSTYPE =~ ^darwin ]]; then
        echo "${2}"
        open "${1}"
    elif [[ -z $DISPLAY && -z $WAYLAND_DISPLAY ]];then
        echo "${2}${1}"
    else
        echo "${2}"
        xdg-open "${1}"
    fi
}

#### macOS Specifics ####
if [[ $OSTYPE =~ ^darwin ]]; then
    FONT_FOLDER="$HOME/Library/Fonts"

    # Export brew paths needed to access GNU ls & gpg
    if [[ $(uname -m) == "arm64" ]]; then
        export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH
    else
        export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
    fi

    #### BREW DISABLE ANALYTICS & INSTALL PACKAGES ####
    # Disable analytics
    if [[ "$(brew analytics state)" =~ enabled ]]; then
        brew analytics off
        echo "Disabled Hombrew analytics."
    fi

    # Install packages, casks and mas apps
    if [[ ! -f "$SCRIPT_DIR/Brewfile.lock.json" ]]; then
        echo "Installing Homebrew packages from Brewfile"
        brew bundle install --file "$SCRIPT_DIR/Brewfile"
    else
        echo "Brewfile.lock exists, skipping brew packages installation"
    fi

    #### DOWNLOAD APPS ####
    if [[ ! -f "$SCRIPT_DIR/Apps.lock" ]]; then
        for entry in "${APPS[@]}"
        do
            echo "Downloading $entry"
            curl -sSLO --output-dir "$HOME/Downloads" "$entry"
        done
        touch "$SCRIPT_DIR/Apps.lock"
    else
        echo "Apps.lock file is present, skipping manual downloads"
    fi

fi

#### CREATE SYMLINKS ####
for entry in "${SYMLINKS[@]}"; do
    # Split on colon to get source and optional destination
    if [[ "$entry" == *:* ]]; then
        source_file="${entry%%:*}"
        dest_path="${entry#*:}"
        # If destination is relative and doesn't start with /, prepend $HOME/
        if [[ "$dest_path" != /* ]]; then
            dest_path="$HOME/$dest_path"
        fi
    else
        source_file="$entry"
        dest_path="$HOME/$entry"
    fi

    safe_symlink "$SCRIPT_DIR/$source_file" "$dest_path"
done

# ZSH Plugins
if [[ ! -d "$CONFIG_DIR/zsh/plugins/powerlevel10k" ]]; then
    git clone https://github.com/romkatv/powerlevel10k.git "$CONFIG_DIR/zsh/plugins/powerlevel10k" || echo "Error: Failed to clone powerlevel10k"
else
    echo "Powerlevel10k already exists, skipping"
fi

if [[ ! -d "$CONFIG_DIR/zsh/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CONFIG_DIR/zsh/plugins/zsh-syntax-highlighting" || echo "Error: Failed to clone zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already exists, skipping"
fi

#### INSTALL FONTS ####
FONT_FOLDER="${FONT_FOLDER:-/usr/local/share/fonts}"
for font in "${FONTS[@]}"; do
    strip_url=${font##*/}
    file_name=${strip_url//%20/ }

    if [[ $OSTYPE =~ ^darwin ]]; then
        # macOS - no sudo needed for user fonts
        curl -sSL "$font" --create-dirs --output "$FONT_FOLDER/$file_name" || echo "Error: Failed to download $file_name"
    else
        # Linux - sudo needed for system fonts
        sudo curl -sSL "$font" --create-dirs --output "$FONT_FOLDER/$file_name" || echo "Error: Failed to download $file_name"
        sudo chmod a+rx "$FONT_FOLDER"
    fi
done

#### CHECK BACKUP DIR ####
if [[ ! -d $BACKUP_DIR ]]; then
    # Linux terminal-only: auto-search for backup on USB drives
    if [[ ! $OSTYPE =~ ^darwin ]] && [[ -z $DISPLAY && -z $WAYLAND_DISPLAY ]]; then
        echo "Backup folder not found. Searching mounted drives..."
        found_backups=()

        # Search common mount points for backup folder
        for mount_point in /media/"$USER"/* /mnt/* /run/media/"$USER"/*; do
            if [[ -d "$mount_point/backup" ]]; then
                found_backups+=("$mount_point/backup")
            fi
        done

        if [[ ${#found_backups[@]} -gt 0 ]]; then
            echo "Found backup folder(s):"
            for i in "${!found_backups[@]}"; do
                echo "  $((i+1)). ${found_backups[$i]}"
            done
            echo -n "Select backup folder (1-${#found_backups[@]}) or Enter to skip: "
            read -r selection

            if [[ $selection =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#found_backups[@]} ]]; then
                selected_backup="${found_backups[$((selection-1))]}"
                echo "Copying backup from $selected_backup to $BACKUP_DIR"
                cp -r "$selected_backup" "$BACKUP_DIR"
            fi
        else
            echo "No backup folders found on mounted drives."
            echo "Please copy backup folder to $BACKUP_DIR and press return to continue..."
            read -r -n 1
        fi
    else
        # macOS or Linux with GUI: open file manager
        cross_open "$SCRIPT_DIR" "Please import backup folder and press return to continue: "
        read -r -n 1
    fi
fi

#### IMPORT & TRUST GPG KEYS ####
if [[ -d "$BACKUP_DIR/gpg" ]]; then
    echo "Import and trust GPG Keys"

    # Ensure .gnupg directory exists with correct permissions
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"

    # Set GPG to use loopback pinentry for non-interactive use
    if [[ ! $OSTYPE =~ ^darwin ]]; then
        # Linux: configure GPG agent for non-interactive use
        mkdir -p "$HOME/.gnupg"
        echo "allow-loopback-pinentry" >> "$HOME/.gnupg/gpg-agent.conf"
        gpgconf --kill gpg-agent 2>/dev/null || true
    fi

    if gpg --import-options restore --import "$BACKUP_DIR/gpg/private.gpg" && \
       gpg --import-options restore --import "$BACKUP_DIR/gpg/public.gpg"; then
        PUBID=$(gpg --list-keys --keyid-format LONG | awk '/pub/{if (length($2) > 0) print $2}')
        SECID=$(gpg --list-secret-keys --keyid-format LONG | awk '/sec/{if (length($2) > 0) print $2}')

        # Trust keys using expect
        if [[ -n "$PUBID" ]]; then
            GPG_TTY=$(tty)
            export GPG_TTY
            expect -c "spawn gpg --edit-key ${PUBID##*/} trust quit; send \"5\ry\r\"; expect eof" || echo "Warning: Failed to trust public key"
        fi
        if [[ -n "$SECID" ]]; then
            GPG_TTY=$(tty)
            export GPG_TTY
            expect -c "spawn gpg --edit-key ${SECID##*/} trust quit; send \"5\ry\r\"; expect eof" || echo "Warning: Failed to trust secret key"
        fi
    else
        echo "Error: Failed to import GPG keys"
    fi
fi

#### IMPORT SSH KEYS ####
if [[ -d "$BACKUP_DIR/.ssh" ]]; then
    echo "Import SSH Config & Keys"
    rsync -a "$BACKUP_DIR/.ssh" "$HOME"
    # Since ssh keys are deployed, we can update the repo url to use ssh
    git -C "$SCRIPT_DIR" remote set-url origin git@github.com:fl4shback/dotfiles.git
fi
