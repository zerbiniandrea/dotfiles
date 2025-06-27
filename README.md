# Dotfiles

Personal dotfiles configuration for Arch Linux development environment.

## Prerequisites

### Git

```bash
sudo pacman -S git
```

### GNU Stow

```bash
sudo pacman -S stow
```

## Installation

Clone the repository to your home directory:

```bash
cd ~
git clone https://github.com/zerbiniandrea/dotfiles/edit/main/README.md dotfiles
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
