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
  rofi libnotify brightnessctl \
  xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
  kitty starship fastfetch \
  pipewire wireplumber playerctl wl-clipboard wl-clip-persist jq \
  power-profiles-daemon nautilus \
  ffmpegthumbnailer \
  neovim \
  rclone rsync \
  networkmanager \
  sddm qt6-virtualkeyboard \
  ttf-jetbrains-mono-nerd \
  grim slurp wf-recorder satty # screenshots & screen recording (hyprpicker/satty above too)
```

```bash
# AUR
yay -S wayle-bin
```

Screenshots use [grimblast](https://github.com/hyprwm/contrib/tree/main/grimblast) — follow its README to install.

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

### SDDM Theme Bootstrap

The dotfiles ship per-theme `sddm.conf` files (`.config/themes/<t>/sddm.conf`) and the `theme-switcher.sh` logic that wires them in, but the underlying SDDM theme (`simple-sddm-2`) and `/etc` bits aren't tracked. One-time setup on a fresh install:

```bash
# 1. Clone the SDDM theme (simple-sddm-2 acts as a shared shell that the
#    per-theme sddm.conf files re-color and re-background per active dotfile theme)
sudo git clone https://github.com/JaKooLit/simple-sddm-2 /usr/share/sddm/themes/simple-sddm-2

# 2. Hand ownership to the user so theme-switcher.sh can rewrite theme.conf
#    and drop wallpapers into Backgrounds/ without sudo on every theme switch
sudo chown -R "$USER:$USER" /usr/share/sddm/themes/simple-sddm-2

# 3. Point SDDM at it
sudo tee /etc/sddm.conf > /dev/null <<'EOF'
[Theme]
    Current=simple-sddm-2
EOF

# 4. Enable virtual-keyboard input method (the per-theme sddm.conf files have
#    HideVirtualKeyboard="false", which only shows the button — the input
#    method backend must be configured separately)
sudo tee /etc/sddm.conf.d/virtualkbd.conf > /dev/null <<'EOF'
[General]
    InputMethod=qtvirtualkeyboard
EOF

# 5. Enable SDDM
sudo systemctl enable sddm

# 6. Apply the active dotfile theme to SDDM (writes the live theme.conf and
#    copies the wallpaper into Backgrounds/)
~/.config/scripts/theme-switcher.sh "$(basename "$(readlink ~/.config/themes/current/theme)")"
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
