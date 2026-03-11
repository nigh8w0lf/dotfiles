# .bashrc

# ble.sh - Bash Line Editor (fish-style inline autosuggestions)
# Must be sourced early before other settings
[[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --attach=none

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/ashwin/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PATH:$PNPM_HOME" ;;
esac
# pnpm end
# Claude Code config
export ANTHROPIC_BASE_URL=https://api.kimi.com/coding/
export ANTHROPIC_API_KEY=sk-kimi-eABP2K9IYUWuH1zVyBdHLqphdlahm8XBRiOGn0mU3fvcQV9oQkFMOuOsuKETlLJA
. "$HOME/.cargo/env"

# Alias claude to cl
alias cl='claude'

# Set startup directory
#cd ~/Projects

# ble.sh - Attach the line editor (must be at the end of .bashrc)
[[ ! ${BLE_VERSION-} ]] || ble-attach

# Alias for yazi file manager
alias fs='yazi'

#Hugging Face ENV config
# Note: HF_TOKEN should be set in ~/.bashrc.local (not tracked in git)
export HF_HUB_ENABLE_HF_TRANSFER=1

export PATH="/usr/local/cuda-13.0/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-13.0/lib64:$LD_LIBRARY_PATH"
export EDITOR=nvim

# mpv wrapper - auto background and disown
mpv() {
    command mpv "$@" & disown
}


# mpv wrapper - auto-refreshes YouTube cookies and uses integrated GPU
mpv() {
    local COOKIES_FILE="$HOME/youtube_cookies.txt"
    local BRAVE_PROFILE="$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/Default"
    local MAX_AGE_MINUTES=360  # 6 hours
    
    # Check if any argument contains youtube
    local is_youtube=false
    for arg in "$@"; do
        if [[ "$arg" == *"youtube.com"* ]] || [[ "$arg" == *"youtu.be"* ]]; then
            is_youtube=true
            break
        fi
    done
    
    # Auto-refresh cookies for YouTube URLs if needed
    if [ "$is_youtube" = true ]; then
        if [ ! -f "$COOKIES_FILE" ] || [ "$(find "$COOKIES_FILE" -mmin +$MAX_AGE_MINUTES 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "[mpv] Refreshing YouTube cookies..." >&2
            yt-dlp --cookies-from-browser "brave:$BRAVE_PROFILE" --cookies "$COOKIES_FILE" "https://youtube.com" 2>/dev/null
        fi
    fi
    
    # Use integrated GPU (disable dGPU)
    DRI_PRIME=0 /usr/bin/mpv "$@"
}
