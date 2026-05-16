"""
T164: Suggestion and rebalance API routes.
"""
from __future__ import annotations

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1/analytics", tags=["signals"])


class RebalanceRequest(BaseModel):
    target_model: str = "equal_weight"
    custom_targets: dict[str, float] = {}
    include_tax_loss_candidates: bool = True


@router.get("/signals")
async def signals(scope: str = "all", limit: int = 20):
    return {
        "signals": [],
        "generated_at": None,
        "disclaimers": [
            "Signals are heuristic screens, not financial advice.",
            "Past performance does not predict future results.",
        ],
    }


@router.post("/rebalance")
async def rebalance(req: RebalanceRequest):
    return {
        "current_allocation": {},
        "target_allocation": {},
        "recommended_actions": [],
        "tax_loss_candidates": [],
        "disclaimers": ["Rebalancing suggestions are heuristic screens, not financial advice."],
    }
