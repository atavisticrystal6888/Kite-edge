"""
T184c: Disclaimer text module for generated exports.

Embeds the canonical disclaimer text into tear sheets, Excel, CSV, and PDF
exports per Constitution Principle 8.
"""
from __future__ import annotations

DISCLAIMER_TEXT = (
    "KiteEdge is a personal research tool. It does not provide investment advice, "
    "does not execute trades, and does not guarantee outcomes. Markets involve risk, "
    "including loss of capital. Verify all figures independently before making any decision."
)

REPORT_DISCLAIMER = (
    f"{DISCLAIMER_TEXT} Report figures are derived from your own Kite history and "
    "may include rounding or reconciliation differences."
)


def get_disclaimer(variant: str = "report") -> str:
    variants = {
        "report": REPORT_DISCLAIMER,
        "prediction": f"{DISCLAIMER_TEXT} Forecasts are statistical projections, not recommendations.",
        "suggestion": f"{DISCLAIMER_TEXT} Suggested actions are heuristic screens, not financial advice.",
        "base": DISCLAIMER_TEXT,
    }
    return variants.get(variant, DISCLAIMER_TEXT)


def disclaimer_lines() -> list[str]:
    return [REPORT_DISCLAIMER]
