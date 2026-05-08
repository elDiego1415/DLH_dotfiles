#!/bin/bash

set -u

action="${1:-}"
on_battery=0

for status_file in /sys/class/power_supply/BAT*/status; do
    [[ -e "$status_file" ]] || continue

    if [[ "$(cat "$status_file")" == "Discharging" || "$(cat "$status_file")" == "Charging" ]]; then
        on_battery=1
        break
    fi
done

[[ "$on_battery" -eq 1 ]] || exit 0

case "$action" in
    lock)
        pidof hyprlock >/dev/null || hyprlock
        ;;
    dpms-off)
        hyprctl dispatch dpms off
        ;;
    *)
        echo "Uso: $0 {lock|dpms-off}" >&2
        exit 64
        ;;
esac
