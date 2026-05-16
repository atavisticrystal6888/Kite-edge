"""T062: Property-based tests for technical summary weighting model."""
import pytest
from analytics_engine.technical.summary import score, _band


def test_score_empty():
    result = score({})
    assert result["score"] == 0
    assert result["band"] == "Neutral"


def test_score_all_buy():
    groups = {"trend": [{"name": "SMA", "value": 100, "signal": "buy"} for _ in range(5)]}
    result = score(groups)
    assert result["score"] > 0
    assert result["band"] in ("Strong Buy", "Buy")


def test_score_all_sell():
    groups = {"trend": [{"name": "SMA", "value": 100, "signal": "sell"} for _ in range(5)]}
    result = score(groups)
    assert result["score"] < 0
    assert result["band"] in ("Strong Sell", "Sell")


def test_band_thresholds():
    assert _band(60) == "Strong Buy"
    assert _band(20) == "Buy"
    assert _band(0) == "Neutral"
    assert _band(-20) == "Sell"
    assert _band(-60) == "Strong Sell"
