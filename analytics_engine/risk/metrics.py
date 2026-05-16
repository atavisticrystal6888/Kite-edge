"""
T091-T094: Portfolio risk metrics — ratios, benchmark-relative stats,
rolling windows, and drawdown analysis.
"""
from __future__ import annotations

import numpy as np
import pandas as pd


# ---- T091: Sharpe, Sortino, Calmar, Information, Treynor ----

def sharpe_ratio(returns: pd.Series, rf: float = 0.0, periods: int = 252) -> float:
    excess = returns - rf / periods
    if excess.std() == 0:
        return 0.0
    return float(np.sqrt(periods) * excess.mean() / excess.std())


def sortino_ratio(returns: pd.Series, rf: float = 0.0, periods: int = 252) -> float:
    excess = returns - rf / periods
    downside = excess[excess < 0]
    if len(downside) == 0 or downside.std() == 0:
        return 0.0
    return float(np.sqrt(periods) * excess.mean() / downside.std())


def calmar_ratio(returns: pd.Series, periods: int = 252) -> float:
    ann_return = returns.mean() * periods
    dd = max_drawdown(returns)
    if dd == 0:
        return 0.0
    return float(ann_return / abs(dd))


def information_ratio(returns: pd.Series, benchmark: pd.Series, periods: int = 252) -> float:
    diff = returns - benchmark
    if diff.std() == 0:
        return 0.0
    return float(np.sqrt(periods) * diff.mean() / diff.std())


def treynor_ratio(returns: pd.Series, benchmark: pd.Series, rf: float = 0.0, periods: int = 252) -> float:
    b = beta(returns, benchmark)
    if b == 0:
        return 0.0
    ann_excess = (returns.mean() - rf / periods) * periods
    return float(ann_excess / b)


# ---- T092: Beta and Alpha ----

def beta(returns: pd.Series, benchmark: pd.Series) -> float:
    aligned = pd.concat([returns, benchmark], axis=1).dropna()
    if len(aligned) < 2 or aligned.iloc[:, 1].var() == 0:
        return 0.0
    return float(aligned.iloc[:, 0].cov(aligned.iloc[:, 1]) / aligned.iloc[:, 1].var())


def alpha(returns: pd.Series, benchmark: pd.Series, rf: float = 0.0, periods: int = 252) -> float:
    b = beta(returns, benchmark)
    ann_r = returns.mean() * periods
    ann_b = benchmark.mean() * periods
    return float(ann_r - rf - b * (ann_b - rf))


# ---- T093: Rolling volatility and rolling ratios ----

def rolling_volatility(returns: pd.Series, window: int = 30, periods: int = 252) -> pd.Series:
    return returns.rolling(window).std() * np.sqrt(periods)


def rolling_sharpe(returns: pd.Series, window: int = 60, rf: float = 0.0, periods: int = 252) -> pd.Series:
    excess = returns - rf / periods
    mean = excess.rolling(window).mean()
    std = excess.rolling(window).std()
    return (mean / std.replace(0, np.nan)) * np.sqrt(periods)


# ---- T094: Drawdown depth, duration, recovery ----

def max_drawdown(returns: pd.Series) -> float:
    cum = (1 + returns).cumprod()
    peak = cum.cummax()
    dd = (cum - peak) / peak
    return float(dd.min())


def drawdown_series(returns: pd.Series) -> pd.Series:
    cum = (1 + returns).cumprod()
    peak = cum.cummax()
    return (cum - peak) / peak


def drawdown_details(returns: pd.Series) -> list[dict]:
    dd = drawdown_series(returns)
    details: list[dict] = []
    in_dd = False
    start = None
    for i, val in enumerate(dd):
        if val < 0 and not in_dd:
            in_dd = True
            start = i
        elif val >= 0 and in_dd:
            in_dd = False
            trough_idx = dd.iloc[start:i].idxmin()
            details.append({
                "start": str(dd.index[start]),
                "trough": str(trough_idx),
                "recovery": str(dd.index[i]),
                "depth": round(float(dd.iloc[start:i].min()), 6),
                "duration_days": i - start,
            })
    if in_dd and start is not None:
        trough_idx = dd.iloc[start:].idxmin()
        details.append({
            "start": str(dd.index[start]),
            "trough": str(trough_idx),
            "recovery": None,
            "depth": round(float(dd.iloc[start:].min()), 6),
            "duration_days": len(dd) - start,
        })
    return details


def compute_all(returns: pd.Series, benchmark: pd.Series, rf: float = 0.0) -> dict:
    return {
        "ratios": {
            "sharpe": sharpe_ratio(returns, rf),
            "sortino": sortino_ratio(returns, rf),
            "calmar": calmar_ratio(returns),
            "information": information_ratio(returns, benchmark),
            "treynor": treynor_ratio(returns, benchmark, rf),
        },
        "volatility": {
            "annualized": round(float(returns.std() * np.sqrt(252)), 6),
        },
        "beta_alpha": {
            "beta": beta(returns, benchmark),
            "alpha": alpha(returns, benchmark, rf),
        },
        "drawdown": {
            "max_drawdown": max_drawdown(returns),
            "details": drawdown_details(returns),
        },
    }
