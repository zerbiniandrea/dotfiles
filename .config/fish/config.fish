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

set -gx PNPM_HOME ~/.local/share/pnpm
fish_add_path $PNPM_HOME/bin

# Aliases
alias uuid 'uuidgen | tr -d "\n" | wl-copy && echo "UUID copied to clipboard: $(wl-paste)"'
alias ds_compress '~/.config/scripts/discord-compress.sh'

alias up 'paru && flatpak update'

# Shell integrations
direnv hook fish | source
fzf --fish | source
starship init fish | source
