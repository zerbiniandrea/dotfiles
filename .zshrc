ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light jeffreytse/zsh-vi-mode
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# History settings
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
HISTORY_IGNORE="(export *|curl *)"
# The following lines were added by compinstall
zstyle :compinstall filename '/home/zerbi/.zshrc'
autoload -Uz compinit
# Only regenerate completions once per day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
# End of compinstall


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Source shared aliases, exports, and integrations
[ -f ~/.shell_aliases ] && source ~/.shell_aliases
[ -f ~/.shell_exports ] && source ~/.shell_exports
[ -f ~/.shell_integrations ] && source ~/.shell_integrations

# Shell integrations
eval "$(fzf --zsh)"
eval "$(starship init zsh)"

zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

KEYTIMEOUT=1
