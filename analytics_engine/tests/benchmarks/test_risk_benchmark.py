"""T186: Risk analysis benchmark coverage."""
import pytest
import time
import pandas as pd
import numpy as np
from analytics_engine.risk.metrics import sharpe_ratio, sortino_ratio, max_drawdown, beta
from analytics_engine.risk.var import historical_var, parametric_var
from analytics_engine.risk.correlation import correlation_matrix


@pytest.fixture
def large_returns():
    np.random.seed(42)
    return pd.Series(np.random.randn(5000) * 0.01)


@pytest.fixture
def large_benchmark():
    np.random.seed(99)
    return pd.Series(np.random.randn(5000) * 0.01)


@pytest.fixture
def multi_asset_returns():
    np.random.seed(42)
    n = 2000
    return pd.DataFrame(
        {f"asset_{i}": np.random.randn(n) * 0.01 for i in range(20)}
    )


class TestRatiosBenchmark:
    def test_sharpe_large(self, large_returns):
        start = time.perf_counter()
        result = sharpe_ratio(large_returns)
        elapsed = time.perf_counter() - start
        assert isinstance(result, float)
        assert elapsed < 5.0

    def test_sortino_large(self, large_returns):
        start = time.perf_counter()
        result = sortino_ratio(large_returns)
        elapsed = time.perf_counter() - start
        assert isinstance(result, float)
        assert elapsed < 5.0

    def test_max_drawdown_large(self, large_returns):
        result = max_drawdown(large_returns)
        assert result <= 0

    def test_beta_large(self, large_returns, large_benchmark):
        start = time.perf_counter()
        result = beta(large_returns, large_benchmark)
        elapsed = time.perf_counter() - start
        assert isinstance(result, float)
        assert elapsed < 5.0


class TestVaRBenchmark:
    def test_historical_var_large(self, large_returns):
        start = time.perf_counter()
        result = historical_var(large_returns)
        elapsed = time.perf_counter() - start
        assert isinstance(result, dict)
        assert "var" in result
        assert elapsed < 5.0

    def test_parametric_var_large(self, large_returns):
        start = time.perf_counter()
        result = parametric_var(large_returns)
        elapsed = time.perf_counter() - start
        assert isinstance(result, dict)
        assert "var" in result
        assert elapsed < 5.0


class TestCorrelationBenchmark:
    def test_correlation_20_assets(self, multi_asset_returns):
        start = time.perf_counter()
        result = correlation_matrix(multi_asset_returns)
        elapsed = time.perf_counter() - start
        assert isinstance(result, dict)
        assert len(result["matrix"]) == 20
        assert len(result["matrix"][0]) == 20
        assert elapsed < 5.0
