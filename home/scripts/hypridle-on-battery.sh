#!/bin/bash

set -u

action="${1:-}"

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
