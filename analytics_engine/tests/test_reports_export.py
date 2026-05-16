"""T172: Export-format contract tests."""
import pytest
import tempfile
from analytics_engine.reports.csv_export import export_holdings_csv
from analytics_engine.reports.excel import export_holdings_xlsx


HOLDINGS = [
    {"symbol": "RELIANCE", "exchange": "NSE", "quantity": 10, "average_price": 2500, "last_price": 2600, "pnl": 1000, "sector": "Energy"},
]


def test_csv_export():
    path = export_holdings_csv(HOLDINGS)
    with open(path) as f:
        content = f.read()
    assert "RELIANCE" in content
    assert "Disclaimer" in content or "KiteEdge" in content


def test_xlsx_export():
    path = export_holdings_xlsx(HOLDINGS)
    assert path.endswith(".xlsx")
