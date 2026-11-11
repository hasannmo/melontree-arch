#!/usr/bin/env bash
# Wallpaper cycler - cycles through images in the pool directory (circular)
# Uses awww (formerly swww) for smooth, non-blocking transitions

# Candidate directories in priority order:
# 1. Custom environment variable WALLPAPER_DIR (if set)
# 2. XDG standard user data: ~/.local/share/wallpapers
# 3. User legacy directory: ~/paper/pool
# 4. Dotfiles repository wallpapers folder relative to this script
CANDIDATES=(
    "${WALLPAPER_DIR:-}"
    "$HOME/.local/share/wallpapers"
    "$HOME/paper/pool"
    "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/wallpapers"
    "$HOME/Pictures/Wallpapers"
)

POOL_DIR=""
for dir in "${CANDIDATES[@]}"; do
    if [ -n "$dir" ] && [ -d "$dir" ]; then
        if [ "$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -n 1)" ]; then
            POOL_DIR="$dir"
            break
        fi
    fi
done

# Fallback default if not yet populated
if [ -z "$POOL_DIR" ]; then
    POOL_DIR="$HOME/paper/pool"
fi

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-cycle-index"
TRANSITION_TYPE="fade"
TRANSITION_DURATION="0.2"

mkdir -p "$(dirname "$STATE_FILE")"

# Collect images (jpg, jpeg, png, webp), sorted for stable order
mapfile -t IMAGES < <(find "$POOL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | sort)

COUNT=${#IMAGES[@]}

if [ "$COUNT" -eq 0 ]; then
    notify-send "Wallpaper Cycler" "No images found in $POOL_DIR" 2>/dev/null
    echo "No images found in $POOL_DIR"
    exit 1
fi

# Make sure the daemon is actually running; start it if not
if ! awww query >/dev/null 2>&1; then
    awww-daemon &
    sleep 0.3
fi

# Read current index, default to -1 so first run lands on index 0
if [ -f "$STATE_FILE" ]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
else
    CURRENT_INDEX=-1
fi

# Compute next index (wraps around)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % COUNT ))
NEXT_IMAGE="${IMAGES[$NEXT_INDEX]}"

# Save new index
echo "$NEXT_INDEX" > "$STATE_FILE"

# Apply with a smooth transition - no blank/default-wallpaper flash
awww img "$NEXT_IMAGE" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-duration "$TRANSITION_DURATION"

notify-send "Wallpaper Cycler" "$(basename "$NEXT_IMAGE")" 2>/dev/null
echo "Switched to: $NEXT_IMAGE"
