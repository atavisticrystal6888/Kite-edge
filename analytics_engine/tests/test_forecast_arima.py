"""T113: Regression tests for ARIMA forecasts."""
import pytest
import pandas as pd
import numpy as np
from analytics_engine.forecast.arima import forecast


@pytest.fixture
def price_series():
    np.random.seed(42)
    dates = pd.date_range("2025-01-01", periods=200, freq="D")
    values = np.cumsum(np.random.randn(200)) + 100
    return pd.Series(values, index=dates)


def test_arima_returns_forecasts(price_series):
    result = forecast(price_series, horizon=5)
    assert result["model"] == "arima"
    assert len(result["forecasts"]) == 5


def test_arima_has_bounds(price_series):
    result = forecast(price_series, horizon=5)
    for pt in result["forecasts"]:
        assert pt["lower"] <= pt["predicted"] <= pt["upper"]
