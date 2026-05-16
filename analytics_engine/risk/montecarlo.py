"""
T102: Forward portfolio simulation (Monte Carlo).
"""
from __future__ import annotations

import numpy as np


def simulate(
    current_value: float,
    mu: float,
    sigma: float,
    horizon: int = 252,
    simulations: int = 10_000,
    seed: int | None = 42,
    percentiles: list[int] | None = None,
) -> dict:
    """Generate forward Monte Carlo paths for the portfolio.

    Returns summary statistics, terminal distribution, and target-probability
    metrics.
    """
    percentiles = percentiles or [5, 25, 50, 75, 95]
    if horizon < 1:
        raise ValueError("horizon must be >= 1")
    rng = np.random.default_rng(seed)

    daily_returns = rng.normal(mu, sigma, (simulations, horizon))
    paths = current_value * np.cumprod(1 + daily_returns, axis=1)
    terminal = paths[:, -1]

    pcts = {str(p): round(float(np.percentile(terminal, p)), 2) for p in percentiles}

    return {
        "paths_summary": {
            "simulations": simulations,
            "horizon_days": horizon,
            "start_value": current_value,
            "percentiles": pcts,
        },
        "terminal_distribution": {
            "mean": round(float(terminal.mean()), 2),
            "std": round(float(terminal.std()), 2),
            "min": round(float(terminal.min()), 2),
            "max": round(float(terminal.max()), 2),
        },
        "target_probability": {
            "above_start": round(float(np.mean(terminal > current_value)), 4),
            "above_10pct": round(float(np.mean(terminal > current_value * 1.10)), 4),
        },
        "drawdown_breach_probability": {
            "10pct_drawdown": round(float(np.mean(np.min(paths, axis=1) < current_value * 0.9)), 4),
            "20pct_drawdown": round(float(np.mean(np.min(paths, axis=1) < current_value * 0.8)), 4),
        },
    }
