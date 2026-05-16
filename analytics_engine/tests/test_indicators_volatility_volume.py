"""T061: Regression tests for volatility, volume, and return indicators."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.technical.indicators import compute_volatility, compute_volume, compute_returns


@pytest.fixture
def sample_df():
    np.random.seed(42)
    n = 100
    close = pd.Series(np.cumsum(np.random.randn(n)) + 100)
    high = close + np.abs(np.random.randn(n))
    low = close - np.abs(np.random.randn(n))
    volume = pd.Series(np.random.randint(1000, 100000, n))
    return pd.DataFrame({"open": close.shift(1).fillna(close.iloc[0]), "high": high, "low": low, "close": close, "volume": volume})


def test_volatility_has_atr(sample_df):
    result = compute_volatility(sample_df)
    names = [r["name"] for r in result]
    assert "ATR" in names


def test_volume_has_obv(sample_df):
    result = compute_volume(sample_df)
    names = [r["name"] for r in result]
    assert "OBV" in names


def test_returns_has_daily(sample_df):
    result = compute_returns(sample_df)
    names = [r["name"] for r in result]
    assert "Daily_Return" in names
