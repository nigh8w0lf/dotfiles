#!/bin/bash
# Install systemd timer for weekly dotfiles backup

set -e

echo "Setting up weekly dotfiles backup..."

# Create systemd user directory if it doesn't exist
mkdir -p ~/.config/systemd/user

# Copy service and timer files
cp ~/dotfiles/systemd/dotfiles-backup.service ~/.config/systemd/user/
cp ~/dotfiles/systemd/dotfiles-backup.timer ~/.config/systemd/user/

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable and start the timer
systemctl --user enable dotfiles-backup.timer
systemctl --user start dotfiles-backup.timer

echo ""
echo "✓ Weekly backup timer installed!"
echo ""
echo "Timer status:"
systemctl --user status dotfiles-backup.timer --no-pager
echo ""
echo "The backup will run every Sunday at 2:00 AM"
echo ""
echo "Commands to manage:"
echo "  Check status:  systemctl --user status dotfiles-backup.timer"
echo "  View logs:     journalctl --user -u dotfiles-backup.service"
echo "  Run manually:  systemctl --user start dotfiles-backup.service"
echo "  Disable:       systemctl --user disable dotfiles-backup.timer"
