"""
T095-T097: Value at Risk — historical, parametric, Monte Carlo.
"""
from __future__ import annotations

import numpy as np
import pandas as pd


def historical_var(returns: pd.Series, confidence: float = 0.95) -> dict:
    """T095: Historical VaR and Expected Shortfall (CVaR)."""
    sorted_r = returns.dropna().sort_values()
    idx = int((1 - confidence) * len(sorted_r))
    var_val = float(sorted_r.iloc[max(idx, 0)])
    es = float(sorted_r.iloc[: max(idx, 1)].mean())
    return {"var": round(var_val, 6), "expected_shortfall": round(es, 6), "method": "historical"}


def parametric_var(returns: pd.Series, confidence: float = 0.95) -> dict:
    """T096: Parametric (Gaussian) VaR."""
    from scipy import stats  # noqa: delayed import

    mu = float(returns.mean())
    sigma = float(returns.std())
    z = stats.norm.ppf(1 - confidence)
    var_val = mu + z * sigma
    return {"var": round(var_val, 6), "mu": round(mu, 6), "sigma": round(sigma, 6), "method": "parametric"}


def monte_carlo_var(
    returns: pd.Series,
    confidence: float = 0.95,
    simulations: int = 10_000,
    horizon: int = 1,
    seed: int | None = 42,
) -> dict:
    """T097: Monte Carlo VaR."""
    rng = np.random.default_rng(seed)
    mu = float(returns.mean())
    sigma = float(returns.std())
    sim_returns = rng.normal(mu, sigma, (simulations, horizon))
    terminal = np.prod(1 + sim_returns, axis=1) - 1
    var_val = float(np.percentile(terminal, (1 - confidence) * 100))
    es = float(terminal[terminal <= var_val].mean()) if np.any(terminal <= var_val) else var_val
    return {
        "var": round(var_val, 6),
        "expected_shortfall": round(es, 6),
        "simulations": simulations,
        "horizon": horizon,
        "method": "monte_carlo",
    }


def compute_var(returns: pd.Series, confidence_levels: list[float] | None = None,
                methods: list[str] | None = None, simulations: int = 10_000,
                seed: int | None = 42) -> dict:
    """Convenience: compute VaR for all requested methods and confidence levels."""
    confidence_levels = confidence_levels or [0.95, 0.99]
    methods = methods or ["historical", "parametric", "monte_carlo"]

    result: dict = {}
    dispatch = {
        "historical": lambda c: historical_var(returns, c),
        "parametric": lambda c: parametric_var(returns, c),
        "monte_carlo": lambda c: monte_carlo_var(returns, c, simulations=simulations, seed=seed),
    }
    for m in methods:
        if m in dispatch:
            result[m] = {str(c): dispatch[m](c) for c in confidence_levels}
    return result
