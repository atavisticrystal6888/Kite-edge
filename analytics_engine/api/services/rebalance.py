"""
T158-T159: Target-allocation rebalance + tax-loss harvesting detection.
"""
from __future__ import annotations

from decimal import Decimal


def rebalance(
    holdings: list[dict],
    target_model: str = "equal_weight",
    custom_targets: dict[str, float] | None = None,
) -> dict:
    """T158: Compute allocation gaps and recommended rebalance actions."""
    total_value = sum(float(h.get("current_value", 0)) for h in holdings) or 1.0
    n = len(holdings)

    if target_model == "equal_weight":
        targets = {h.get("symbol", h.get("tradingsymbol", "")): 1.0 / n for h in holdings}
    else:
        targets = custom_targets or {}

    current: dict[str, float] = {}
    for h in holdings:
        sym = h.get("symbol", h.get("tradingsymbol", ""))
        current[sym] = float(h.get("current_value", 0)) / total_value

    actions: list[dict] = []
    for sym, target_w in targets.items():
        cur_w = current.get(sym, 0.0)
        diff = target_w - cur_w
        if abs(diff) > 0.005:
            actions.append({
                "symbol": sym,
                "current_weight": round(cur_w, 4),
                "target_weight": round(target_w, 4),
                "action": "buy" if diff > 0 else "sell",
                "adjustment_value": round(abs(diff) * total_value, 2),
            })

    return {
        "current_allocation": current,
        "target_allocation": targets,
        "recommended_actions": actions,
        "disclaimers": ["Rebalancing suggestions are heuristic screens, not financial advice."],
    }


def tax_loss_candidates(holdings: list[dict], threshold_pct: float = -5.0) -> list[dict]:
    """T159: Identify holdings with unrealized losses beyond threshold for tax-loss harvesting."""
    candidates: list[dict] = []
    for h in holdings:
        pnl_pct = float(h.get("pnl_percent", 0))
        if pnl_pct < threshold_pct:
            candidates.append({
                "symbol": h.get("symbol", h.get("tradingsymbol", "")),
                "pnl_percent": round(pnl_pct, 2),
                "unrealized_loss": round(float(h.get("pnl", 0)), 2),
                "current_value": round(float(h.get("current_value", 0)), 2),
            })
    return sorted(candidates, key=lambda c: c["pnl_percent"])
