#!/usr/bin/env bash

#### GLOBAL VARIABLES ####
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
echo "$SCRIPT_DIR"
BACKUP_DIR="$SCRIPT_DIR/backup"
SSH_DIR="$HOME/.ssh"

#### DUMP Brewfile ####
echo "Dumping Brewfile"
brew bundle dump --force --file "$SCRIPT_DIR/Brewfile"

#### BACKUP GPG KEYS ####
# Check if backup folder exists, if not, creates it
if [[ ! -d "$BACKUP_DIR/gpg" ]]; then
    mkdir "$BACKUP_DIR/gpg"
fi

# Deletes old backups if existing
if [[ -f "$BACKUP_DIR/gpg/private.gpg" ]]; then
 rm "$BACKUP_DIR/gpg/private.gpg"
 echo "Delete old private GPG key backup"
fi
if [[ -f "$BACKUP_DIR/gpg/public.gpg" ]]; then
 rm "$BACKUP_DIR/gpg/public.gpg"
 echo "Delete old public GPG key backup"
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
