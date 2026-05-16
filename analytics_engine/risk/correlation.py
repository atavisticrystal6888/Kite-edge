"""
T098-T099: Correlation and covariance services.
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.covariance import LedoitWolf


def correlation_matrix(returns: pd.DataFrame, method: str = "pearson") -> dict:
    """T098: Compute correlation matrix."""
    if method == "spearman":
        corr = returns.corr(method="spearman")
    else:
        corr = returns.corr(method="pearson")
    return {
        "method": method,
        "symbols": list(corr.columns),
        "matrix": corr.values.tolist(),
    }


def covariance_matrix(returns: pd.DataFrame) -> dict:
    """T098: Compute sample covariance matrix."""
    cov = returns.cov()
    return {
        "symbols": list(cov.columns),
        "matrix": cov.values.tolist(),
    }


def ledoit_wolf_shrinkage(returns: pd.DataFrame) -> dict:
    """T099: Ledoit-Wolf shrinkage estimator."""
    lw = LedoitWolf().fit(returns.dropna())
    return {
        "symbols": list(returns.columns),
        "shrunk_covariance": lw.covariance_.tolist(),
        "shrinkage_coefficient": round(float(lw.shrinkage_), 6),
    }


def marginal_risk_contribution(returns: pd.DataFrame, weights: list[float] | None = None) -> dict:
    """T099: Marginal risk contribution per asset."""
    n = returns.shape[1]
    w = np.array(weights if weights else [1.0 / n] * n)
    cov = returns.cov().values
    port_vol = float(np.sqrt(w @ cov @ w))
    if port_vol == 0:
        mrc = [0.0] * n
    else:
        mrc = ((cov @ w) / port_vol).tolist()
    return {
        "symbols": list(returns.columns),
        "marginal_contributions": [round(float(m), 6) for m in mrc],
        "portfolio_volatility": round(port_vol, 6),
    }


def rolling_correlation(returns: pd.DataFrame, window: int = 60) -> dict:
    """T098: Rolling pairwise correlation for first two assets."""
    cols = list(returns.columns)
    if len(cols) < 2:
        return {"error": "Need at least 2 assets"}
    rolling = returns[cols[0]].rolling(window).corr(returns[cols[1]])
    return {
        "pair": [cols[0], cols[1]],
        "window": window,
        "values": rolling.dropna().round(4).tolist(),
    }
