"""
T065-T068: Technical indicator wrappers.

Provides trend, momentum, volatility, volume, and return indicator
computations using the `ta` library. Each function takes a pandas DataFrame
with at least ``close``, ``high``, ``low``, ``volume`` columns and returns
a dict of indicator name → value/signal pairs.
"""
from __future__ import annotations

import pandas as pd
import ta


# ---------------------------------------------------------------------------
# Trend indicators (T065)
# ---------------------------------------------------------------------------

def compute_trend(df: pd.DataFrame, params: dict | None = None) -> list[dict]:
    """SMA, EMA, MACD, ADX, Ichimoku, Parabolic SAR."""
    params = params or {}
    close = df["close"]
    high = df["high"]
    low = df["low"]

    sma_20 = ta.trend.SMAIndicator(close, window=params.get("sma_window", 20)).sma_indicator()
    ema_12 = ta.trend.EMAIndicator(close, window=params.get("ema_window", 12)).ema_indicator()
    macd = ta.trend.MACD(close)
    adx = ta.trend.ADXIndicator(high, low, close, window=params.get("adx_window", 14))
    psar = ta.trend.PSARIndicator(high, low, close)

    last = len(df) - 1
    macd_line = macd.macd().iloc[last]
    macd_signal = macd.macd_signal().iloc[last]

    return [
        _ind("SMA_20", sma_20.iloc[last], "buy" if close.iloc[last] > sma_20.iloc[last] else "sell"),
        _ind("EMA_12", ema_12.iloc[last], "buy" if close.iloc[last] > ema_12.iloc[last] else "sell"),
        _ind("MACD", macd_line, "buy" if macd_line > macd_signal else "sell"),
        _ind("ADX", adx.adx().iloc[last], "strong" if adx.adx().iloc[last] > 25 else "weak"),
        _ind("PSAR", psar.psar().iloc[last], "buy" if close.iloc[last] > psar.psar().iloc[last] else "sell"),
    ]


# ---------------------------------------------------------------------------
# Momentum indicators (T066)
# ---------------------------------------------------------------------------

def compute_momentum(df: pd.DataFrame, params: dict | None = None) -> list[dict]:
    """RSI, Stochastic, Williams %R, CCI, ROC."""
    params = params or {}
    close = df["close"]
    high = df["high"]
    low = df["low"]
    last = len(df) - 1

    rsi = ta.momentum.RSIIndicator(close, window=params.get("rsi_window", 14)).rsi()
    stoch = ta.momentum.StochasticOscillator(high, low, close)
    wr = ta.momentum.WilliamsRIndicator(high, low, close)
    cci = ta.trend.CCIIndicator(high, low, close)
    roc = ta.momentum.ROCIndicator(close, window=params.get("roc_window", 12)).roc()

    rsi_val = rsi.iloc[last]

    return [
        _ind("RSI", rsi_val, "overbought" if rsi_val > 70 else ("oversold" if rsi_val < 30 else "neutral")),
        _ind("Stochastic_K", stoch.stoch().iloc[last], "buy" if stoch.stoch().iloc[last] < 20 else ("sell" if stoch.stoch().iloc[last] > 80 else "neutral")),
        _ind("Williams_%R", wr.williams_r().iloc[last], "oversold" if wr.williams_r().iloc[last] < -80 else ("overbought" if wr.williams_r().iloc[last] > -20 else "neutral")),
        _ind("CCI", cci.cci().iloc[last], "buy" if cci.cci().iloc[last] < -100 else ("sell" if cci.cci().iloc[last] > 100 else "neutral")),
        _ind("ROC", roc.iloc[last], "buy" if roc.iloc[last] > 0 else "sell"),
    ]


# ---------------------------------------------------------------------------
# Volatility indicators (T067)
# ---------------------------------------------------------------------------

def compute_volatility(df: pd.DataFrame, params: dict | None = None) -> list[dict]:
    """Bollinger Bands, ATR, Keltner Channel."""
    params = params or {}
    close = df["close"]
    high = df["high"]
    low = df["low"]
    last = len(df) - 1

    bb = ta.volatility.BollingerBands(close, window=params.get("bb_window", 20))
    atr = ta.volatility.AverageTrueRange(high, low, close, window=params.get("atr_window", 14))
    kc = ta.volatility.KeltnerChannel(high, low, close)

    return [
        _ind("BB_Upper", bb.bollinger_hband().iloc[last], None),
        _ind("BB_Lower", bb.bollinger_lband().iloc[last], None),
        _ind("BB_Width", bb.bollinger_wband().iloc[last], "squeeze" if bb.bollinger_wband().iloc[last] < 0.1 else "normal"),
        _ind("ATR", atr.average_true_range().iloc[last], None),
        _ind("KC_Upper", kc.keltner_channel_hband().iloc[last], None),
        _ind("KC_Lower", kc.keltner_channel_lband().iloc[last], None),
    ]


# ---------------------------------------------------------------------------
# Volume & Return indicators (T068)
# ---------------------------------------------------------------------------

def compute_volume(df: pd.DataFrame, params: dict | None = None) -> list[dict]:
    """OBV, VWAP, MFI, A/D."""
    params = params or {}
    close = df["close"]
    high = df["high"]
    low = df["low"]
    volume = df["volume"]
    last = len(df) - 1

    obv = ta.volume.OnBalanceVolumeIndicator(close, volume).on_balance_volume()
    mfi = ta.volume.MFIIndicator(high, low, close, volume, window=params.get("mfi_window", 14)).money_flow_index()
    ad = ta.volume.AccDistIndexIndicator(high, low, close, volume).acc_dist_index()

    mfi_val = mfi.iloc[last]

    return [
        _ind("OBV", obv.iloc[last], None),
        _ind("MFI", mfi_val, "overbought" if mfi_val > 80 else ("oversold" if mfi_val < 20 else "neutral")),
        _ind("A/D", ad.iloc[last], None),
    ]


def compute_returns(df: pd.DataFrame, _params: dict | None = None) -> list[dict]:
    """Daily, weekly, monthly returns."""
    close = df["close"]
    daily = close.pct_change().iloc[-1] * 100 if len(close) > 1 else 0.0
    weekly = ((close.iloc[-1] / close.iloc[-5]) - 1) * 100 if len(close) >= 5 else 0.0
    monthly = ((close.iloc[-1] / close.iloc[-21]) - 1) * 100 if len(close) >= 21 else 0.0
    return [
        _ind("Daily_Return", daily, None),
        _ind("Weekly_Return", weekly, None),
        _ind("Monthly_Return", monthly, None),
    ]


# ---------------------------------------------------------------------------
# Full computation
# ---------------------------------------------------------------------------

def compute_all(df: pd.DataFrame, params: dict | None = None) -> dict:
    """Return grouped indicator results."""
    return {
        "trend": compute_trend(df, params),
        "momentum": compute_momentum(df, params),
        "volatility": compute_volatility(df, params),
        "volume": compute_volume(df, params),
        "returns": compute_returns(df, params),
    }


def _ind(name: str, value, signal) -> dict:
    v = None if value is None or (isinstance(value, float) and pd.isna(value)) else round(float(value), 4)
    return {"name": name, "value": v, "signal": signal}
