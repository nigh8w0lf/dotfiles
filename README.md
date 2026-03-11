# Dotfiles

Personal dotfiles and configuration for my development environment.

**Repository:** https://github.com/nigh8w0lf/dotfiles  
**System:** Acer Predator PT515-51 running Fedora Linux with GNOME + Pop!_OS Shell

## What's Included

### Shell Configuration
- **Bash** (`.bashrc`, `.bash_profile`) - Primary shell with custom aliases and functions
- **Zsh** (`.zshrc`, `.zshenv`) - Alternative shell configuration
- **Profile** (`.profile`) - Environment variables shared across shells

### Development Tools
- **Git** (`.gitconfig`, `.config/git/`) - Git configuration and global ignore patterns
- **Tmux** (`.tmux.conf`) - Terminal multiplexer configuration
- **SSH** (`.ssh/`) - SSH config and public keys (private keys not included)

### Terminal & Editor
- **Ghostty** (`.config/ghostty/`) - Terminal emulator configuration

### Window Manager
- **Pop!_OS Shell** (`.config/pop-shell/`) - Tiling window manager for GNOME
- **GNOME Extensions** (`gnome-extensions.txt`) - List of installed GNOME extensions

## Prerequisites

- Fedora Linux (or similar RPM-based distribution)
- GNOME Shell 45+
- Git
- [GitHub CLI](https://cli.github.com/) (`gh`) - For authentication

## Installation

### 1. Clone the Repository

```bash
cd ~
git clone https://github.com/nigh8w0lf/dotfiles.git
cd dotfiles
```

### 2. Backup Existing Configs

```bash
# Create backup directory
mkdir -p ~/.dotfiles-backup/$(date +%Y%m%d)

# Backup existing configs
cp ~/.bashrc ~/.dotfiles-backup/$(date +%Y%m%d)/ 2>/dev/null || true
cp ~/.zshrc ~/.dotfiles-backup/$(date +%Y%m%d)/ 2>/dev/null || true
cp ~/.gitconfig ~/.dotfiles-backup/$(date +%Y%m%d)/ 2>/dev/null || true
cp -r ~/.config/ghostty ~/.dotfiles-backup/$(date +%Y%m%d)/ 2>/dev/null || true
cp -r ~/.config/pop-shell ~/.dotfiles-backup/$(date +%Y%m%d)/ 2>/dev/null || true
```

### 3. Install Dotfiles

**Option A: Manual Installation**

```bash
# Copy files
cp .bashrc ~/
cp .bash_profile ~/
cp .zshrc ~/
cp .zshenv ~/
cp .profile ~/
cp .gitconfig ~/
cp .tmux.conf ~/

# Copy directories
cp -r .config/git ~/.config/
cp -r .config/ghostty ~/.config/
cp -r .config/pop-shell ~/.config/

# SSH config (copy only if you don't have existing config)
cp -r .ssh ~/.ssh-backup-temp  # Review before copying
cat .ssh/config >> ~/.ssh/config  # Append rather than overwrite
```

**Option B: Using Stow (Recommended)**

Install GNU Stow first:
```bash
sudo dnf install stow
```

Then use stow to manage symlinks:
```bash
cd ~/dotfiles

# Create symlinks for all configs
stow -v -t ~ .

# Or stow individual packages
stow -v -t ~ bash zsh git tmux ssh
```

### 4. Configure Secrets

Create a local file for private environment variables:

```bash
# Create ~/.bashrc.local for secrets
touch ~/.bashrc.local
chmod 600 ~/.bashrc.local

# Add your tokens (this file is NOT tracked in git)
echo 'export HF_TOKEN=your_huggingface_token' >> ~/.bashrc.local
echo 'export OPENAI_API_KEY=your_openai_key' >> ~/.bashrc.local

# Source it in your .bashrc
echo '[ -f ~/.bashrc.local ] && source ~/.bashrc.local' >> ~/.bashrc
```

### 5. Install GNOME Extensions

Install the GNOME extensions listed in `gnome-extensions.txt`:

```bash
# Via GNOME Extensions website or command line:
gnome-extensions install ddterm@amezin.github.com  # Dropdown terminal
gnome-extensions install predator-fan@ashwin       # Temperature monitor (if needed)
```

### 6. Enable Pop!_OS Shell

```bash
gnome-extensions enable pop-shell@system76.com
```

Log out and log back in for all changes to take effect.

## Post-Installation

### Install Required Packages

```bash
# Core tools
sudo dnf install -y \
    git \
    tmux \
    gh \
    stow \
    fzf \
    ripgrep \
    fd-find \
    bat \
    eza \
    zoxide \
    yazi

# Terminal emulators
sudo dnf install -y ptyxis  # GNOME Console
# Or build Ghostty from source

# Development
sudo dnf install -y \
    neovim \
    nodejs \
    python3-pip
```

### Pop!_OS Shell Key Bindings

| Shortcut | Action |
|----------|--------|
| `Super + Enter` | Launch terminal |
| `Super + /` | Show launcher |
| `Super + Arrow Keys` | Move focus between windows |
| `Super + Shift + Arrow Keys` | Move windows |
| `Super + M` | Toggle tiling mode |
| `Super + G` | Toggle window gaps |
| `Super + O` | Toggle orientation |

### Custom Aliases

Key aliases included:
- `fs` - Launch yazi file manager
- `ll` - Enhanced ls with eza
- `cat` - Syntax highlighted cat (using bat)
- `cd` - Smart cd with zoxide

## Updating Dotfiles

To update your dotfiles backup:

```bash
cd ~/dotfiles
./backup.sh
git add -A
git commit -m "Update: $(date +%Y-%m-%d)"
git push origin main
```

## Restoring on a New Machine

1. Install Fedora and GNOME
2. Install `gh` and authenticate: `gh auth login`
3. Clone this repo: `git clone https://github.com/nigh8w0lf/dotfiles.git`
4. Follow the installation steps above
5. Set up secrets in `~/.bashrc.local`

## Hardware-Specific Notes

### Acer Predator PT515-51
- Fan control via Fn+F keyboard shortcut
- Temperature monitoring via predator-fan extension
- See [system_tools/README.md](system_tools/README.md) for fan control setup

## License

These dotfiles are personal configurations. Feel free to use and modify as needed.

## Credits

- Pop!_OS Shell by System76
- Ghostty terminal
- Various open-source tools and plugins
