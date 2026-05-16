"""
Analytics Engine — FastAPI application entry point.
"""
from __future__ import annotations

from fastapi import FastAPI

from analytics_engine.api.routes.technical import router as technical_router
from analytics_engine.api.routes.risk import router as risk_router
from analytics_engine.api.routes.forecast import router as forecast_router
from analytics_engine.api.routes.trades import router as trades_router
from analytics_engine.api.routes.signals import router as signals_router
from analytics_engine.api.routes.reports import router as reports_router

app = FastAPI(title="KiteEdge Analytics Engine", version="0.1.0")

app.include_router(technical_router)
app.include_router(risk_router)
app.include_router(forecast_router)
app.include_router(trades_router)
app.include_router(signals_router)
app.include_router(reports_router)


# ---- Portfolio XIRR endpoint (consumed by Elixir T050) ----

from pydantic import BaseModel
from analytics_engine.portfolio.xirr import xirr


class CashflowItem(BaseModel):
    amount: float
    date: str


class XIRRRequest(BaseModel):
    cashflows: list[CashflowItem]


@app.post("/portfolio/xirr")
async def portfolio_xirr(req: XIRRRequest):
    from datetime import date as _date
    from fastapi.responses import JSONResponse
    try:
        entries = [(c.amount, _date.fromisoformat(c.date)) for c in req.cashflows]
    except ValueError as e:
        return JSONResponse(status_code=422, content={"error": f"Invalid date format: {e}", "xirr": None})
    try:
        result = xirr(entries)
        return {"xirr": result}
    except (ValueError, TypeError) as e:
        return JSONResponse(status_code=422, content={"error": str(e), "xirr": None})


@app.get("/health")
async def health():
    return {"status": "ok"}
