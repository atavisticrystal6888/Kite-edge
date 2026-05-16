"""T087: Monte Carlo VaR convergence tests."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.risk.var import monte_carlo_var


@pytest.fixture
def returns():
    np.random.seed(42)
    return pd.Series(np.random.randn(252) * 0.01)


def test_mc_var_returns_result(returns):
    result = monte_carlo_var(returns, 0.95, simulations=1000, seed=42)
    assert result["var"] < 0
    assert result["method"] == "monte_carlo"


def test_mc_var_more_sims_converge(returns):
    r1 = monte_carlo_var(returns, 0.95, simulations=1000, seed=42)
    r2 = monte_carlo_var(returns, 0.95, simulations=10000, seed=42)
    # Both should be in similar ballpark
    assert abs(r1["var"] - r2["var"]) < 0.05
