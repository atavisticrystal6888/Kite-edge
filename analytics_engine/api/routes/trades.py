"""
T145: Trade analytics API routes.
"""
from __future__ import annotations

from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/analytics/trades", tags=["trades"])


@router.get("/performance")
async def trade_performance(from_date: str | None = None, to_date: str | None = None, group_by: str = "day"):
    return {
        "summary_metrics": {},
        "streaks": {},
        "time_patterns": {},
        "equity_curve": [],
        "drawdown_curve": [],
    }
