"""
T100-T101: Stress testing — historical and custom scenarios.
"""
from __future__ import annotations

import pandas as pd

# Pre-defined historical stress scenarios (approximate market drops).
HISTORICAL_SCENARIOS: dict[str, dict] = {
    "CRASH_2020_03": {
        "name": "COVID Crash (Mar 2020)",
        "nifty_shock": -0.38,
        "description": "NIFTY 50 fell ~38% from Jan 2020 peak to Mar 2020 trough.",
    },
    "DEMONETIZATION_2016": {
        "name": "Demonetization (Nov 2016)",
        "nifty_shock": -0.08,
        "description": "Brief 8% correction following demonetization announcement.",
    },
    "GFC_2008": {
        "name": "Global Financial Crisis (2008)",
        "nifty_shock": -0.60,
        "description": "NIFTY 50 fell ~60% from Jan 2008 peak to Oct 2008 trough.",
    },
    "TAPER_TANTRUM_2013": {
        "name": "Taper Tantrum (2013)",
        "nifty_shock": -0.12,
        "description": "~12% correction as US Fed signalled tapering.",
    },
}


def historical_stress(
    holdings: list[dict],
    scenario_code: str,
    beta_map: dict[str, float] | None = None,
) -> dict:
    """T100: Apply a historical scenario to the current portfolio.

    Each holding impact = weight * beta * scenario_shock.
    """
    scenario = HISTORICAL_SCENARIOS.get(scenario_code)
    if not scenario:
        return {"error": f"Unknown scenario: {scenario_code}"}

    shock = scenario["nifty_shock"]
    total_value = sum(h.get("current_value", 0) for h in holdings) or 1
    beta_map = beta_map or {}

    holding_impacts: list[dict] = []
    portfolio_impact = 0.0
    for h in holdings:
        symbol = h.get("symbol", h.get("tradingsymbol", ""))
        weight = h.get("current_value", 0) / total_value
        b = beta_map.get(symbol, 1.0)
        impact = weight * b * shock
        portfolio_impact += impact
        holding_impacts.append({
            "symbol": symbol,
            "weight": round(weight, 4),
            "beta": round(b, 4),
            "impact_pct": round(impact * 100, 2),
        })

    return {
        "scenario": scenario,
        "portfolio_impact_pct": round(portfolio_impact * 100, 2),
        "holding_impacts": holding_impacts,
    }


def custom_stress(
    holdings: list[dict],
    factor_shocks: list[dict],
    beta_map: dict[str, float] | None = None,
) -> dict:
    """T101: Apply custom factor shocks.

    ``factor_shocks``: ``[{factor, shock_pct}]``
    """
    total_value = sum(h.get("current_value", 0) for h in holdings) or 1
    beta_map = beta_map or {}

    total_shock = sum(s.get("shock_pct", 0) for s in factor_shocks) / 100

    holding_impacts: list[dict] = []
    portfolio_impact = 0.0
    for h in holdings:
        symbol = h.get("symbol", h.get("tradingsymbol", ""))
        weight = h.get("current_value", 0) / total_value
        b = beta_map.get(symbol, 1.0)
        impact = weight * b * total_shock
        portfolio_impact += impact
        holding_impacts.append({
            "symbol": symbol,
            "weight": round(weight, 4),
            "impact_pct": round(impact * 100, 2),
        })

    return {
        "scenario": {"name": "Custom", "shocks": factor_shocks},
        "portfolio_impact_pct": round(portfolio_impact * 100, 2),
        "holding_impacts": holding_impacts,
    }
