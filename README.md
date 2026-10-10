# Dotfiles

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
  libnotify brightnessctl \
  ddcutil \
  xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
  kitty starship fastfetch \
  zsh zsh-completions \
  pipewire wireplumber playerctl wl-clipboard wl-clip-persist jq \
  power-profiles-daemon nautilus \
  ffmpegthumbnailer \
  neovim \
  fnm \
  rclone rsync \
  networkmanager \
  sddm qt6-virtualkeyboard \
  ttf-jetbrains-mono-nerd \
  noctalia \
  wf-recorder # screen recording

# Optional deps of xdg-desktop-portal-hyprland (screenshot portal)
sudo pacman -S --asdeps grim slurp
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

### SDDM Theme Bootstrap

SDDM colors come from a Noctalia user template (`.config/noctalia/templates/sddm-theme.conf`); its post-hook (`.config/noctalia/hooks/sddm.sh`) installs the rendered `theme.conf` and copies the current wallpaper into the theme. The underlying SDDM theme (`simple-sddm-2`) and `/etc` bits aren't tracked. One-time setup on a fresh install:

```bash
# 1. Clone the SDDM theme (simple-sddm-2 acts as a shared shell that the
#    Noctalia sddm template re-colors and re-backgrounds per active palette)
sudo git clone https://github.com/JaKooLit/simple-sddm-2 /usr/share/sddm/themes/simple-sddm-2

# 2. Hand ownership to the user so the Noctalia sddm hook can rewrite theme.conf
#    and drop wallpapers into Backgrounds/ without sudo on every theme switch
sudo chown -R "$USER:$USER" /usr/share/sddm/themes/simple-sddm-2

# 3. Point SDDM at it
sudo tee /etc/sddm.conf > /dev/null <<'EOF'
[Theme]
    Current=simple-sddm-2
EOF

# 4. Enable virtual-keyboard input method (the sddm template has
#    HideVirtualKeyboard="false", which only shows the button — the input
#    method backend must be configured separately)
sudo tee /etc/sddm.conf.d/virtualkbd.conf > /dev/null <<'EOF'
[General]
    InputMethod=qtvirtualkeyboard
EOF

# 5. Enable SDDM
sudo systemctl enable sddm

# 6. Render Noctalia templates (writes the live theme.conf and copies the
#    wallpaper into Backgrounds/); needs noctalia running
noctalia msg templates-apply
```

### Enable Systemd User Timers

After deploying, enable the user timers:

```bash
systemctl --user daemon-reload
systemctl --user enable --now mouse-battery-check.timer  # Mouse low battery notifications
systemctl --user enable --now keepass-backup.timer       # Daily KeePass backup
systemctl --user enable --now wtf-backup.timer           # Daily WTF backup
```

### OOM Handling (SysRq + earlyoom)

```bash
sudo pacman -S earlyoom
cd ~/dotfiles/system
sudo install -Dm644 etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/99-sysrq.conf
sudo sysctl --load=/etc/sysctl.d/99-sysrq.conf
sudo install -Dm644 etc/default/earlyoom /etc/default/earlyoom
sudo systemctl enable --now earlyoom
```

earlyoom kills the worst process (preferring lint/test tooling, avoiding Hyprland/kitty/Steam/games) when free RAM drops below 5%, before the system starts thrashing. **Alt+SysRq+F** is the manual escape.

Verify:

```bash
cat /proc/sys/kernel/sysrq      # 1
systemctl status earlyoom       # active, logs the thresholds and prefer/avoid regexes
```

Test SysRq safely with **Alt+SysRq+H** (prints help to `journalctl -k`).

### Webcam Toggle (udev)

`.config/scripts/toggle-webcam.sh` (**Super+Shift+W**) unbinds/binds the webcam via sysfs. This udev rule lets the `video` group write the uvcvideo bind/unbind handles so it works without sudo:

```bash
cd ~/dotfiles/system
sudo install -Dm644 etc/udev/rules.d/99-uvcvideo-toggle.rules /etc/udev/rules.d/99-uvcvideo-toggle.rules
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=usb --action=add
```

### Italian Formats Locale

`.config/locale.conf` keeps English messages, uses `en_GB` for dates (Monday first, dd/mm, 24h) and `it_IT` for everything else. Generate the locales once, then relog:

```bash
sudo sed -i -E 's/^#(it_IT|en_GB)\.UTF-8/\1.UTF-8/' /etc/locale.gen && sudo locale-gen
```

### Dark Mode (dconf)

These preferences live in dconf, not in stowable files, so apply them once on a fresh install:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'  # portal signal for Firefox/Zen in-content + devtools
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'         # GTK3 dialogs (file picker); dark via prefer-dark flag in gtk-3.0/settings.ini
```

Note: `Adwaita-dark` is not a valid theme name here (no on-disk theme) — the dark variant comes from the built-in `Adwaita` plus `gtk-application-prefer-dark-theme=1`. Dark mode also requires `xdg-desktop-portal` running, which needs `hyprland-session.target` to be active (started from `hyprland.lua` autostart).

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
