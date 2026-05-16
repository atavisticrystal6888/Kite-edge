"""XIRR implementation.

Canonical reference used by the Elixir gateway for FR-003 / FR-010
(per-holding and portfolio-wide time-weighted returns).

The implementation uses ``scipy.optimize.brentq`` on the net-present-value
function. Inputs are a list of ``(amount, date)`` tuples where outflows are
negative and inflows are positive.
"""

from __future__ import annotations

from datetime import date
from typing import Sequence

from scipy.optimize import brentq  # type: ignore[import-untyped]


def _xnpv(rate: float, cashflows: Sequence[tuple[float, date]]) -> float:
    t0 = cashflows[0][1]
    return sum(amount / (1.0 + rate) ** ((d - t0).days / 365.0) for amount, d in cashflows)


def xirr(cashflows: Sequence[tuple[float, date]], *, guess_low: float = -0.99, guess_high: float = 10.0) -> float:
    """Compute the internal rate of return for irregularly timed cashflows.

    Raises:
        ValueError: when the cashflows do not contain at least one sign change.
    """
    if len(cashflows) < 2:
        raise ValueError("at least two cashflows required")

    signs = {1 if amount > 0 else -1 for amount, _ in cashflows if amount != 0}
    if len(signs) < 2:
        raise ValueError("cashflows must contain at least one sign change")

    ordered = sorted(cashflows, key=lambda c: c[1])
    return brentq(lambda r: _xnpv(r, ordered), guess_low, guess_high, maxiter=256, xtol=1e-8)
