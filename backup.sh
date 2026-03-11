#!/bin/bash
# Dotfiles backup script
# Backs up important configuration files to ~/dotfiles

set -e

echo "Backing up dotfiles..."

DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

# Core shell configs
cp ~/.bashrc "$DOTFILES_DIR/" 2>/dev/null || true
cp ~/.bash_profile "$DOTFILES_DIR/" 2>/dev/null || true
cp ~/.zshrc "$DOTFILES_DIR/" 2>/dev/null || true
cp ~/.zshenv "$DOTFILES_DIR/" 2>/dev/null || true
cp ~/.profile "$DOTFILES_DIR/" 2>/dev/null || true

# Git config
cp ~/.gitconfig "$DOTFILES_DIR/" 2>/dev/null || true

# Tmux
cp ~/.tmux.conf "$DOTFILES_DIR/" 2>/dev/null || true

# SSH config (public only, no private keys)
mkdir -p "$DOTFILES_DIR/.ssh"
cp ~/.ssh/config "$DOTFILES_DIR/.ssh/" 2>/dev/null || true
cp ~/.ssh/*.pub "$DOTFILES_DIR/.ssh/" 2>/dev/null || true

# Config directories to backup
mkdir -p "$DOTFILES_DIR/.config"

# Important config dirs
cp -r ~/.config/git "$DOTFILES_DIR/.config/" 2>/dev/null || true
cp -r ~/.config/ghostty "$DOTFILES_DIR/.config/" 2>/dev/null || true
cp -r ~/.config/pop-shell "$DOTFILES_DIR/.config/" 2>/dev/null || true

# Create backup of GNOME extensions list
gnome-extensions list > "$DOTFILES_DIR/gnome-extensions.txt" 2>/dev/null || true

echo "Dotfiles backed up to $DOTFILES_DIR"
echo ""
echo "Files to commit:"
git status --short
