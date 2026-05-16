"""T152: Regression tests for screening and signal ranking."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.api.services.signals import screen_holdings, rank_signals


@pytest.fixture
def holdings():
    return [{"symbol": "RELIANCE"}, {"symbol": "TCS"}]


@pytest.fixture
def ohlcv_map():
    np.random.seed(42)
    n = 200
    frames = {}
    for sym in ["RELIANCE", "TCS"]:
        close = pd.Series(np.cumsum(np.random.randn(n)) + 100)
        frames[sym] = pd.DataFrame({
            "open": close.shift(1).fillna(100),
            "high": close + 1,
            "low": close - 1,
            "close": close,
            "volume": np.random.randint(1000, 100000, n),
        })
    return frames


def test_screen_returns_signals(holdings, ohlcv_map):
    result = screen_holdings(holdings, ohlcv_map)
    assert isinstance(result, list)


def test_rank_signals_adds_rank():
    signals = [{"confidence_score": 0.5}, {"confidence_score": 0.9}]
    ranked = rank_signals(signals)
    assert ranked[0]["rank"] == 1
    assert ranked[0]["confidence_score"] == 0.9
