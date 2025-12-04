# Dotfiles

Personal dotfiles configuration for Arch Linux development environment.

## System Requirements

This dotfiles configuration is designed for Arch Linux with Hyprland (Wayland compositor).

## Installation

### Prerequisites

```bash
sudo pacman -S git stow
```

### Required Dependencies

```bash
# Official repositories
sudo pacman -S \
  hyprland hyprlock hypridle hyprpaper uwsm hyprshot hyprsunset \
  waybar rofi mako libnotify swayosd \
  xdg-desktop-portal-gtk \
  kitty starship fastfetch \
  pipewire wireplumber playerctl wl-clipboard jq \
  power-profiles-daemon nautilus \
  ffmpegthumbnailer \
  neovim \
  rclone rsync \
  wiremix impala satty \
  ttf-jetbrains-mono-nerd

### Deploy Dotfiles

Clone the repository to your home directory:

```bash
cd ~
git clone https://github.com/zerbiniandrea/dotfiles/ dotfiles
cd dotfiles
```

Deploy all configurations using GNU Stow:

```bash
stow .
```

## Managing Dotfiles

### Remove all configurations

```bash
stow -D .
```

### Reinstall configurations

```bash
stow -R .
```

## Troubleshooting

### Existing Files Conflict

If you encounter conflicts with existing files:

```bash
# Backup existing configs
mkdir ~/config-backup
mv ~/.config/fish ~/config-backup/

# Then restow
stow .
```

### Verify Symlinks

Check that symlinks were created correctly:

```bash
ls -la ~ | grep "\->"
```

## Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull
stow -R .  # Restow to apply any structural changes
```
