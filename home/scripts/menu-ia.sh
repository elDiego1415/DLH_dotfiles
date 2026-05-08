#!/bin/bash

CONFIG="$HOME/.config/wofi/menu-ia.conf"
STYLE="$HOME/.config/wofi/menu-ia.css"

opcion=$(printf '%s\n' "󰚩  Codex" "󰧑  Opencode" | wofi --conf "$CONFIG" --style "$STYLE" -dmenu)

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
esac 
