"""
T174: QuantStats tear-sheet generation.
"""
from __future__ import annotations

import io
import tempfile
from pathlib import Path

import pandas as pd
from analytics_engine.reports.disclaimers import REPORT_DISCLAIMER


def generate_tearsheet(
    returns: pd.Series,
    benchmark: pd.Series | None = None,
    period_start: str | None = None,
    period_end: str | None = None,
    output_format: str = "html",
) -> dict:
    """Generate a QuantStats tear sheet."""
    import quantstats as qs

    if period_start:
        returns = returns[returns.index >= period_start]
    if period_end:
        returns = returns[returns.index <= period_end]

    with tempfile.TemporaryDirectory() as tmpdir:
        filename = f"tearsheet.{output_format}"
        filepath = Path(tmpdir) / filename

        qs.reports.html(returns, benchmark=benchmark, output=str(filepath), title="KiteEdge Tear Sheet")
        content = filepath.read_text(encoding="utf-8")
        # Inject disclaimer
        content = content.replace("</body>", f'<footer style="padding:20px;font-size:11px;color:#666;">{REPORT_DISCLAIMER}</footer></body>')

    return {
        "report_id": "tearsheet",
        "status": "completed",
        "content": content,
        "disclaimers": [REPORT_DISCLAIMER],
    }
