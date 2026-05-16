"""T116: Portfolio forecast aggregation tests."""
import pytest
from analytics_engine.forecast.portfolio import aggregate_forecasts


def test_empty_forecasts():
    result = aggregate_forecasts([], [])
    assert result["portfolio_forecasts"] == []
    assert len(result["disclaimers"]) > 0


def test_single_holding():
    fc = [{"forecasts": [{"date": "2026-01-01", "predicted": 100, "lower": 90, "upper": 110}]}]
    result = aggregate_forecasts(fc, [1.0], horizons=[1])
    assert len(result["portfolio_forecasts"]) == 1
    assert result["portfolio_forecasts"][0]["predicted_value"] == 100
