#!/usr/bin/env bash

CURRENT_WALLPAPER="$HOME/.config/hypr/current-wallpaper"

mkdir -p "$(dirname "$CURRENT_WALLPAPER")"

WALLPAPER=$(hyprctl hyprpaper listactive 2>/dev/null | awk -F': ' 'NF > 1 { print $2; exit }')

if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    ln -sfn "$WALLPAPER" "$CURRENT_WALLPAPER"
fi

exec hyprlock
