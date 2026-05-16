"""T114: Regression tests for Prophet forecasts."""
import pytest
import pandas as pd
import numpy as np


@pytest.fixture
def prophet_df():
    np.random.seed(42)
    dates = pd.date_range("2024-01-01", periods=200, freq="B")
    prices = np.cumsum(np.random.randn(200)) + 100
    return pd.DataFrame({"ds": dates, "y": prices})


def test_prophet_forecast_import():
    """Verify prophet_model module is importable."""
    from analytics_engine.forecast import prophet_model
    assert hasattr(prophet_model, "forecast")


def test_prophet_forecast_signature(prophet_df):
    """Verify forecast function accepts expected parameters."""
    from analytics_engine.forecast.prophet_model import forecast
    import inspect
    sig = inspect.signature(forecast)
    params = list(sig.parameters.keys())
    assert "df" in params
    assert "horizon" in params
    assert "confidence" in params


def test_prophet_forecast_with_mock(prophet_df, monkeypatch):
    """Test prophet forecast with mocked Prophet class."""
    mock_called = {"fit": False, "predict": False}

    class MockProphet:
        def __init__(self, **kwargs):
            pass

        def fit(self, df):
            mock_called["fit"] = True
            return self

        def make_future_dataframe(self, periods):
            dates = pd.date_range("2024-01-01", periods=200 + periods, freq="B")
            return pd.DataFrame({"ds": dates})

        def predict(self, future):
            mock_called["predict"] = True
            n = len(future)
            return pd.DataFrame({
                "ds": future["ds"],
                "yhat": np.random.randn(n) + 100,
                "yhat_lower": np.random.randn(n) + 95,
                "yhat_upper": np.random.randn(n) + 105,
            })

    monkeypatch.setattr(
        "analytics_engine.forecast.prophet_model.Prophet",
        MockProphet,
        raising=False,
    )

    # Use a dynamic import approach
    import importlib
    mod = importlib.import_module("analytics_engine.forecast.prophet_model")
    # prophet import is deferred inside forecast(), so we monkey-patch the builtins
    original_import = __builtins__.__import__ if hasattr(__builtins__, "__import__") else __import__

    def mock_import(name, *args, **kwargs):
        if name == "prophet":
            import types
            m = types.ModuleType("prophet")
            m.Prophet = MockProphet
            return m
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr("builtins.__import__", mock_import)

    result = mod.forecast(prophet_df, horizon=10)
    assert isinstance(result, dict)
    assert "forecasts" in result
