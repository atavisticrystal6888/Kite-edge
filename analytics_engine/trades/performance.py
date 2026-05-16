"""
T140-T142, T144: Trade performance metrics.

- Per-trade P&L (T140)
- Win rate, expectancy, streaks (T141)
- Holding period and time patterns (T142)
- Rolling equity curve and drawdown (T144)
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from analytics_engine.trades.cost_basis import MatchedTrade


def per_trade_pnl(matched: list[MatchedTrade]) -> list[dict]:
    """T140: Per-trade P&L."""
    return [
        {
            "symbol": m.symbol,
            "buy_price": m.buy_price,
            "sell_price": m.sell_price,
            "quantity": m.quantity,
            "pnl": m.pnl,
            "holding_period_days": m.holding_period_days,
            "return_pct": round((m.sell_price / m.buy_price - 1) * 100, 2) if m.buy_price else 0,
        }
        for m in matched
    ]


def summary_metrics(matched: list[MatchedTrade]) -> dict:
    """T141: Win rate, expectancy, streak metrics."""
    if not matched:
        return {"total_trades": 0}

    pnls = [m.pnl for m in matched]
    wins = [p for p in pnls if p > 0]
    losses = [p for p in pnls if p < 0]
    win_rate = len(wins) / len(pnls) * 100

    avg_win = np.mean(wins) if wins else 0.0
    avg_loss = abs(np.mean(losses)) if losses else 0.0
    expectancy = (win_rate / 100 * avg_win) - ((1 - win_rate / 100) * avg_loss)

    # Streaks
    current_streak = 0
    max_win_streak = 0
    max_loss_streak = 0
    streak = 0
    for p in pnls:
        if p > 0:
            streak = streak + 1 if streak > 0 else 1
            max_win_streak = max(max_win_streak, streak)
        else:
            streak = streak - 1 if streak < 0 else -1
            max_loss_streak = max(max_loss_streak, abs(streak))
        current_streak = streak

    return {
        "total_trades": len(pnls),
        "total_pnl": round(sum(pnls), 2),
        "win_rate": round(win_rate, 2),
        "avg_win": round(float(avg_win), 2),
        "avg_loss": round(float(avg_loss), 2),
        "expectancy": round(float(expectancy), 2),
        "max_win_streak": max_win_streak,
        "max_loss_streak": max_loss_streak,
        "current_streak": current_streak,
        "profit_factor": round(sum(wins) / abs(sum(losses)), 2) if losses and sum(losses) != 0 else None,
    }


def holding_period_analysis(matched: list[MatchedTrade]) -> dict:
    """T142: Holding-period and time-pattern analysis."""
    if not matched:
        return {"avg_holding_days": 0}

    days = [m.holding_period_days for m in matched]
    return {
        "avg_holding_days": round(float(np.mean(days)), 1),
        "median_holding_days": round(float(np.median(days)), 1),
        "min_holding_days": int(min(days)),
        "max_holding_days": int(max(days)),
    }


def equity_curve(matched: list[MatchedTrade]) -> dict:
    """T144: Rolling equity curve and drawdown."""
    if not matched:
        return {"curve": [], "drawdown": []}

    sorted_trades = sorted(matched, key=lambda m: m.sell_date)
    cumulative = 0.0
    peak: float | None = None
    curve: list[dict] = []
    drawdown: list[dict] = []

    for m in sorted_trades:
        cumulative += m.pnl
        if peak is None:
            peak = cumulative
        else:
            peak = max(peak, cumulative)
        dd = (cumulative - peak) / abs(peak) if peak != 0 else 0.0
        curve.append({"date": m.sell_date, "equity": round(cumulative, 2)})
        drawdown.append({"date": m.sell_date, "drawdown_pct": round(dd * 100, 2)})

    return {"curve": curve, "drawdown": drawdown}
