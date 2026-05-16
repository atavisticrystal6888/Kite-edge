"""T039: XIRR and per-holding return regression tests."""

from __future__ import annotations

import math
from datetime import date

import pytest

from analytics_engine.portfolio.xirr import xirr


def test_xirr_matches_reference_flat_investment():
    # Reference: 100,000 invested 2025-01-01, worth 110,000 on 2026-01-01 -> ~10% XIRR.
    cashflows = [(-100_000.0, date(2025, 1, 1)), (110_000.0, date(2026, 1, 1))]
    assert math.isclose(xirr(cashflows), 0.10, rel_tol=0.0001)


def test_xirr_handles_multiple_cashflows():
    cashflows = [
        (-50_000.0, date(2024, 1, 1)),
        (-50_000.0, date(2024, 7, 1)),
        (120_000.0, date(2026, 1, 1)),
    ]
    rate = xirr(cashflows)
    assert 0.05 < rate < 0.25


def test_xirr_requires_sign_change():
    with pytest.raises(ValueError):
        xirr([(100.0, date(2025, 1, 1)), (200.0, date(2026, 1, 1))])
