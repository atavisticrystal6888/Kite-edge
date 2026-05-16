# Gateway API Contract

## Overview

- Style: REST over HTTPS
- Base path: `/api/v1`
- Audience: React dashboard and internal trusted clients
- Authentication: Local application session after successful Kite authorization
- Content type: `application/json`

## Common Response Metadata

Every response includes:

```json
{
  "data": {},
  "meta": {
    "generated_at": "2026-04-16T10:00:00Z",
    "source_mode": "live",
    "freshness_seconds": 1
  },
  "errors": []
}
```

`source_mode` values:
- `live`
- `cached`
- `offline`

## Endpoints

### `GET /api/v1/portfolio/holdings`

- Purpose: Return current holdings with live quote enrichment and current profit and loss.
- Query params:
  - `include_dividends` boolean optional
  - `sort_by` enum optional: `weight`, `pnl`, `symbol`
- Response `data` shape:

```json
{
  "holdings": [
    {
      "symbol": "RELIANCE",
      "exchange": "NSE",
      "quantity": 10,
      "average_price": 2500.0,
      "last_price": 2745.5,
      "current_value": 27455.0,
      "pnl_absolute": 2455.0,
      "pnl_percent": 9.82,
      "day_pnl_absolute": 120.0,
      "sector": "Energy",
      "market_cap_bucket": "Large",
      "holding_period_days": 420,
      "xirr": 14.12,
      "freshness_seconds": 1
    }
  ]
}
```

### `GET /api/v1/portfolio/positions`

- Purpose: Return active day and carry-forward positions.
- Query params:
  - `position_type` optional: `intraday`, `delivery`, `all`
- Response fields:
  - `positions[]` with `symbol`, `product_type`, `quantity`, `average_price`, `last_price`,
    `pnl_absolute`, `position_type`, `snapshot_at`

### `GET /api/v1/portfolio/summary`

- Purpose: Return aggregate portfolio metrics used by summary cards.
- Response fields:
  - `total_invested`
  - `current_value`
  - `pnl_absolute`
  - `pnl_percent`
  - `day_pnl_absolute`
  - `cagr`
  - `xirr`
  - `dividend_income_total`
  - `concentration_risk`
  - `top_holdings[]`

### `GET /api/v1/portfolio/history`

- Purpose: Return daily portfolio value series for charts and reporting.
- Query params:
  - `from` ISO date required
  - `to` ISO date required
  - `interval` optional: `day`, `week`, `month`
- Response fields:
  - `series[]` entries with `date`, `invested_value`, `market_value`, `benchmark_value`

### `GET /api/v1/instruments/{symbol}/ohlcv`

- Purpose: Return historical candles for charts and analytics previews.
- Path params:
  - `symbol` required
- Query params:
  - `exchange` optional default inferred
  - `timeframe` required
  - `from` ISO datetime required
  - `to` ISO datetime required
- Response fields:
  - `instrument`
  - `timeframe`
  - `candles[]` with `time`, `open`, `high`, `low`, `close`, `volume`

### `GET /api/v1/instruments/{symbol}/quote`

- Purpose: Return current quote and freshness metadata.
- Response fields:
  - `symbol`, `exchange`, `last_price`, `change_percent`, `volume`, `market_status`,
    `freshness_seconds`, `as_of`

### `GET /api/v1/instruments/search`

- Purpose: Search the instrument master for supported instruments.
- Query params:
  - `query` required
  - `exchange` optional
  - `limit` optional default 20 max 100
- Response fields:
  - `results[]` with `symbol`, `name`, `exchange`, `instrument_type`, `sector`,
    `market_cap_bucket`

### `GET /api/v1/trades`

- Purpose: Return trade history for journal and performance views.
- Query params:
  - `from` optional ISO date
  - `to` optional ISO date
  - `symbol` optional
  - `page` optional default 1
  - `page_size` optional default 50 max 500
- Response fields:
  - `trades[]` with `trade_id`, `symbol`, `side`, `quantity`, `price`, `executed_at`,
    `trade_value`, `fees_total`, `pnl_absolute`, `holding_period_days`
  - `pagination`

## Error Model

```json
{
  "data": null,
  "meta": {
    "generated_at": "2026-04-16T10:00:00Z",
    "source_mode": "offline"
  },
  "errors": [
    {
      "code": "KITE_SESSION_EXPIRED",
      "message": "Broker authorization expired. Re-authentication is required.",
      "retryable": false
    }
  ]
}
```

## OpenAPI Notes

- OpenAPI version target: 3.1.0
- Security schemes:
  - `appSessionCookie`
- Reusable schemas:
  - `Holding`
  - `Position`
  - `PortfolioSummary`
  - `PortfolioHistoryPoint`
  - `Quote`
  - `Trade`
  - `ApiError`