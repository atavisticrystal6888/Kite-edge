"""T060: Regression tests for momentum indicator outputs."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.technical.indicators import compute_momentum


@pytest.fixture
def sample_df():
    np.random.seed(42)
    n = 100
    close = pd.Series(np.cumsum(np.random.randn(n)) + 100)
    high = close + np.abs(np.random.randn(n))
    low = close - np.abs(np.random.randn(n))
    volume = pd.Series(np.random.randint(1000, 100000, n))
    return pd.DataFrame({"open": close.shift(1).fillna(close.iloc[0]), "high": high, "low": low, "close": close, "volume": volume})


def test_momentum_returns_list(sample_df):
    result = compute_momentum(sample_df)
    assert isinstance(result, list)
    assert len(result) >= 4


def test_rsi_in_range(sample_df):
    result = compute_momentum(sample_df)
    rsi = next(r for r in result if r["name"] == "RSI")
    assert 0 <= rsi["value"] <= 100
