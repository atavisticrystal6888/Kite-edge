# WebSocket API Contract

## Overview

- Transport: Phoenix Channels over WebSocket
- Authentication: Established application session
- Serialization: JSON payloads
- Purpose: Push live quote, profit and loss, alert, and long-running analytics progress events

## Channels

### `portfolio:live`

- Purpose: Push current holding and portfolio summary updates.
- Join payload:

```json
{
  "view": "overview"
}
```

- Server events:
  - `portfolio_snapshot`
  - `holding_update`
  - `freshness_state`

- `holding_update` payload:

```json
{
  "symbol": "RELIANCE",
  "last_price": 2745.5,
  "pnl_absolute": 2455.0,
  "day_pnl_absolute": 120.0,
  "freshness_seconds": 1,
  "as_of": "2026-04-16T10:00:00Z"
}
```

### `ticks:{instrument_token}`

- Purpose: Push live quote and chart update events for a specific instrument.
- Join payload:

```json
{
  "instrument_token": 738561,
  "timeframe": "1m"
}
```

- Server events:
  - `tick`
  - `quote`
  - `candle_closed`
  - `market_status`

- `tick` payload fields:
  - `instrument_token`
  - `last_price`
  - `last_quantity`
  - `volume`
  - `timestamp`

### `alerts:user`

- Purpose: Push real-time alerts and notification state changes.
- Join payload:

```json
{
  "include_read": false
}
```

- Server events:
  - `alert_fired`
  - `alert_read`
  - `alert_count`

- `alert_fired` payload:

```json
{
  "alert_id": "5e6f3c1e-7c5e-4d6d-90aa-0f6ef1d3f31c",
  "severity": "bearish",
  "headline": "RELIANCE dropped 5% intraday",
  "message_body": "Abnormal move detected against configured alert thresholds.",
  "instrument_token": 738561,
  "fired_at": "2026-04-16T10:00:00Z"
}
```

### `analytics:progress`

- Purpose: Push progress for long-running computations such as large simulations, tear-sheet
  generation, or export jobs.
- Join payload:

```json
{
  "request_id": "risk-run-20260416-001"
}
```

- Server events:
  - `started`
  - `progress`
  - `completed`
  - `failed`

- `progress` payload fields:
  - `request_id`
  - `stage`
  - `percent_complete`
  - `message`
  - `eta_seconds` nullable

## Delivery Semantics

- Channels favor latest-state delivery for portfolio and quote updates.
- Alerts and progress events are append-oriented and should not be silently dropped if the
  client is connected.
- Every payload carrying market or analytical data includes either `as_of` or
  `freshness_seconds` so the dashboard can surface staleness clearly.

## Error Events

- `join_denied`: emitted when the session is invalid or expired.
- `stale_data`: emitted when the underlying source falls back to cached data outside normal
  freshness thresholds.
- `computation_failed`: emitted when a long-running analytical request ends unsuccessfully.