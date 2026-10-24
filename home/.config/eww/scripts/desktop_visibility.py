#!/usr/bin/env python3
"""Listen for Hyprland window/workspace events and report whether the desktop is empty."""

import json
import os
import socket
import subprocess
import time


RELEVANT_EVENTS = (
    "openwindow",
    "closewindow",
    "movewindow",
    "movewindowv2",
    "workspace",
    "workspacev2",
    "focusedmon",
    "focusedmonv2",
    "activespecial",
    "activespecialv2",
)
WIDGETS = ("profile", "disk_usage", "sp500")


def hypr_json(command):
    output = subprocess.check_output(["hyprctl", "-j", *command], timeout=2, text=True)
    return json.loads(output)


def desktop_state():
    workspace = hypr_json(["activeworkspace"])
    clients = hypr_json(["clients"])
    active_id = workspace["id"]
    occupied = any(
        client.get("mapped", False)
        and not client.get("hidden", False)
        and client.get("workspace", {}).get("id") == active_id
        for client in clients
    )
    return "occupied" if occupied else "empty"


def socket_path():
    runtime_dir = os.environ["XDG_RUNTIME_DIR"]
    instance = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    return f"{runtime_dir}/hypr/{instance}/.socket2.sock"


def sync_widgets(state):
    command = ["eww", "open-many", *WIDGETS] if state == "empty" else ["eww", "close", *WIDGETS]
    try:
        subprocess.run(command, check=False, capture_output=True, text=True, timeout=5)
    except (OSError, subprocess.SubprocessError):
        # Eww can be restarting while the Hyprland event listener reconnects.
        pass


def ensure_eww():
    try:
        if subprocess.run(["eww", "ping"], capture_output=True, timeout=2).returncode == 0:
            return
        subprocess.run(["eww", "daemon"], capture_output=True, timeout=5)
        for _ in range(30):
            if subprocess.run(["eww", "ping"], capture_output=True, timeout=1).returncode == 0:
                return
            time.sleep(0.1)
    except (OSError, subprocess.SubprocessError):
        pass


def main():
    last_state = None
    while True:
        try:
            path = socket_path()
            state = desktop_state()
            if state != last_state:
                ensure_eww()
                sync_widgets(state)
                last_state = state

            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
                connection.connect(path)
                reader = connection.makefile("r", encoding="utf-8", errors="replace")
                for event in reader:
                    name = event.partition(">>")[0]
                    if name not in RELEVANT_EVENTS:
                        continue
                    try:
                        state = desktop_state()
                    except (OSError, subprocess.SubprocessError, json.JSONDecodeError, KeyError, TypeError):
                        continue
                    if state != last_state:
                        ensure_eww()
                        sync_widgets(state)
                        last_state = state
        except (OSError, KeyError, subprocess.SubprocessError, json.JSONDecodeError):
            # Reconnect if Hyprland restarts or the event socket is briefly unavailable.
            time.sleep(2)


if __name__ == "__main__":
    main()
