#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source shared aliases, exports, and integrations
[ -f ~/.shell_aliases ] && source ~/.shell_aliases
[ -f ~/.shell_exports ] && source ~/.shell_exports
[ -f ~/.shell_integrations ] && source ~/.shell_integrations
PS1='[\u@\h \W]\$ '

# export $(envsubst < ~/.env)

# exec fish

#if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]; then
#  shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
#  exec fish $LOGIN_OPTION
#fi

