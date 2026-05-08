#!/usr/bin/env bash
set -euo pipefail

OUT="/tmp/quickshell-cava-${USER}.txt"
CFG="/tmp/quickshell-cava-${USER}.conf"
LOCK="/tmp/quickshell-cava-${USER}.lock"

mkdir -p "$(dirname "$OUT")"

exec 9>"$LOCK"
if ! flock -n 9; then
  echo "0;0;0;0;0;0;0;0;0;0" > "$OUT"
  sleep infinity
fi

get_default_sink_monitor() {
  local sink
  sink="$(pactl get-default-sink 2>/dev/null || true)"
  if [ -n "$sink" ]; then
    printf '%s.monitor' "$sink"
    return 0
  fi
  return 1
}

SOURCE="$(get_default_sink_monitor || true)"

cat > "$CFG" <<EOF
[general]
bars = 10
framerate = 30
autosens = 1
sensitivity = 120

[input]
method = pipewire
source = ${SOURCE:-auto}

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
frame_delimiter = 10

[smoothing]
integral = 65
monstercat = 1
waves = 0
gravity = 100
ignore = 0

[eq]
1 = 1
2 = 1
EOF

cleanup() {
  rm -f "$CFG"
}
trap cleanup EXIT

if ! command -v cava >/dev/null 2>&1; then
  echo "0;0;0;0;0;0;0;0;0;0" > "$OUT"
  sleep infinity
fi

while true; do
  cava -p "$CFG" 2>/dev/null | while IFS= read -r line; do
    [ -n "$line" ] && printf '%s\n' "$line" > "$OUT"
  done
  sleep 0.5
done
