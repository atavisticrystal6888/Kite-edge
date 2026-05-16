"""
T176: CSV exports.
"""
from __future__ import annotations

import csv
import tempfile
from pathlib import Path

from analytics_engine.reports.disclaimers import REPORT_DISCLAIMER


def export_holdings_csv(holdings: list[dict], filename: str | None = None) -> str:
    """Export holdings to CSV. Returns path."""
    if not filename:
        tmpdir = tempfile.mkdtemp()
        filename = str(Path(tmpdir) / "holdings_export.csv")

    fields = ["symbol", "exchange", "quantity", "average_price", "last_price", "pnl", "sector"]

    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        for h in holdings:
            row = {
                "symbol": h.get("symbol", h.get("tradingsymbol", "")),
                "exchange": h.get("exchange", ""),
                "quantity": h.get("quantity", 0),
                "average_price": h.get("average_price", 0),
                "last_price": h.get("last_price", 0),
                "pnl": h.get("pnl", 0),
                "sector": h.get("sector", ""),
            }
            writer.writerow(row)
        # Write disclaimer as comment row
        f.write(f"\n# {REPORT_DISCLAIMER}\n")

    return filename
