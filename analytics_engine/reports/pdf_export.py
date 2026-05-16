"""
T176a: PDF tear-sheet export with embedded disclaimer footer.
"""
from __future__ import annotations

import tempfile
from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors

from analytics_engine.reports.disclaimers import REPORT_DISCLAIMER


def export_holdings_pdf(holdings: list[dict], filename: str | None = None) -> str:
    """Export holdings data to a PDF. Returns path."""
    if not filename:
        tmpdir = tempfile.mkdtemp()
        filename = str(Path(tmpdir) / "holdings_export.pdf")

    doc = SimpleDocTemplate(filename, pagesize=A4)
    styles = getSampleStyleSheet()
    elements = []

    elements.append(Paragraph("KiteEdge Holdings Report", styles["Title"]))
    elements.append(Spacer(1, 10 * mm))

    headers = ["Symbol", "Exchange", "Qty", "Avg Price", "LTP", "P&L", "Sector"]
    data = [headers]
    for h in holdings:
        data.append([
            h.get("symbol", h.get("tradingsymbol", "")),
            h.get("exchange", ""),
            str(h.get("quantity", 0)),
            str(round(float(h.get("average_price", 0)), 2)),
            str(round(float(h.get("last_price", 0)), 2)),
            str(round(float(h.get("pnl", 0)), 2)),
            h.get("sector", ""),
        ])

    table = Table(data)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.grey),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.whitesmoke),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.black),
    ]))
    elements.append(table)
    elements.append(Spacer(1, 15 * mm))

    # Disclaimer footer
    disclaimer_style = styles["Normal"].clone("disclaimer")
    disclaimer_style.fontSize = 7
    disclaimer_style.textColor = colors.grey
    elements.append(Paragraph(f"<i>{REPORT_DISCLAIMER}</i>", disclaimer_style))

    doc.build(elements)
    return filename
