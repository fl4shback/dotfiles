OS=$(uname -s)
ARCH=$(uname -m)
BREW_PREFIX=$(brew --prefix 2>/dev/null)

### HOMEBREW CUSTOM PATH ###
if [[ $OS == Darwin ]]; then
  add_to_path() {
    [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
  }
  if [[ $ARCH == arm64 ]]; then
    add_to_path /opt/homebrew/bin
    add_to_path /opt/homebrew/sbin
    add_to_path /opt/homebrew/opt/coreutils/libexec/gnubin
  else
    add_to_path /usr/local/opt/coreutils/libexec/gnubin
  fi
fi

### START COMMANDS ###
#if [[ ! $TMUX ]]; then
#  if [[ -z $(tmux list-sessions 2> /dev/null) ]]; then
#    tmux
#  else
#    tmux a
#  fi
#fi

# Set ls color flag based on platform
if command ls --color=auto &>/dev/null; then
  LS_COLOR_FLAG="--color=auto"
else
  LS_COLOR_FLAG="-G"
fi

# Run fastfetch if present
command -v fastfetch &>/dev/null && fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
 
### ALIASES ###
# Global aliases (work anywhere in command)
alias -g G='| grep'
alias -g L='| less -RFX'
alias -g H='| head'
alias -g T='| tail'
alias -g NE='2>/dev/null'
# Normal aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias chx="chmod +x"
alias ls="ls $LS_COLOR_FLAG"
alias la="ls -a"
alias ll="ls -l"
alias lla="ls -la"
alias pip="pip3"
alias python="python3"
alias tree="tree -C"
alias treef='tree --prune -aP'
alias vimc="vi $XDG_CONFIG_HOME/dotfiles/.vimrc"
alias zshc="vi $ZDOTDIR/.zshrc && source $ZDOTDIR/.zshrc"
if [[ $HOST == *Victor* ]]; then
  alias brewcun="brew uninstall --zap"
  alias rapprochement="bash $HOME/Documents/Scripts/rapprochement.sh"
  alias virement="bash $HOME/Documents/Scripts/virements.sh"
fi

### SHELL OPTIONS ###
# Directory navigation
setopt AUTO_CD              # Type directory name to cd into it
setopt AUTO_PUSHD           # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack
# Named directories - shortcuts that work in ANY command (not just cd)
# Usage: cd ~docs, ls ~dl, cp file.txt ~proj
# Unlike aliases, these expand to full paths everywhere
# hash -d docs=$HOME/Documents
# hash -d dl=$HOME/Downloads
# hash -d dt=$HOME/Desktop
# Command correction
setopt CORRECT              # Suggest corrections for mistyped commands
setopt CORRECT_ALL          # Also correct arguments (disable if annoying)
# Job control
setopt AUTO_RESUME          # Resume jobs with their name
setopt NOTIFY               # Report job status immediately
setopt LONG_LIST_JOBS       # Show detailed job information

### CUSTOM FUNCTIONS ###
mcdir () {
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If .venv folder is found then activate the vitualenv
    if [[ -d ./.venv ]] ; then
      source ./.venv/bin/activate
    fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    parentdir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parentdir"/* ]] ; then
      deactivate
    fi
  fi
}

### macOS ONLY FUNCTIONS ###
if [[ $OS == "Darwin" ]]; then
  defender() {
    case "$1" in
      off)
        echo "Enabling passive mode (disables monitoring)..."
        sudo mdatp config passive-mode --value enabled
        sudo mdatp config behavior-monitoring --value disabled
        sudo mdatp config network-protection enforcement-level --value disabled
        echo "\nCurrent status:"
        echo "Passive mode: $(mdatp health --field passive_mode_enabled)"
        echo "Behavior monitoring: $(mdatp health --field behavior_monitoring)"
        echo "Network protection: $(mdatp health --field network_protection_status)"
        ;;
      on)
        echo "Disabling passive mode (enables monitoring)..."
        sudo mdatp config passive-mode --value disabled
        sudo mdatp config behavior-monitoring --value enabled
        echo "\nCurrent status:"
        mdatp health --field passive_mode_enabled
        mdatp health --field real_time_protection_enabled
        mdatp health --field behavior_monitoring
        ;;
      status)
        echo "=== Defender Status ==="
        echo "Passive mode: $(mdatp health --field passive_mode_enabled)"
        echo "Real-time protection: $(mdatp health --field real_time_protection_enabled)"
        echo "Behavior monitoring: $(mdatp health --field behavior_monitoring)"
        echo "Network protection: $(mdatp health --field network_protection_status)"
        echo "Tamper protection: $(mdatp health --field tamper_protection)"
        ;;
      *)
        echo "Usage: defender {on|off|status}"
        return 1
        ;;
    esac
  }

  update () {
    brew cu -aqy --no-quarantine
    brew upgrade
    brew cleanup
    mas upgrade
    softwareupdate -i -a --agree-to-license
  }
fi

### SOURCE PLUGINS / THEMES ###
source $ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme


### AUTOCOMPLETE ###
# Load completions
[[ -n $BREW_PREFIX ]] && FPATH="$BREW_PREFIX/share/zsh/site-functions:${FPATH}"

# Call before compinit
zmodload zsh/complist

# Init completion
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;
_comp_options+=(globdots)		# Include hidden files.

### Autocompletion for defender function
_defender() {
    local -a subcmds
    subcmds=(
    'on:Enable defender'
    'off:Disable defender'
    'status:Show defender status'
    )
    _describe 'defender' subcmds
}

compdef _defender defender

# Cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/"

# Options
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu

# Zstyles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

### P10K CONFIG ###
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $ZDOTDIR/.p10k.zsh ]] || source $ZDOTDIR/.p10k.zsh

### Syntax highlighting
# Must be a the end of the config file
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
