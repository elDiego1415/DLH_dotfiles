#!/bin/bash

BAT="/sys/class/power_supply/BAT0"

LOW=15
CRITICAL=5

WARNED_LOW=0
WARNED_CRITICAL=0

while true; do
    CAPACITY=$(cat "$BAT/capacity")
    STATUS=$(cat "$BAT/status")

    if [[ "$STATUS" == "Discharging" ]]; then

        if [[ "$CAPACITY" -le "$CRITICAL" && "$WARNED_CRITICAL" -eq 0 ]]; then
            notify-send -u critical "BATERIA CRITICA" "${CAPACITY}% - Conecta el cargador YA"

            # sonido (opcional)
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga &

            WARNED_CRITICAL=1
        elif [[ "$CAPACITY" -le "$LOW" && "$WARNED_LOW" -eq 0 ]]; then
            notify-send "Bateria baja" "Quedan ${CAPACITY}%"
            WARNED_LOW=1
        fi

    fi

    # reset si sube o carga
    if [[ "$STATUS" == "Charging" || "$CAPACITY" -gt "$LOW" ]]; then
        WARNED_LOW=0
        WARNED_CRITICAL=0
    fi

    sleep 60
done
