"""T088: Correlation and covariance matrix contract tests."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.risk.correlation import correlation_matrix, covariance_matrix, marginal_risk_contribution


@pytest.fixture
def returns_df():
    np.random.seed(42)
    return pd.DataFrame({
        "A": np.random.randn(100) * 0.01,
        "B": np.random.randn(100) * 0.01,
        "C": np.random.randn(100) * 0.01,
    })


def test_correlation_shape(returns_df):
    result = correlation_matrix(returns_df)
    assert len(result["symbols"]) == 3
    assert len(result["matrix"]) == 3


def test_covariance_shape(returns_df):
    result = covariance_matrix(returns_df)
    assert len(result["symbols"]) == 3


def test_marginal_risk(returns_df):
    result = marginal_risk_contribution(returns_df)
    assert len(result["marginal_contributions"]) == 3
