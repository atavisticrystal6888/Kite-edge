"""
T070: Support and resistance detection.

Uses pivot points and local extrema to identify key price levels.
"""
from __future__ import annotations

import numpy as np
import pandas as pd


def detect(df: pd.DataFrame, window: int = 20) -> dict:
    """Return ``{support: [...], resistance: [...]}``.

    Each entry is ``{price, strength, touches}``.
    """
    highs = df["high"].values
    lows = df["low"].values

    supports = _find_levels(lows, window, kind="support")
    resistances = _find_levels(highs, window, kind="resistance")

    return {"support": supports, "resistance": resistances}


def _find_levels(series: np.ndarray, window: int, kind: str) -> list[dict]:
    levels: list[dict] = []
    n = len(series)
    for i in range(window, n - window):
        if kind == "support":
            if series[i] == np.min(series[i - window : i + window + 1]):
                levels.append({"price": round(float(series[i]), 2), "index": i})
        else:
            if series[i] == np.max(series[i - window : i + window + 1]):
                levels.append({"price": round(float(series[i]), 2), "index": i})

    # cluster nearby levels
    clustered = _cluster(levels)
    return clustered


def _cluster(levels: list[dict], tolerance: float = 0.015) -> list[dict]:
    if not levels:
        return []
    sorted_levels = sorted(levels, key=lambda x: x["price"])
    clusters: list[list[dict]] = [[sorted_levels[0]]]
    for lvl in sorted_levels[1:]:
        if abs(lvl["price"] - clusters[-1][-1]["price"]) / max(clusters[-1][-1]["price"], 1e-9) < tolerance:
            clusters[-1].append(lvl)
        else:
            clusters.append([lvl])
    return [
        {
            "price": round(sum(l["price"] for l in c) / len(c), 2),
            "strength": len(c),
            "touches": len(c),
        }
        for c in clusters
    ]
