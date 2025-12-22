if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
end

set -gx PATH ~/.npm-global/bin $PATH


direnv hook fish | source
alias up='yay && flatpak update'
#starship init fish | source
