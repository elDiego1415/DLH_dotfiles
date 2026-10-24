#!/usr/bin/env bash
# Select the default PipeWire/PulseAudio output from a terminal.

set -euo pipefail

for command in pactl jq; do
  command -v "$command" >/dev/null || {
    printf 'Falta el comando requerido: %s\n' "$command" >&2
    exit 1
  }
done

current_sink=$(pactl get-default-sink)
mapfile -t sinks < <(
  pactl --format=json list sinks |
    jq -r '.[] | [.name, .description] | @tsv'
)

if ((${#sinks[@]} == 0)); then
  printf 'No se ha detectado ninguna salida de audio.\n' >&2
  exit 1
fi

printf '\nSalidas de audio disponibles:\n\n'
for index in "${!sinks[@]}"; do
  IFS=$'\t' read -r name description <<<"${sinks[index]}"
  marker=' '
  [[ $name == "$current_sink" ]] && marker='*'
  printf ' %s %d) %s\n' "$marker" "$((index + 1))" "$description"
done

printf '\nElige una salida (Enter para cancelar): '
read -r choice

[[ -z $choice ]] && exit 0
[[ $choice =~ ^[0-9]+$ ]] || {
  printf 'Selección no válida.\n' >&2
  exit 1
}

index=$((choice - 1))
((index >= 0 && index < ${#sinks[@]})) || {
  printf 'Selección fuera de rango.\n' >&2
  exit 1
}

IFS=$'\t' read -r sink_name sink_description <<<"${sinks[index]}"
pactl set-default-sink "$sink_name"
printf 'Salida predeterminada: %s\n' "$sink_description"
printf 'Las aplicaciones ya abiertas pueden necesitar reiniciar su reproducción.\n'
