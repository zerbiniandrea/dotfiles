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
  hyprland hyprlock hypridle hyprsunset hyprpicker \
  grim slurp \
  rofi libnotify brightnessctl \
  xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
  kitty starship fastfetch \
  pipewire wireplumber playerctl wl-clipboard wl-clip-persist jq \
  power-profiles-daemon nautilus \
  ffmpegthumbnailer \
  neovim \
  rclone rsync solaar \
  wiremix networkmanager networkmanager-dmenu satty \
  ttf-jetbrains-mono-nerd
```

```bash
# AUR
yay -S bluetuith wayle-bin
```

### Enable NetworkManager

```bash
sudo systemctl enable --now NetworkManager
```

If `systemd-networkd` is also active (Arch sometimes ships it enabled), disable it and its triggering units to avoid two managers fighting over the same interfaces.

List every related unit on your system (the exact set may vary across systemd versions):

```bash
systemctl list-unit-files 'systemd-networkd*' 'systemd-network-generator*'
```

Then disable + stop everything from that list, e.g.:

```bash
sudo systemctl disable --now \
  systemd-networkd.service \
  systemd-networkd.socket \
  systemd-networkd-resolve-hook.socket \
  systemd-networkd-varlink.socket \
  systemd-networkd-varlink-metrics.socket \
  systemd-network-generator.service
```

Verify nothing's still running:

```bash
systemctl is-active 'systemd-networkd*'   # all should be inactive
networkctl                                # all links should be unmanaged
```

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

### Enable Systemd User Timers

After deploying, enable the user timers:

```bash
systemctl --user daemon-reload
systemctl --user enable --now mouse-battery-check.timer  # Mouse low battery notifications
systemctl --user enable --now keepass-backup.timer       # Daily KeePass backup
systemctl --user enable --now wtf-backup.timer           # Daily WTF backup
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
