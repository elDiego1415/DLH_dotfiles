#!/usr/bin/env python3
"""Fetch the latest available S&P 500 quote for the Eww widget."""

import json
import math
import subprocess
import time
import urllib.request
from datetime import datetime
from pathlib import Path


URL = "https://query1.finance.yahoo.com/v8/finance/chart/%5EGSPC?range=1d&interval=1m"
CACHE = Path.home() / ".cache/eww"


def write_chart(bars, opening, up):
    # Render at 2x and let Eww scale down for crisp edges on HiDPI displays.
    width, height, pad = 392, 96, 8
    prices = [price for _, price in bars]
    low, high = min(min(prices), opening), max(max(prices), opening)
    spread = max(high - low, abs(high) * 0.0002)
    low -= spread * 0.12
    high += spread * 0.12
    points = []
    for index, (_, price) in enumerate(bars):
        x = pad + index * (width - 2 * pad) / max(len(prices) - 1, 1)
        y = height - pad - (price - low) * (height - 2 * pad) / (high - low)
        points.append((x, y))

    line = "M " + " L ".join(f"{x:.2f} {y:.2f}" for x, y in points)
    color = "#a6e3a1" if up else "#f38ba8"
    last_x, last_y = points[-1]
    open_y = height - pad - (opening - low) * (height - 2 * pad) / (high - low)
    svg = (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
        f'<path d="M {pad} {open_y:.2f} H {width - pad}" fill="none" stroke="#f9e2af" stroke-width="2" stroke-dasharray="4 6" stroke-linecap="round"/>'
        f'<path d="{line}" fill="none" stroke="{color}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>'
        f'<circle cx="{last_x:.2f}" cy="{last_y:.2f}" r="6" fill="{color}"/>'
        "</svg>"
    )
    CACHE.mkdir(parents=True, exist_ok=True)
    chart = CACHE / f"sp500-{int(time.time())}.svg"
    chart.write_text(svg, encoding="utf-8")
    # Keep a small rolling set so Eww can swap image paths without stale files accumulating.
    for old in sorted(CACHE.glob("sp500-*.svg"), key=lambda path: path.stat().st_mtime, reverse=True)[4:]:
        old.unlink(missing_ok=True)
    subprocess.run(["eww", "update", f"sp500_chart={chart}"], check=False, capture_output=True)


def main():
    request = urllib.request.Request(URL, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(request, timeout=8) as response:
            payload = json.load(response)
        result = payload["chart"]["result"][0]
        meta = result["meta"]
        quote = result["indicators"]["quote"][0]
        bars = [
            (stamp, close)
            for stamp, close in zip(result.get("timestamp", []), quote["close"])
            if close is not None and math.isfinite(close)
        ]
        if not bars:
            raise ValueError("No hay cotización disponible")

        price = bars[-1][1]
        opening_values = [value for value in quote.get("open", []) if value is not None and math.isfinite(value)]
        opening = opening_values[0] if opening_values else bars[0][1]
        previous = meta.get("chartPreviousClose") or meta.get("previousClose")
        change = price - previous if previous else 0
        percent = change / previous * 100 if previous else 0
        arrow = "▲" if change >= 0 else "▼"
        write_chart(bars, opening, change >= 0)
        as_of = datetime.fromtimestamp(bars[-1][0]).astimezone().strftime("%H:%M")
        print(f"US$ {price:,.2f}  {arrow} {abs(percent):.2f}%  ·  {as_of}")
    except (OSError, KeyError, IndexError, TypeError, ValueError):
        print("Cotización no disponible")


if __name__ == "__main__":
    main()
