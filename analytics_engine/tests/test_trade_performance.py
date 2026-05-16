"""T135: Regression tests for trade performance metrics."""
import pytest
from analytics_engine.trades.cost_basis import match_fifo
from analytics_engine.trades.performance import summary_metrics, equity_curve


TRADES = [
    {"symbol": "RELIANCE", "side": "BUY", "quantity": 10, "price": 2500, "date": "2025-01-15"},
    {"symbol": "RELIANCE", "side": "SELL", "quantity": 10, "price": 2600, "date": "2025-03-15"},
    {"symbol": "TCS", "side": "BUY", "quantity": 5, "price": 3000, "date": "2025-02-01"},
    {"symbol": "TCS", "side": "SELL", "quantity": 5, "price": 2900, "date": "2025-04-01"},
]


def test_fifo_matching():
    matched = match_fifo(TRADES)
    assert len(matched) == 2
    assert matched[0].pnl == 1000  # 10 * (2600-2500)
    assert matched[1].pnl == -500  # 5 * (2900-3000)


def test_summary_metrics():
    matched = match_fifo(TRADES)
    m = summary_metrics(matched)
    assert m["total_trades"] == 2
    assert m["win_rate"] == 50.0


def test_equity_curve():
    matched = match_fifo(TRADES)
    ec = equity_curve(matched)
    assert len(ec["curve"]) == 2
