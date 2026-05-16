"""
T156-T157: Daily screening engine + signal ranking.
"""
from __future__ import annotations

import pandas as pd
from analytics_engine.forecast.signals import detect_all


def screen_holdings(
    holdings_data: list[dict],
    ohlcv_map: dict[str, pd.DataFrame],
) -> list[dict]:
    """T156: Screen each holding for active signals.

    ``ohlcv_map`` maps symbol → DataFrame with OHLCV columns.
    """
    all_signals: list[dict] = []
    for h in holdings_data:
        symbol = h.get("symbol", h.get("tradingsymbol", ""))
        df = ohlcv_map.get(symbol)
        if df is None or len(df) < 30:
            continue
        signals = detect_all(df)
        for s in signals:
            s["symbol"] = symbol
        all_signals.extend(signals)
    return all_signals


def rank_signals(signals: list[dict]) -> list[dict]:
    """T157: Rank signals by confidence score descending."""
    ranked = sorted(signals, key=lambda s: s.get("confidence_score", 0), reverse=True)
    for i, s in enumerate(ranked):
        s["rank"] = i + 1
    return ranked


def generate_signal_feed(
    holdings_data: list[dict],
    ohlcv_map: dict[str, pd.DataFrame],
) -> dict:
    """Convenience: screen + rank + attach disclaimers."""
    raw = screen_holdings(holdings_data, ohlcv_map)
    ranked = rank_signals(raw)
    return {
        "signals": ranked,
        "generated_at": pd.Timestamp.now().isoformat(),
        "disclaimers": [
            "Signals are heuristic screens, not financial advice.",
            "Past performance does not predict future results.",
        ],
    }
