"""T063: API contract tests for technical analysis responses."""
import pytest
from httpx import AsyncClient, ASGITransport
from analytics_engine.api.main import app


@pytest.fixture
def client():
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")


@pytest.mark.asyncio
async def test_technical_endpoint(client):
    resp = await client.post("/api/v1/analytics/technical/RELIANCE", json={"exchange": "NSE"})
    assert resp.status_code == 200
    data = resp.json()
    assert "indicator_groups" in data
    assert "summary_score" in data


@pytest.mark.asyncio
async def test_technical_summary_endpoint(client):
    resp = await client.get("/api/v1/analytics/technical/RELIANCE/summary?timeframe=1d")
    assert resp.status_code == 200
    data = resp.json()
    assert "score" in data
