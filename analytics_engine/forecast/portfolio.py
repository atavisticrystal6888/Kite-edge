"""
T125: Portfolio-level forecast aggregation.
"""
from __future__ import annotations


def aggregate_forecasts(
    holding_forecasts: list[dict],
    weights: list[float],
    horizons: list[int] | None = None,
) -> dict:
    """Combine per-holding forecasts into a portfolio-level forecast.

    Each ``holding_forecasts[i]`` has ``forecasts: [{date, predicted, lower, upper}]``.
    """
    if not holding_forecasts:
        return {"portfolio_forecasts": [], "disclaimers": _disclaimers()}

    horizons = horizons or [5, 10, 30]
    results: list[dict] = []

    for h in horizons:
        pred = 0.0
        lo = 0.0
        hi = 0.0
        for i, fc in enumerate(holding_forecasts):
            pts = fc.get("forecasts", [])
            if h - 1 < len(pts):
                w = weights[i] if i < len(weights) else 0.0
                pred += w * pts[h - 1]["predicted"]
                lo += w * pts[h - 1]["lower"]
                hi += w * pts[h - 1]["upper"]
        results.append({
            "horizon_days": h,
            "predicted_value": round(pred, 2),
            "lower_bound": round(lo, 2),
            "upper_bound": round(hi, 2),
        })

    return {
        "portfolio_forecasts": results,
        "distribution_summary": {
            "n_holdings": len(holding_forecasts),
        },
        "disclaimers": _disclaimers(),
    }


def _disclaimers() -> list[str]:
    return [
        "Forecasts are statistical projections, not recommendations, and will be wrong sometimes.",
        "Past performance does not predict future results.",
    ]
