#!/usr/bin/env bash
# install.sh - Restore dotfiles, scripts, wallpapers, and packages for melontree-arch
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Restoring configuration files to ~/.config"
mkdir -p "$HOME/.config"

for item in "$DOTFILES_DIR/.config"/*; do
    target="$HOME/.config/$(basename "$item")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to ${target}.bak"
        mv "$target" "${target}.bak"
    fi
    echo "Symlinking $item -> $target"
    ln -sfn "$item" "$target"
done

echo "==> Restoring user binaries to ~/.local/bin"
mkdir -p "$HOME/.local/bin"
for bin in "$DOTFILES_DIR/.local/bin"/*; do
    if [ -f "$bin" ]; then
        bname="$(basename "$bin")"
        target="$HOME/.local/bin/$bname"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "Backing up existing binary $target to ${target}.bak"
            mv "$target" "${target}.bak"
        fi
        echo "Symlinking $bin -> $target"
        ln -sfn "$bin" "$target"
        chmod +x "$target"
    fi
done

echo "==> Restoring shell configurations"
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    [ -e "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
    ln -sfn "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi

echo "==> Setting up wallpaper pool"
mkdir -p "$HOME/paper/pool"
mkdir -p "$HOME/.local/share/wallpapers"

if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    # Copy wallpapers into pool if empty, and link to XDG standard wallpapers dir
    for wp in "$DOTFILES_DIR/wallpapers"/*; do
        fname="$(basename "$wp")"
        if [ ! -f "$HOME/paper/pool/$fname" ]; then
            cp "$wp" "$HOME/paper/pool/$fname"
        fi
        ln -sfn "$wp" "$HOME/.local/share/wallpapers/$fname"
    done
fi

echo "==> Dotfiles, scripts, and wallpapers restored successfully!"
echo ""
echo "Optional package restoration (Arch Linux):"
echo "  Standard repos: sudo pacman -S --needed - < packages-explicit.txt"
echo "  AUR packages:   yay -S --needed - < packages-aur.txt"
