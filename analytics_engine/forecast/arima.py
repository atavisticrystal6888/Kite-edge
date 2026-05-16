"""
T118: ARIMA fitting and forecast generation.
"""
from __future__ import annotations

import pandas as pd
import numpy as np
from statsmodels.tsa.arima.model import ARIMA as _ARIMA


def forecast(
    series: pd.Series,
    horizon: int = 10,
    order: tuple[int, int, int] = (2, 1, 2),
    confidence: float = 0.95,
) -> dict:
    """Fit an ARIMA model and produce forecasts with confidence intervals."""
    model = _ARIMA(series.dropna(), order=order)
    fitted = model.fit()

    pred = fitted.get_forecast(steps=horizon)
    mean = pred.predicted_mean
    ci = pred.conf_int(alpha=1 - confidence)

    points: list[dict] = []
    last_date = series.index[-1] if hasattr(series.index, "__getitem__") else pd.Timestamp.now()
    for i in range(horizon):
        d = last_date + pd.Timedelta(days=i + 1)
        points.append({
            "date": str(d.date()) if hasattr(d, "date") else str(d),
            "predicted": round(float(mean.iloc[i]), 2),
            "lower": round(float(ci.iloc[i, 0]), 2),
            "upper": round(float(ci.iloc[i, 1]), 2),
        })

    return {
        "model": "arima",
        "order": list(order),
        "aic": round(float(fitted.aic), 2),
        "bic": round(float(fitted.bic), 2),
        "horizon": horizon,
        "confidence": confidence,
        "forecasts": points,
    }
