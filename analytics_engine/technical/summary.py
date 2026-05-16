"""
T069: Technical summary scorer.

Produces a composite score from indicator signals:
  buy/oversold = +1, sell/overbought = -1, neutral/strong/weak/None = 0.
Score is normalized to [-100, +100] and banded: Strong Buy / Buy / Neutral /
Sell / Strong Sell.
"""
from __future__ import annotations

from analytics_engine.technical.indicators import compute_all

SIGNAL_WEIGHT = {
    "buy": 1,
    "sell": -1,
    "overbought": -1,
    "oversold": 1,
    "neutral": 0,
    "strong": 0,
    "weak": 0,
    "squeeze": 0,
    "normal": 0,
    None: 0,
}


def score(indicator_groups: dict) -> dict:
    """Return ``{score, band, contributors}`` from grouped indicators."""
    contributors: list[dict] = []
    total = 0
    count = 0
    for group_name, indicators in indicator_groups.items():
        for ind in indicators:
            w = SIGNAL_WEIGHT.get(ind.get("signal"), 0)
            total += w
            count += 1
            if w != 0:
                contributors.append({"indicator": ind["name"], "group": group_name, "weight": w})

    norm = round(total / max(count, 1) * 100, 2)
    band = _band(norm)
    return {"score": norm, "band": band, "contributors": contributors}


def compute_summary(df, params: dict | None = None, timeframe: str = "1d") -> dict:
    """Convenience: compute indicators then score them."""
    groups = compute_all(df, params)
    result = score(groups)
    result["timeframe"] = timeframe
    return result


def _band(s: float) -> str:
    if s >= 50:
        return "Strong Buy"
    if s >= 15:
        return "Buy"
    if s > -15:
        return "Neutral"
    if s > -50:
        return "Sell"
    return "Strong Sell"
