"""T136: Regression tests for execution quality analytics."""
import pytest
from analytics_engine.trades.execution import execution_quality


def test_no_expected_price():
    trades = [{"symbol": "REL", "side": "BUY", "price": 100, "quantity": 10, "date": "2025-01-01"}]
    result = execution_quality(trades)
    assert result["n"] == 1


def test_with_expected_price():
    trades = [{"symbol": "REL", "side": "BUY", "price": 100.5, "expected_price": 100, "quantity": 10, "date": "2025-01-01"}]
    result = execution_quality(trades)
    assert result["avg_slippage_bps"] > 0  # bought higher than expected
