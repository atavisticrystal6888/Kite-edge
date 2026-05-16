"""
T121: Forecast accuracy tracking.
"""
from __future__ import annotations

import numpy as np
import pandas as pd


def evaluate(actual: pd.Series, predicted: pd.Series) -> dict:
    """Compute standard forecast error metrics."""
    aligned = pd.concat([actual, predicted], axis=1).dropna()
    if len(aligned) == 0:
        return {"mae": None, "rmse": None, "mape": None, "n": 0}
    a = aligned.iloc[:, 0].values
    p = aligned.iloc[:, 1].values
    errors = a - p
    mae = float(np.mean(np.abs(errors)))
    rmse = float(np.sqrt(np.mean(errors ** 2)))
    # MAPE: avoid division by zero
    nonzero = a != 0
    mape = float(np.mean(np.abs(errors[nonzero] / a[nonzero])) * 100) if np.any(nonzero) else None
    return {"mae": round(mae, 4), "rmse": round(rmse, 4), "mape": round(mape, 4) if mape is not None else None, "n": len(aligned)}


def directional_accuracy(actual: pd.Series, predicted: pd.Series) -> dict:
    """Percentage of times predicted direction matched actual."""
    a_diff = actual.diff().dropna()
    p_diff = predicted.diff().dropna()
    aligned = pd.concat([a_diff, p_diff], axis=1).dropna()
    if len(aligned) == 0:
        return {"accuracy": None, "n": 0}
    correct = (aligned.iloc[:, 0] * aligned.iloc[:, 1]) > 0
    return {"accuracy": round(float(correct.mean()) * 100, 2), "n": len(aligned)}
