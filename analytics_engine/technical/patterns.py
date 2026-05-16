"""
T071: Candlestick pattern recognition.

Uses ta-lib style heuristics to detect common candle patterns.
"""
from __future__ import annotations

import pandas as pd


def detect_patterns(df: pd.DataFrame) -> list[dict]:
    """Return a list of detected candlestick patterns with index and direction."""
    results: list[dict] = []
    if len(df) < 3:
        return results

    o = df["open"].values
    h = df["high"].values
    l = df["low"].values  # noqa: E741
    c = df["close"].values

    for i in range(2, len(df)):
        body = abs(c[i] - o[i])
        upper_shadow = h[i] - max(o[i], c[i])
        lower_shadow = min(o[i], c[i]) - l[i]
        total_range = h[i] - l[i]

        if total_range == 0:
            continue

        # Doji
        if body / total_range < 0.05:
            results.append(_pattern("Doji", i, "neutral", df))

        # Hammer (bullish)
        if lower_shadow > 2 * body and upper_shadow < body * 0.3 and c[i] > o[i]:
            results.append(_pattern("Hammer", i, "bullish", df))

        # Shooting Star (bearish)
        if upper_shadow > 2 * body and lower_shadow < body * 0.3 and c[i] < o[i]:
            results.append(_pattern("Shooting Star", i, "bearish", df))

        # Engulfing patterns
        if i >= 1:
            prev_body = abs(c[i - 1] - o[i - 1])
            if c[i] > o[i] and c[i - 1] < o[i - 1] and body > prev_body:
                if o[i] <= c[i - 1] and c[i] >= o[i - 1]:
                    results.append(_pattern("Bullish Engulfing", i, "bullish", df))
            if c[i] < o[i] and c[i - 1] > o[i - 1] and body > prev_body:
                if o[i] >= c[i - 1] and c[i] <= o[i - 1]:
                    results.append(_pattern("Bearish Engulfing", i, "bearish", df))

    return results


def _pattern(name: str, idx: int, direction: str, df: pd.DataFrame) -> dict:
    date = str(df.index[idx]) if hasattr(df.index, "__getitem__") else str(idx)
    return {
        "name": name,
        "index": idx,
        "date": date,
        "direction": direction,
        "close": round(float(df["close"].iloc[idx]), 2),
    }
