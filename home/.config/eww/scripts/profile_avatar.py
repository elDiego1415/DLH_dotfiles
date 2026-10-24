#!/usr/bin/env python3
"""Print the best available local profile image for the Eww profile widget."""

import os
from pathlib import Path


home = Path.home()
username = os.environ.get("USER", "")
candidates = (
    home / ".face",
    home / ".face.icon",
    home / ".local/share/icons" / f"{username}.png",
    Path("/var/lib/AccountsService/icons") / username,
)

for candidate in candidates:
    if candidate.is_file():
        print(candidate)
        break
else:
    print(home / ".config/eww/profile-placeholder.svg")
