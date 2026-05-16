"""T086: Distribution tests for historical and parametric VaR."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.risk.var import historical_var, parametric_var


@pytest.fixture
def returns():
    np.random.seed(42)
    return pd.Series(np.random.randn(252) * 0.01)


def test_historical_var_95(returns):
    result = historical_var(returns, 0.95)
    assert result["var"] < 0
    assert result["method"] == "historical"


def test_parametric_var_99(returns):
    result = parametric_var(returns, 0.99)
    assert result["var"] < 0
    assert result["method"] == "parametric"
