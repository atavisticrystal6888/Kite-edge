"""
T120: Ensemble combiner and weight adjustment logic.
"""
from __future__ import annotations

import numpy as np


def combine(
    forecasts: list[dict],
    weights: list[float] | None = None,
) -> dict:
    """Combine multiple model forecast outputs into an ensemble result.

    Each forecast dict must have ``forecasts: [{date, predicted, lower, upper}]``.
    """
    if not forecasts:
        return {"model": "ensemble", "forecasts": [], "weights": []}

    n_models = len(forecasts)
    w = np.array(weights or [1.0 / n_models] * n_models)
    w = w / w.sum()

    horizon = len(forecasts[0]["forecasts"])
    combined: list[dict] = []
    for i in range(horizon):
        vals = [f["forecasts"][i] for f in forecasts if i < len(f["forecasts"])]
        pred = sum(w[j] * vals[j]["predicted"] for j in range(len(vals)))
        lo = sum(w[j] * vals[j]["lower"] for j in range(len(vals)))
        hi = sum(w[j] * vals[j]["upper"] for j in range(len(vals)))
        combined.append({
            "date": vals[0]["date"],
            "predicted": round(float(pred), 2),
            "lower": round(float(lo), 2),
            "upper": round(float(hi), 2),
        })

    return {
        "model": "ensemble",
        "weights": w.tolist(),
        "horizon": horizon,
        "forecasts": combined,
    }
