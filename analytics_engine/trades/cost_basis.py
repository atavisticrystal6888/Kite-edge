"""
T139: FIFO cost-basis matching.
"""
from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field


@dataclass
class Lot:
    quantity: float
    price: float
    date: str


@dataclass
class MatchedTrade:
    symbol: str
    buy_price: float
    sell_price: float
    quantity: float
    buy_date: str
    sell_date: str
    pnl: float
    holding_period_days: int


def match_fifo(trades: list[dict]) -> list[MatchedTrade]:
    """Match buy and sell trades using FIFO order.

    Each trade dict: {symbol, side, quantity, price, date}.
    Returns list of matched trade results.
    """
    queues: dict[str, list[Lot]] = defaultdict(list)
    matched: list[MatchedTrade] = []

    sorted_trades = sorted(trades, key=lambda t: t["date"])

    for t in sorted_trades:
        symbol = t["symbol"]
        side = t["side"].upper()
        qty = float(t["quantity"])
        price = float(t["price"])
        date = t["date"]

        if side == "BUY":
            queues[symbol].append(Lot(quantity=qty, price=price, date=date))
        elif side == "SELL":
            remaining = qty
            while remaining > 0 and queues[symbol]:
                lot = queues[symbol][0]
                fill = min(remaining, lot.quantity)
                pnl = fill * (price - lot.price)
                days = _date_diff(lot.date, date)
                matched.append(MatchedTrade(
                    symbol=symbol,
                    buy_price=lot.price,
                    sell_price=price,
                    quantity=fill,
                    buy_date=lot.date,
                    sell_date=date,
                    pnl=round(pnl, 2),
                    holding_period_days=days,
                ))
                lot.quantity -= fill
                remaining -= fill
                if lot.quantity <= 0:
                    queues[symbol].pop(0)
    return matched


def _date_diff(d1: str, d2: str) -> int:
    from datetime import date as dt_date
    try:
        a = dt_date.fromisoformat(d1[:10])
        b = dt_date.fromisoformat(d2[:10])
        return (b - a).days
    except (ValueError, TypeError):
        return 0
