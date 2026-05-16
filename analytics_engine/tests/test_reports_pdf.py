"""T172a: PDF export generation contract tests."""
import pytest
from analytics_engine.reports.pdf_export import export_holdings_pdf


HOLDINGS = [
    {"symbol": "RELIANCE", "exchange": "NSE", "quantity": 10, "average_price": 2500, "last_price": 2600, "pnl": 1000, "sector": "Energy"},
]


def test_pdf_export():
    path = export_holdings_pdf(HOLDINGS)
    assert path.endswith(".pdf")
    # File should exist and be non-empty
    with open(path, "rb") as f:
        content = f.read()
    assert len(content) > 0
    assert content[:4] == b"%PDF"
