if status is-interactive
    # Vi mode
    fish_vi_key_bindings

    fastfetch
end

# Environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

# PATH
fish_add_path ~/.local/bin
fish_add_path ~/.bin
fish_add_path ~/.cargo/bin

# Aliases
alias up 'yay && flatpak update'
alias uuid 'uuidgen | tr -d "\n" | wl-copy && echo "UUID copied to clipboard: $(wl-paste)"'

# Shell integrations
direnv hook fish | source
fzf --fish | source
starship init fish | source
