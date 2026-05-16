"""T153: Regression tests for the rebalance calculator."""
import pytest
from analytics_engine.api.services.rebalance import rebalance, tax_loss_candidates


def test_equal_weight_rebalance():
    holdings = [
        {"symbol": "A", "current_value": 6000},
        {"symbol": "B", "current_value": 4000},
    ]
    result = rebalance(holdings)
    assert "recommended_actions" in result
    assert "disclaimers" in result


def test_tax_loss_candidates():
    holdings = [
        {"symbol": "A", "pnl_percent": -10, "pnl": -1000, "current_value": 9000},
        {"symbol": "B", "pnl_percent": 5, "pnl": 500, "current_value": 10500},
    ]
    candidates = tax_loss_candidates(holdings)
    assert len(candidates) == 1
    assert candidates[0]["symbol"] == "A"
