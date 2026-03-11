
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
