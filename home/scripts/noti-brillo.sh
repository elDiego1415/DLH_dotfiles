#!/usr/bin/env bash
set -euo pipefail

STEP="5%"
NOTIFICATION_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/noti-brillo.id"

case "$1" in
    up)
        brightnessctl -e4 -n2 set "$STEP"+ > /dev/null
        ;;
    down)
        brightnessctl -e4 -n2 set "$STEP"- > /dev/null
        ;;
    *)
        echo "Uso: $(basename "$0") up|down" >&2
        exit 1
        ;;
esac

percent=$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')

replace_id=0
if [[ -s "$NOTIFICATION_ID_FILE" ]]; then
    read -r replace_id < "$NOTIFICATION_ID_FILE"
fi

send_notification() {
    notify-send \
        -a "Brillo" \
        -u low \
        -e \
        -p \
        "$@" \
        -h int:value:"$percent" \
        "󰃠 Brillo" \
        "$percent%"
}

if ! send_notification -r "$replace_id" > "$NOTIFICATION_ID_FILE"; then
    send_notification > "$NOTIFICATION_ID_FILE"
fi
