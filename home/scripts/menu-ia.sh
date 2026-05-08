#!/usr/bin/env bash

CONFIG="$HOME/.config/wofi/menu-ia.conf"
STYLE="$HOME/.config/wofi/menu-ia.css"
ERR_FILE="${XDG_RUNTIME_DIR:-/tmp}/menu-ia-wofi.err"

notify_error() {
	if command -v notify-send >/dev/null 2>&1; then
		notify-send "Menu IA" "$1"
	fi
}

if pgrep -x wofi >/dev/null 2>&1; then
	pkill -x wofi
	exit 0
fi

if [[ ! -r "$CONFIG" || ! -r "$STYLE" ]]; then
	notify_error "No puedo leer la configuracion de wofi."
	exit 1
fi

: > "$ERR_FILE"

opcion=$(printf '%s\n' "󰚩  Codex" "󰧑  Opencode" | wofi --conf "$CONFIG" --style "$STYLE" --cache-file /dev/null -dmenu 2>"$ERR_FILE")
status=$?

if (( status != 0 )); then
	if [[ -s "$ERR_FILE" ]]; then
		notify_error "wofi fallo. Revisa $ERR_FILE"
	else
		notify_error "wofi fallo al abrir el menu."
	fi
	exit "$status"
fi

case "$opcion" in
	"󰚩  Codex")
	 	kitty -e codex &
	;;

	"󰧑  Opencode")
		kitty -e opencode &
	;;

	"")
		exit 0
	;;

	*)
		exit 0
	;;
esac
