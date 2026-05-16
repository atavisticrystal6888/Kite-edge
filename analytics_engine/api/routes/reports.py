"""
T179: Report-generation API routes.
"""
from __future__ import annotations

from fastapi import APIRouter
from pydantic import BaseModel

from analytics_engine.reports.disclaimers import REPORT_DISCLAIMER

router = APIRouter(prefix="/api/v1/reports", tags=["reports"])


class TearSheetRequest(BaseModel):
    period_start: str
    period_end: str
    benchmark: str = "NIFTY50"
    format: str = "html"


class ExportRequest(BaseModel):
    scope_type: str = "portfolio"
    scope_ref: str = ""
    format: str = "xlsx"


@router.post("/tearsheet")
async def tearsheet(req: TearSheetRequest):
    return {
        "report_id": "pending",
        "status": "queued",
        "download_uri": None,
        "disclaimers": [REPORT_DISCLAIMER],
    }


@router.post("/export")
async def export(req: ExportRequest):
    return {
        "export_job_id": "pending",
        "status": "queued",
        "download_uri": None,
    }
