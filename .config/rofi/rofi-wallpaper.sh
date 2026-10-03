#!/usr/bin/env bash

WALL_DIR="$HOME/Wallpapers"

# 1. Start the daemon if not running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.3
fi

# Function to apply wallpaper
apply_wallpaper() {
    local img_path="$1"
    [ -z "$img_path" ] && exit 0
    
    TRANSITIONS=("fade" "wipe" "slide" "grow")
    RANDOM_TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}
    
    awww img "$img_path" \
        --transition-type "$RANDOM_TRANSITION" \
        --transition-pos "center" \
        --transition-step 4 \
        --transition-fps 60 \
        --transition-duration 0.5 \
        --transition-angle "$((RANDOM % 360))"
    
    matugen image "$img_path" --source-color-index 0 && ln -sf "$img_path" "$HOME/.config/hypr/current_wallpaper"
}

# MODE A: Called directly via keybind (e.g. hl.bind)
if [ -t 0 ] || [ -z "$ROFI_RETV" ]; then
    SELECTED_WALL=$(for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
        [ -e "$img" ] || continue
        name=$(basename "$img")
        echo -en "$name\0icon\x1fthumbnail://$img\n"
    done | rofi -dmenu -i -p "Wallpapers:" -show-icons)
    
    if [ -n "$SELECTED_WALL" ]; then
        apply_wallpaper "$WALL_DIR/$SELECTED_WALL"
    fi
    exit 0
fi

# MODE B: Called by Rofi as a custom Modi (rofi -show wallpaper)
if [ -n "$1" ]; then
    apply_wallpaper "$WALL_DIR/$1"
    exit 0
fi

# Output entries for Rofi Modi
for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
    [ -e "$img" ] || continue
    name=$(basename "$img")
    echo -en "$name\0icon\x1fthumbnail://$img\n"
done