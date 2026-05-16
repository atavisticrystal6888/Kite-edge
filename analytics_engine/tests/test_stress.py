"""T089: Stress scenario regression tests."""
import pytest
from analytics_engine.risk.stress import historical_stress, custom_stress

HOLDINGS = [
    {"symbol": "RELIANCE", "current_value": 50000},
    {"symbol": "TCS", "current_value": 30000},
    {"symbol": "INFY", "current_value": 20000},
]


def test_historical_stress_known_scenario():
    result = historical_stress(HOLDINGS, "CRASH_2020_03")
    assert result["portfolio_impact_pct"] < 0
    assert len(result["holding_impacts"]) == 3


def test_historical_stress_unknown():
    result = historical_stress(HOLDINGS, "UNKNOWN")
    assert "error" in result


def test_custom_stress():
    result = custom_stress(HOLDINGS, [{"factor": "market", "shock_pct": -10}])
    assert result["portfolio_impact_pct"] < 0
