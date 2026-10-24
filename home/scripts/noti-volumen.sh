#!/usr/bin/env bash
set -euo pipefail

STEP="5%"
NOTIFICATION_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/noti-volumen.id"

case "$1" in
    up)
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$STEP"+ > /dev/null
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP"- > /dev/null
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle > /dev/null
        ;;
    *)
        echo "Uso: $(basename "$0") up|down|mute" >&2
        exit 1
        ;;
esac

read -r volume muted < <(
    wpctl get-volume @DEFAULT_AUDIO_SINK@ |
        awk '{ print $2, ($3 == "[MUTED]" ? 1 : 0) }'
)

percent=$(awk -v v="$volume" 'BEGIN { printf "%d", (v * 100) + 0.5 }')

if [[ "$muted" == "1" ]]; then
    title="󰖁 Volumen"
    body="Silenciado"
    value=0
else
    title="󰕾 Volumen"
    body="$percent%"
    value="$percent"
fi

replace_id=0
if [[ -s "$NOTIFICATION_ID_FILE" ]]; then
    read -r replace_id < "$NOTIFICATION_ID_FILE"
fi

send_notification() {
    notify-send \
        -a "Volumen" \
        -u low \
        -e \
        -p \
        "$@" \
        -h int:value:"$value" \
        "$title" \
        "$body"
}

if ! send_notification -r "$replace_id" > "$NOTIFICATION_ID_FILE"; then
    send_notification > "$NOTIFICATION_ID_FILE"
fi
