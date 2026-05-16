"""
T119: Prophet forecasts with trading-calendar seasonality support.
"""
from __future__ import annotations

import pandas as pd


def forecast(
    df: pd.DataFrame,
    horizon: int = 30,
    confidence: float = 0.95,
    weekly_seasonality: bool = True,
    yearly_seasonality: bool = True,
) -> dict:
    """Fit Prophet and produce forecasts.

    ``df`` must have columns ``ds`` (datetime) and ``y`` (close price).
    """
    from prophet import Prophet  # heavy import, deferred

    m = Prophet(
        interval_width=confidence,
        weekly_seasonality=weekly_seasonality,
        yearly_seasonality=yearly_seasonality,
        daily_seasonality=False,
    )
    m.fit(df[["ds", "y"]])
    future = m.make_future_dataframe(periods=horizon)
    pred = m.predict(future)
    forecast_rows = pred.tail(horizon)

    points: list[dict] = []
    for _, row in forecast_rows.iterrows():
        points.append({
            "date": str(row["ds"].date()),
            "predicted": round(float(row["yhat"]), 2),
            "lower": round(float(row["yhat_lower"]), 2),
            "upper": round(float(row["yhat_upper"]), 2),
        })

    return {
        "model": "prophet",
        "horizon": horizon,
        "confidence": confidence,
        "forecasts": points,
    }
