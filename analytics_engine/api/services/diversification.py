"""
T160: Diversification analysis and improvement suggestions.
"""
from __future__ import annotations

import numpy as np


def analyze(holdings: list[dict]) -> dict:
    """Compute diversification metrics and suggestions."""
    if not holdings:
        return {"score": 0, "suggestions": []}

    total = sum(float(h.get("current_value", 0)) for h in holdings) or 1

    # Sector concentration
    sectors: dict[str, float] = {}
    for h in holdings:
        sector = h.get("sector") or "Unclassified"
        w = float(h.get("current_value", 0)) / total
        sectors[sector] = sectors.get(sector, 0) + w

    # HHI
    weights = [float(h.get("current_value", 0)) / total for h in holdings]
    hhi = sum(w ** 2 for w in weights)

    # Score: lower HHI = better diversified → scale to 0-100
    score = max(0, min(100, round((1 - hhi) * 100, 1)))

    suggestions: list[str] = []
    for sector, w in sectors.items():
        if w > 0.4:
            suggestions.append(f"High concentration in {sector} ({w:.0%}). Consider diversifying.")

    if len(holdings) < 5:
        suggestions.append("Portfolio has fewer than 5 holdings. Consider adding more instruments.")

    top_holding = max(weights) if weights else 0
    if top_holding > 0.25:
        suggestions.append(f"Largest position is {top_holding:.0%} of portfolio. Consider trimming.")

    return {
        "diversification_score": score,
        "hhi": round(hhi, 4),
        "sector_weights": {k: round(v, 4) for k, v in sectors.items()},
        "n_holdings": len(holdings),
        "suggestions": suggestions,
    }
