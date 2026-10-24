#!/usr/bin/env python3
"""Report root filesystem usage for the Eww disk widget."""

import shutil
import sys


usage = shutil.disk_usage("/")
percent = round(usage.used / usage.total * 100) if usage.total else 0


def gibibytes(value):
    return f"{value / (1024 ** 3):.0f} GB"


if len(sys.argv) > 1 and sys.argv[1] == "percent":
    print(percent)
else:
    print(f"{gibibytes(usage.free)} libres de {gibibytes(usage.total)}")
