#!/bin/bash

set -euo pipefail

choice="$(
    printf '%s\n' \
        "Abrir editor de red" \
        "Gestionar en terminal" \
        "Activar WiFi" \
        "Desactivar WiFi" \
        "Reconectar WiFi" \
        "Mostrar estado" |
        wofi --dmenu --prompt "Red"
)"

case "$choice" in
    "Abrir editor de red")
        nm-connection-editor
        ;;
    "Gestionar en terminal")
        kitty nmtui
        ;;
    "Activar WiFi")
        nmcli radio wifi on
        notify-send "WiFi" "Activado"
        ;;
    "Desactivar WiFi")
        nmcli radio wifi off
        notify-send "WiFi" "Desactivado"
        ;;
    "Reconectar WiFi")
        nmcli radio wifi off
        sleep 1
        nmcli radio wifi on
        notify-send "WiFi" "Reconectando"
        ;;
    "Mostrar estado")
        status="$(nmcli -t -f WIFI g)"
        connection="$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2 == "802-11-wireless" { print $1; exit }')"
        notify-send "Red" "WiFi: ${status:-desconocido}${connection:+\nConexion: $connection}"
        ;;
esac
