"""
T143: Slippage and best-execution analysis.
"""
from __future__ import annotations


def execution_quality(trades: list[dict]) -> dict:
    """Compute slippage metrics from trade data.

    Each trade: {symbol, side, price, expected_price?, quantity, date}.
    """
    if not trades:
        return {"n": 0, "avg_slippage_bps": 0}

    slippages: list[float] = []
    for t in trades:
        expected = t.get("expected_price")
        if expected is None:
            continue
        actual = float(t["price"])
        exp = float(expected)
        if exp == 0:
            continue
        slip_bps = ((actual - exp) / exp) * 10_000
        if t.get("side", "").upper() == "SELL":
            slip_bps = -slip_bps  # for sells, higher actual is better
        slippages.append(slip_bps)

    if not slippages:
        return {"n": len(trades), "avg_slippage_bps": 0, "note": "No expected_price data"}

    import numpy as np

    return {
        "n": len(slippages),
        "avg_slippage_bps": round(float(np.mean(slippages)), 2),
        "median_slippage_bps": round(float(np.median(slippages)), 2),
        "worst_slippage_bps": round(float(max(slippages)), 2),
        "best_slippage_bps": round(float(min(slippages)), 2),
    }
