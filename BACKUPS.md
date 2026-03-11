# Automated Backup Strategies

This document describes different approaches to automatically backup your dotfiles.

## Quick Setup (Recommended)

Run the installer to set up weekly backups:

```bash
cd ~/dotfiles
./install-backup-timer.sh
```

This will:
- Install a systemd timer that runs every Sunday at 2 AM
- Automatically commit and push changes to GitHub
- No manual intervention required

## Backup Methods

### Method 1: Systemd Timer (Automated Weekly)

**Best for:** Fedora/Linux systems with systemd

**Setup:**
```bash
./install-backup-timer.sh
```

**How it works:**
- Runs `backup.sh` weekly
- Automatically commits changes with timestamp
- Pushes to GitHub
- Logs available via `journalctl`

**Manage the timer:**
```bash
# Check status
systemctl --user status dotfiles-backup.timer

# View logs
journalctl --user -u dotfiles-backup.service -f

# Run backup manually
systemctl --user start dotfiles-backup.service

# Disable weekly backups
systemctl --user disable dotfiles-backup.timer
systemctl --user stop dotfiles-backup.timer
```

### Method 2: Cron Job (Simple)

**Best for:** Any Unix-like system, simple setup

**Setup:**
```bash
crontab -e
```

Add one of these lines:

```bash
# Weekly (Sundays at 2 AM)
0 2 * * 0 cd ~/dotfiles && ./backup.sh && git add -A && git diff --cached --quiet || (git commit -m "Weekly backup: $(date +\%Y-\%m-\%d)" && git push)

# Daily (every day at 2 AM)
0 2 * * * cd ~/dotfiles && ./backup.sh && git add -A && git diff --cached --quiet || (git commit -m "Daily backup: $(date +\%Y-\%m-\%d)" && git push)

# On login (backup every time you login)
@reboot cd ~/dotfiles && ./backup.sh && git add -A && git diff --cached --quiet || (git commit -m "Login backup: $(date +\%Y-\%m-\%d)" && git push)
```

### Method 3: Git Post-Commit Hook (Event-Driven)

**Best for:** Immediate sync after manual changes

**Already configured!** Every time you run `git commit` in your dotfiles repo, it automatically pushes to GitHub.

**Usage:**
```bash
cd ~/dotfiles
./backup.sh          # Backup files
git add -A           # Stage changes
git commit -m "Updated zsh config"  # This will auto-push!
```

### Method 4: Manual Backup Script

**Best for:** Full control, one-off backups

```bash
cd ~/dotfiles
./backup.sh

# Then manually commit and push
git add -A
git status                    # Review changes
git commit -m "Your message"
git push
```

## Comparison

| Method | Frequency | Auto-push | Setup Complexity | Best For |
|--------|-----------|-----------|------------------|----------|
| Systemd Timer | Weekly | Yes | Low | Most users |
| Cron | Flexible | Yes | Low | Server/VPS |
| Git Hook | Every commit | Yes | None | Active development |
| Manual | On-demand | No | None | Full control |

## Monitoring Backups

### Check last backup
```bash
cd ~/dotfiles
git log -1 --format="%h %s %ar"
```

### Check timer status
```bash
# Systemd
systemctl --user list-timers dotfiles-backup

# Cron
crontab -l
```

### View backup history
```bash
git log --oneline --graph --all
```

## Troubleshooting

### Backup not running?
1. Check timer is enabled: `systemctl --user is-enabled dotfiles-backup.timer`
2. Check for errors: `journalctl --user -u dotfiles-backup.service`
3. Ensure GitHub auth is working: `gh auth status`

### Changes not being committed?
- Make sure `backup.sh` has execute permission: `chmod +x ~/dotfiles/backup.sh`
- Check that git user is configured:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your@email.com"
  ```

### Push failing?
- Verify SSH key is added to GitHub: `gh ssh-key list`
- Test connection: `ssh -T git@github.com`

## Security Notes

- **Never** commit private keys, passwords, or API tokens
- Use `.bashrc.local` for secrets (already ignored by .gitignore)
- The backup script automatically excludes private SSH keys
- GitHub secret scanning will reject commits containing common secret patterns

## Customization

### Change backup frequency

Edit `~/.config/systemd/user/dotfiles-backup.timer`:

```ini
# Daily at 2 AM
OnCalendar=daily

# Every 3 days
OnCalendar=*-*-1,4,7,10,13,16,19,22,25,28:02:00

# Specific time
OnCalendar=Mon,Tue,Wed,Thu,Fri *-*-* 09:00:00
```

Then reload:
```bash
systemctl --user daemon-reload
systemctl --user restart dotfiles-backup.timer
```

### Exclude files from backup

Edit `~/dotfiles/backup.sh` and add exclusions:

```bash
# Don't backup certain files
rm -f "$DOTFILES_DIR/.bash_history"
rm -f "$DOTFILES_DIR/.zsh_history"
```

Or add to `.gitignore`:
```
.bash_history
.zsh_history
*.log
.cache/
```
