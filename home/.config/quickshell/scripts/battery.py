#!/usr/bin/env python3
import subprocess


def sh(cmd):
    try:
        return subprocess.check_output(cmd, text=True).strip()
    except Exception:
        return ''


def field(value):
    return str(value).replace('|', '/').strip()


devices = sh(['upower', '-e']).splitlines()
bat = next((dev for dev in devices if 'battery' in dev.lower()), '')

if not bat:
    print('0|0|Unknown|0|0')
    raise SystemExit

info    = sh(['upower', '-i', bat])
percent = 0
state   = 'unknown'

for line in info.splitlines():
    line = line.strip()
    if line.startswith('percentage:'):
        try:
            percent = int(float(line.split(':')[1].strip().replace('%', '')))
        except Exception:
            percent = 0
    elif line.startswith('state:'):
        state = line.split(':')[1].strip()

charging    = 1 if state in ('charging', 'fully-charged', 'pending-charge') else 0
discharging = 1 if state in ('discharging', 'pending-discharge') else 0

print(f'1|{percent}|{field(state)}|{charging}|{discharging}')
