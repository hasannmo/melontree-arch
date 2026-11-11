# melontree-arch

Personal Arch Linux configuration records, user scripts, and dotfiles for Hyprland desktop environment.

Based on best practices from [ArchWiki Dotfiles](https://wiki.archlinux.org/title/Dotfiles) and [Arch Linux](https://archlinux.org/).

---

## 📁 Repository Structure

```text
melontree-arch/
├── .config/
│   ├── hypr/            # Hyprland lua & paper configs
│   ├── hyprland/        # Additional hyprland setups, idle & paper configs
│   ├── waybar/          # Status bar config & css style
│   ├── kitty/           # Terminal emulator configuration
│   ├── rofi/            # Application launcher config
│   ├── quickshell/      # QuickShell widgets
│   ├── mako/            # Notification daemon config
│   ├── cava/            # Audio visualizer config & themes
│   ├── fastfetch/       # System information display
│   ├── satty/           # Screenshot annotation tool
│   ├── neovide/         # Neovim GUI configuration
│   └── starship.toml    # Shell prompt styling
├── .local/
│   └── bin/             # Custom CLI commands & desktop scripts (wallpaper-cycle, screenshot, etc.)
├── wallpapers/          # Curated desktop wallpaper pool
├── .zshrc               # Zsh configuration
├── .bashrc              # Bash configuration
├── packages-explicit.txt # Explicitly installed native packages (`pacman -Qqe`)
├── packages-aur.txt      # Foreign/AUR packages (`pacman -Qqem`)
├── install.sh           # Automated installer for symlinks, binaries, and wallpaper pool
└── README.md
```

---

## 🚀 Restoration Guide

### 1. Package Reinstallation (Arch Linux)

According to the [ArchWiki Pacman tips](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#List_of_installed_packages):

```bash
# Reinstall explicitly installed official packages
sudo pacman -S --needed - < packages-explicit.txt

# Reinstall AUR packages (via yay or your preferred AUR helper)
yay -S --needed - < packages-aur.txt
```

### 2. Deploy Dotfiles, Scripts & Wallpapers

Run the restoration script:

```bash
chmod +x install.sh
./install.sh
```

What `install.sh` handles:
- Symlinks `.config/*` to `~/.config/` (backs up existing configs to `.bak`).
- Symlinks all scripts in `.local/bin/*` to `~/.local/bin/` with executable permissions.
- Populates the wallpaper pool in `~/paper/pool` and `~/.local/share/wallpapers`.
- Links `.zshrc` and `.bashrc`.
