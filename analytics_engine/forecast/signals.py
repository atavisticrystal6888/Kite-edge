"""
T122-T124: Predictive signal generation.

- Moving-average crossover (T122)
- Divergence detection (T123)
- Bollinger squeeze and volume-price divergence (T124)
"""
from __future__ import annotations

import pandas as pd
import ta


def ma_crossover(df: pd.DataFrame, fast: int = 12, slow: int = 26) -> list[dict]:
    """T122: Moving-average crossover signals."""
    close = df["close"]
    fast_ma = close.ewm(span=fast).mean()
    slow_ma = close.ewm(span=slow).mean()
    signals: list[dict] = []

    for i in range(1, len(df)):
        if fast_ma.iloc[i] > slow_ma.iloc[i] and fast_ma.iloc[i - 1] <= slow_ma.iloc[i - 1]:
            signals.append(_sig("MA Crossover", "bullish", i, df, f"EMA({fast}) crossed above EMA({slow})"))
        elif fast_ma.iloc[i] < slow_ma.iloc[i] and fast_ma.iloc[i - 1] >= slow_ma.iloc[i - 1]:
            signals.append(_sig("MA Crossover", "bearish", i, df, f"EMA({fast}) crossed below EMA({slow})"))
    return signals


def rsi_divergence(df: pd.DataFrame, window: int = 14, lookback: int = 30) -> list[dict]:
    """T123: RSI divergence detection."""
    close = df["close"]
    rsi = ta.momentum.RSIIndicator(close, window=window).rsi()
    signals: list[dict] = []

    if len(df) < lookback:
        return signals

    recent = slice(-lookback, None)
    price_low = close.iloc[recent].min()
    rsi_low = rsi.iloc[recent].min()
    price_high = close.iloc[recent].max()
    rsi_high = rsi.iloc[recent].max()

    # Bullish divergence: lower price low but higher RSI low
    last = len(df) - 1
    if close.iloc[last] <= price_low * 1.02 and rsi.iloc[last] > rsi_low:
        signals.append(_sig("RSI Divergence", "bullish", last, df, "Price near lows but RSI rising"))
    # Bearish divergence
    if close.iloc[last] >= price_high * 0.98 and rsi.iloc[last] < rsi_high:
        signals.append(_sig("RSI Divergence", "bearish", last, df, "Price near highs but RSI falling"))

    return signals


def bollinger_squeeze(df: pd.DataFrame, bb_window: int = 20, kc_window: int = 20) -> list[dict]:
    """T124: Bollinger squeeze detection."""
    close = df["close"]
    high = df["high"]
    low = df["low"]

    bb = ta.volatility.BollingerBands(close, window=bb_window)
    kc = ta.volatility.KeltnerChannel(high, low, close, window=kc_window)

    signals: list[dict] = []
    last = len(df) - 1
    bb_upper = bb.bollinger_hband().iloc[last]
    bb_lower = bb.bollinger_lband().iloc[last]
    kc_upper = kc.keltner_channel_hband().iloc[last]
    kc_lower = kc.keltner_channel_lband().iloc[last]

    if bb_lower > kc_lower and bb_upper < kc_upper:
        signals.append(_sig("Bollinger Squeeze", "neutral", last, df, "BB inside KC — volatility compression"))
    return signals


def volume_price_divergence(df: pd.DataFrame, lookback: int = 10) -> list[dict]:
    """T124: Volume-price divergence."""
    signals: list[dict] = []
    if len(df) < lookback:
        return signals

    close = df["close"]
    volume = df["volume"]
    recent = slice(-lookback, None)

    price_trend = close.iloc[-1] - close.iloc[-lookback]
    vol_trend = volume.iloc[recent].mean() - volume.iloc[-lookback * 2 : -lookback].mean() if len(df) >= lookback * 2 else 0

    if price_trend > 0 and vol_trend < 0:
        signals.append(_sig("Volume Divergence", "bearish", len(df) - 1, df, "Price rising on declining volume"))
    elif price_trend < 0 and vol_trend > 0:
        signals.append(_sig("Volume Divergence", "bullish", len(df) - 1, df, "Price falling on rising volume"))

    return signals


def detect_all(df: pd.DataFrame) -> list[dict]:
    """Run all signal detectors."""
    return ma_crossover(df) + rsi_divergence(df) + bollinger_squeeze(df) + volume_price_divergence(df)


def _sig(name: str, direction: str, idx: int, df: pd.DataFrame, rationale: str) -> dict:
    date = str(df.index[idx]) if hasattr(df.index, "__getitem__") else str(idx)
    return {
        "name": name,
        "direction": direction,
        "confidence_score": 0.6,
        "date": date,
        "close": round(float(df["close"].iloc[idx]), 2),
        "rationale": rationale,
    }
