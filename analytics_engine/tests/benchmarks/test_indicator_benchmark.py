"""T185: Indicator computation benchmark coverage."""
import pytest
import time
import pandas as pd
import numpy as np
from analytics_engine.technical.indicators import (
    compute_trend,
    compute_momentum,
    compute_volatility,
    compute_volume,
)


@pytest.fixture
def large_df():
    np.random.seed(42)
    n = 5000
    close = pd.Series(np.cumsum(np.random.randn(n)) + 500)
    high = close + np.abs(np.random.randn(n))
    low = close - np.abs(np.random.randn(n))
    volume = pd.Series(np.random.randint(1000, 500000, n))
    return pd.DataFrame(
        {
            "open": close.shift(1).fillna(close.iloc[0]),
            "high": high,
            "low": low,
            "close": close,
            "volume": volume,
        }
    )


class TestTrendBenchmark:
    def test_trend_under_five_seconds(self, large_df):
        start = time.perf_counter()
        result = compute_trend(large_df)
        elapsed = time.perf_counter() - start
        assert isinstance(result, list)
        assert elapsed < 5.0

    def test_trend_large_dataset_produces_output(self, large_df):
        result = compute_trend(large_df)
        assert len(result) >= 4


class TestMomentumBenchmark:
    def test_momentum_under_five_seconds(self, large_df):
        start = time.perf_counter()
        result = compute_momentum(large_df)
        elapsed = time.perf_counter() - start
        assert isinstance(result, list)
        assert elapsed < 5.0


class TestVolatilityBenchmark:
    def test_volatility_under_five_seconds(self, large_df):
        start = time.perf_counter()
        result = compute_volatility(large_df)
        elapsed = time.perf_counter() - start
        assert isinstance(result, list)
        assert elapsed < 5.0


class TestVolumeBenchmark:
    def test_volume_under_five_seconds(self, large_df):
        start = time.perf_counter()
        result = compute_volume(large_df)
        elapsed = time.perf_counter() - start
        assert isinstance(result, list)
        assert elapsed < 5.0
