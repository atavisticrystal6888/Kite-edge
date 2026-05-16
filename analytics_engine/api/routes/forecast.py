"""
T126: Forecast API routes.
"""
from __future__ import annotations

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1/analytics/forecast", tags=["forecast"])


class ForecastRequest(BaseModel):
    exchange: str = "NSE"
    horizons: list[int] = [5, 10, 30]
    models: list[str] = ["arima", "prophet", "ensemble"]
    confidence_levels: list[float] = [0.8, 0.95]


class PortfolioForecastRequest(BaseModel):
    horizons: list[int] = [5, 10, 30]
    confidence_levels: list[float] = [0.8, 0.95]
    seed: int | None = None


@router.post("/portfolio")
async def portfolio_forecast(req: PortfolioForecastRequest):
    return {
        "portfolio_forecasts": [],
        "distribution_summary": {},
        "disclaimers": [
            "Forecasts are statistical projections, not recommendations.",
            "Past performance does not predict future results.",
        ],
    }


@router.post("/{symbol}")
async def instrument_forecast(symbol: str, req: ForecastRequest):
    return {
        "instrument": {"symbol": symbol, "exchange": req.exchange},
        "forecasts": [],
        "accuracy_metrics": {},
        "signals": [],
        "disclaimers": [
            "Forecasts are statistical projections, not recommendations.",
            "Past performance does not predict future results.",
        ],
    }
