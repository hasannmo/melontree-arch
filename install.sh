#!/usr/bin/env bash
# install.sh - Restore dotfiles and packages for melontree-arch
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Restoring configuration files to ~/.config and ~"
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

if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    [ -e "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
    ln -sfn "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi

echo "==> Configurations restored successfully!"
echo ""
echo "Optional package restoration (Arch Linux):"
echo "  Standard repos: sudo pacman -S --needed - < packages-explicit.txt"
echo "  AUR packages:   yay -S --needed - < packages-aur.txt"
