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

    horizon = max(len(f["forecasts"]) for f in forecasts)
    combined: list[dict] = []
    for i in range(horizon):
        available = [(j, f["forecasts"][i]) for j, f in enumerate(forecasts) if i < len(f["forecasts"])]
        if not available:
            continue
        w_sub = np.array([w[j] for j, _ in available])
        w_sub = w_sub / w_sub.sum()  # re-normalize weights for available models
        vals = [v for _, v in available]
        pred = sum(w_sub[k] * vals[k]["predicted"] for k in range(len(vals)))
        lo = sum(w_sub[k] * vals[k]["lower"] for k in range(len(vals)))
        hi = sum(w_sub[k] * vals[k]["upper"] for k in range(len(vals)))
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
