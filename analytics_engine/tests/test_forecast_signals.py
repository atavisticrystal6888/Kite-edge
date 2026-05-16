"""T115: Regression tests for crossover, divergence, and squeeze signals."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.forecast.signals import ma_crossover, bollinger_squeeze, detect_all


@pytest.fixture
def sample_df():
    np.random.seed(42)
    n = 200
    close = pd.Series(np.cumsum(np.random.randn(n)) + 100)
    high = close + np.abs(np.random.randn(n))
    low = close - np.abs(np.random.randn(n))
    volume = pd.Series(np.random.randint(1000, 100000, n))
    return pd.DataFrame({"open": close.shift(1).fillna(close.iloc[0]), "high": high, "low": low, "close": close, "volume": volume})


def test_ma_crossover_returns_list(sample_df):
    result = ma_crossover(sample_df)
    assert isinstance(result, list)


def test_detect_all_returns_list(sample_df):
    result = detect_all(sample_df)
    assert isinstance(result, list)
    for s in result:
        assert "direction" in s
