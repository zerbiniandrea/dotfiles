ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
# Initialize vi-mode immediately to avoid keybinding conflicts
ZVM_INIT_MODE=sourcing
zinit light jeffreytse/zsh-vi-mode
zinit light zsh-users/zsh-syntax-highlighting
# zinit light zsh-users/zsh-completions
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
HISTORY_IGNORE="(export *|curl *|git commit -m *|ds_compress *)"

# Keep typos (unknown first word) in session history but don't write them to HISTFILE
zshaddhistory() {
    local cmd=${${(z)1}[1]}
    [[ -n $cmd ]] && whence -- "$cmd" >/dev/null || return 2
}

# Completion
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Source shared aliases, exports, and integrations
[ -f ~/.shell_aliases ] && source ~/.shell_aliases
[ -f ~/.shell_exports ] && source ~/.shell_exports
[ -f ~/.shell_integrations ] && source ~/.shell_integrations

# Edit command line in $EDITOR (Ctrl+x Ctrl+e)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Shell integrations
eval "$(fzf --zsh)"
eval "$(starship init zsh)"

# Autosuggestion: history first, completion as fallback for stale paths
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

KEYTIMEOUT=1

[ -f ~/Quinck/secure-sharing/quinck-secure.zsh ] && source ~/Quinck/secure-sharing/quinck-secure.zsh
export PATH="$PATH:/home/zerbi/.local/bin"
