[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
source ~/.tools/zsh-git-prompt/zshrc.sh

PROMPT='%B%m%~%b$(git_super_status) %# '

setopt autocd		# Automatically cd into typed directory.

LFCD="$GOPATH/src/github.com/gokcehan/lf/etc/lfcd.sh"  	# source
LFCD="$HOME/.config/lf/lfcd.sh"                   	# pre-built binary, make sure to use absolute path
if [ -f "$LFCD" ]; then
    source "$LFCD"
fi

# Basic auto/tab complete:
autoload -U compinit -u
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -e
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
 bindkey -M menuselect 'h' vi-backward-char
 bindkey -M menuselect 'k' vi-up-line-or-history
 bindkey -M menuselect 'l' vi-forward-char
 bindkey -M menuselect 'j' vi-down-line-or-history
 bindkey -v '^?' backward-delete-char


# Change cursor shape for different vi modes.
 function zle-keymap-select {
   if [[ ${KEYMAP} == vicmd ]] ||
      [[ $1 = 'block' ]]; then
     echo -ne '\e[1 q'
   elif [[ ${KEYMAP} == main ]] ||
        [[ ${KEYMAP} == viins ]] ||
        [[ ${KEYMAP} = '' ]] ||
        [[ $1 = 'beam' ]]; then
     echo -ne '\e[5 q'
   fi
 }
 zle -N zle-keymap-select
 zle-line-init() {
     zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
     echo -ne "\e[5 q"
 }
 zle -N zle-line-init
 echo -ne '\e[5 q' # Use beam shape cursor on startup.
 preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.
 
 autoload -U url-quote-magic bracketed-paste-magic
 zle -N self-insert url-quote-magic
 zle -N bracketed-paste bracketed-paste-magic

export HISTFILE="${XDG_CONFIG_HOME:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=1000
setopt SHARE_HISTORY
# export PATH="$PYENV_ROOT/bin:$PATH"
source $TOOLS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pnpm
export PNPM_HOME="/home/tony/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
