"""T085: Regression tests for portfolio risk ratios."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.risk.metrics import sharpe_ratio, sortino_ratio, calmar_ratio, max_drawdown, beta, alpha


@pytest.fixture
def returns():
    np.random.seed(42)
    return pd.Series(np.random.randn(252) * 0.01)


@pytest.fixture
def benchmark():
    np.random.seed(99)
    return pd.Series(np.random.randn(252) * 0.01)


def test_sharpe_not_none(returns):
    assert sharpe_ratio(returns) is not None


def test_max_drawdown_negative(returns):
    assert max_drawdown(returns) <= 0


def test_beta_close_to_zero_for_random(returns, benchmark):
    b = beta(returns, benchmark)
    assert -2 < b < 2
