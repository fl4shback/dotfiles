#!/usr/bin/env bash

#### GLOBAL VARIABLES ####
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
BACKUP_DIR="$SCRIPT_DIR/backup"
SSH_DIR="$HOME/.ssh"

#### DUMP Brewfile if macOS ####
if [[ $OSTYPE =~ ^darwin ]]; then
    echo "Dumping Brewfile"
    brew bundle dump --force --file "$SCRIPT_DIR/Brewfile"
fi

#### BACKUP GPG KEYS ####
# Creates backup folder if needed, deletes old backup if existing
if [[ ! -d "$BACKUP_DIR/gpg" ]]; then
    mkdir "$BACKUP_DIR/gpg"
else
    find "$BACKUP_DIR/gpg" -name "*.gpg" -delete
    echo "Delete old GPG keys backup"
fi

# Back up gpg keys
echo "Backup GPG Keys"
gpg -o "$BACKUP_DIR/gpg/private.gpg" --export-options backup --export-secret-keys fl4shback@outlook.com
gpg -o "$BACKUP_DIR/gpg/public.gpg" --export-options backup --export fl4shback@outlook.com

#### BACKUP SSH KEYS ####
if [[ -d  $SSH_DIR ]]; then
    echo "Backup SSH keys"
    rsync -a "$SSH_DIR" "$BACKUP_DIR"
fi
