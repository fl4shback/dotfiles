
### CUSTOM PATH ###
if [[ $(uname -m) == "arm64" ]]; then
  export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH
else
  export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
fi

### START COMMANDS ###
 if [[ ! $(tmux list-sessions) ]]; then
   tmux
 fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### ALIASES ###
alias afk="osascript -e 'tell application \"System Events\" to keystroke \"q\" using {command down,control down}'"
alias brewcun="brew uninstall --zap"
alias kraken="gitkraken"
alias la="ls -a"
alias lla="ls -la"
alias ll="ls -l"
alias ls="ls --color"
alias plexupdate="ssh qnas docker restart plex"
alias python="/usr/local/bin/python3"
alias tree="tree -C"
alias zshc="vi $ZDOTDIR/.zshrc && source $ZDOTDIR/.zshrc"

### CUSTOM FUNCTIONS ###
gitkraken () {
  dir="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
  open gitkraken://repo/$dir
}
update () {
  brew cu -aqy --no-quarantine
  brew upgrade
  if [[ -n $(brew list | grep microsoft-auto-update) ]]; then
     brewcun microsoft-auto-update
  fi
  brew cleanup
  #mas upgrade
  if [[ -n $(pip list --outdated) ]]; then
    pip install --upgrade $(pip list --outdated | awk 'NR>2 {print $1}')
  fi
  softwareupdate -i -a --agree-to-license
}

### SOURCE PLUGINS / THEMES ###
source $ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme


### AUTOCOMPLETE ###
# Load completions
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

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

### Source git/ssh auth
source $ZDOTDIR/.extras

### P10K CONFIG ###
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $ZDOTDIR/.p10k.zsh ]] || source $ZDOTDIR/.p10k.zsh

### Syntax highlighting
# Must be a the end of the config file
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
