#!/usr/bin/env python3
import subprocess
import time
from pathlib import Path


def sh(cmd):
    try:
        return subprocess.check_output(cmd, text=True).strip()
    except Exception:
        return ''


def read_int(path):
    try:
        return int(Path(path).read_text().strip())
    except Exception:
        return None


def field(value):
    return str(value).replace('|', '/').strip()


def human_bytes(v):
    try:
        v = float(v)
    except Exception:
        return '--'
    units = ['B/s', 'KB/s', 'MB/s', 'GB/s']
    i = 0
    while v >= 1024 and i < len(units) - 1:
        v /= 1024.0
        i += 1
    return f'{int(v)} {units[i]}' if i == 0 else f'{v:.1f} {units[i]}'


lines  = sh(['nmcli', '-t', '-f', 'DEVICE,TYPE,STATE', 'dev']).splitlines()
picked = None

for ln in lines:
    parts = ln.split(':')
    if len(parts) >= 3 and parts[1] == 'wifi' and parts[2] == 'connected':
        picked = parts
        break

if picked is None:
    for ln in lines:
        parts = ln.split(':')
        if len(parts) >= 3 and parts[1] == 'ethernet' and parts[2] == 'connected':
            picked = parts
            break

if picked is None:
    print('none|󰖪|Disconnected||--|--')
    raise SystemExit

dev, typ, state = picked[0], picked[1], picked[2]

rx_path = f'/sys/class/net/{dev}/statistics/rx_bytes'
tx_path = f'/sys/class/net/{dev}/statistics/tx_bytes'

rx1 = read_int(rx_path)
tx1 = read_int(tx_path)
time.sleep(0.4)
rx2 = read_int(rx_path)
tx2 = read_int(tx_path)

try:
    down = human_bytes((rx2 - rx1) / 0.4)
except Exception:
    down = '--'

try:
    up = human_bytes((tx2 - tx1) / 0.4)
except Exception:
    up = '--'

if typ == 'wifi' and state == 'connected':
    conn = sh(['nmcli', '-t', '-g', 'GENERAL.CONNECTION', 'device', 'show', dev])
    if not conn:
        conn = sh(['nmcli', '-t', '-g', 'CONNECTION.ID', 'device', 'show', dev])
    if not conn:
        conn = 'WiFi'

    strength     = sh(['nmcli', '-t', '-g', 'IN-USE,SIGNAL', 'dev', 'wifi'])
    signal_value = 0
    for ln in strength.splitlines():
        p = ln.split(':', 1)
        if len(p) == 2 and p[0] == '*':
            try:
                signal_value = int(float(p[1]))
            except Exception:
                signal_value = 0
            break

    icon = '󰤯'
    if signal_value >= 25: icon = '󰤟'
    if signal_value >= 50: icon = '󰤢'
    if signal_value >= 75: icon = '󰤥'
    if signal_value >= 90: icon = '󰤨'

    print(f'wifi|{icon}|{field(conn)}|{field(dev)}|{down}|{up}')

elif typ == 'ethernet' and state == 'connected':
    print(f'ethernet|󰀂|Ethernet|{field(dev)}|{down}|{up}')

else:
    print(f'none|󰖪|Disconnected|{field(dev)}|--|--')
