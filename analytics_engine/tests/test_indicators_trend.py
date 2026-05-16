"""T059: Regression tests for trend indicator outputs."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.technical.indicators import compute_trend


@pytest.fixture
def sample_df():
    np.random.seed(42)
    n = 100
    close = pd.Series(np.cumsum(np.random.randn(n)) + 100)
    high = close + np.abs(np.random.randn(n))
    low = close - np.abs(np.random.randn(n))
    volume = pd.Series(np.random.randint(1000, 100000, n))
    return pd.DataFrame({"open": close.shift(1).fillna(close.iloc[0]), "high": high, "low": low, "close": close, "volume": volume})


def test_trend_returns_list(sample_df):
    result = compute_trend(sample_df)
    assert isinstance(result, list)
    assert len(result) >= 4


def test_trend_has_sma(sample_df):
    result = compute_trend(sample_df)
    names = [r["name"] for r in result]
    assert "SMA_20" in names


def test_trend_signal_values(sample_df):
    result = compute_trend(sample_df)
    for r in result:
        assert r["signal"] in ("buy", "sell", "strong", "weak", None)
