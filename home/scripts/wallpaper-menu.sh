#!/usr/bin/env bash

WALL_DIR="$HOME/fondos"
WOFI_CONF="$HOME/.config/wofi/wallpaper.conf"
WOFI_STYLE="$HOME/.config/wofi/wallpaper.css"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs-16x9-rounded"
CURRENT_WALLPAPER="$HOME/.config/hypr/current-wallpaper"
THUMB_WIDTH=640
THUMB_HEIGHT=360
THUMB_RADIUS=18

pgrep hyprpaper >/dev/null || hyprpaper &
sleep 0.3

mkdir -p "$THUMB_DIR"

thumb_for() {
    local img="$1"
    local hash
    local thumb
    local tmp

    hash=$(printf '%s' "$img" | sha256sum | cut -d' ' -f1)
    thumb="$THUMB_DIR/$hash.png"
    tmp="$THUMB_DIR/$hash.tmp.$$.png"

    if command -v ffmpeg >/dev/null 2>&1; then
        if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
            if ffmpeg -hide_banner -loglevel error -y \
                -i "$img" \
                -vf "scale=$THUMB_WIDTH:$THUMB_HEIGHT:force_original_aspect_ratio=increase,crop=$THUMB_WIDTH:$THUMB_HEIGHT,format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='if(lt(min(X,W-1-X),$THUMB_RADIUS)*lt(min(Y,H-1-Y),$THUMB_RADIUS)*gt(hypot($THUMB_RADIUS-min(X,W-1-X),$THUMB_RADIUS-min(Y,H-1-Y)),$THUMB_RADIUS),0,255)'" \
                -frames:v 1 \
                -update 1 \
                "$tmp" >/dev/null 2>&1; then
                mv "$tmp" "$thumb"
            else
                rm -f "$tmp"
                thumb="$img"
            fi
        fi
    else
        thumb="$img"
    fi

    printf '%s' "$thumb"
}

wallpaper_for_thumb() {
    local selected="$1"
    local thumb_path="${selected#img:}"
    local selected_hash
    local img
    local hash

    if [ -f "$thumb_path" ] && [[ "$thumb_path" != "$THUMB_DIR/"* ]]; then
        printf '%s' "$thumb_path"
        return
    fi

    selected_hash=$(basename "$thumb_path" .png)

    while IFS= read -r img; do
        hash=$(printf '%s' "$img" | sha256sum | cut -d' ' -f1)
        if [ "$hash" = "$selected_hash" ]; then
            printf '%s' "$img"
            return
        fi
    done < <(find "$WALL_DIR" -type f \( \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.png" -o \
        -iname "*.webp" \
    \))
}

# Crear menú con miniaturas cacheadas
CHOICE=$(find "$WALL_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" \
\) | sort | while read -r img; do
    thumb=$(thumb_for "$img")
    printf 'img:%s\n' "$thumb"
done | wofi \
    --conf "$WOFI_CONF" \
    --style "$WOFI_STYLE" \
    --show dmenu \
    --prompt "Wallpaper" \
    --allow-images \
    --parse-search \
    --insensitive \
    --cache-file /dev/null \
    --width 900 \
    --height 600 \
    --columns 3)

[ -z "$CHOICE" ] && exit 0

# Si wofi devuelve una entrada antigua img:/ruta:text:/ruta, sacamos la ruta
if [[ "$CHOICE" == img:*":text:"* ]]; then
    WALLPAPER="${CHOICE##*:text:}"
elif [[ "$CHOICE" == img:* ]]; then
    WALLPAPER=$(wallpaper_for_thumb "$CHOICE")
else
    WALLPAPER="$CHOICE"
fi

[ ! -f "$WALLPAPER" ] && notify-send "Wallpaper" "No se encontró el archivo" && exit 1

mkdir -p "$(dirname "$CURRENT_WALLPAPER")"
ln -sfn "$WALLPAPER" "$CURRENT_WALLPAPER"

MONITOR=$(hyprctl monitors | awk '
    /^Monitor/ { monitor=$2 }
    /focused: yes/ { print monitor; exit }
')

if [ -z "$MONITOR" ]; then
    hyprctl hyprpaper wallpaper ", $WALLPAPER, cover"
else
    hyprctl hyprpaper wallpaper "$MONITOR, $WALLPAPER, cover"
fi

notify-send "Wallpaper cambiado" "$(basename "$WALLPAPER")"
