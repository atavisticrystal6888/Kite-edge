# KiteEdge Data Model

## Modeling Principles

- PostgreSQL stores historical data, synchronized portfolio records, analytical snapshots,
  alert configuration, and generated report metadata.
- Redis stores ephemeral session data, hot market caches, rate-limit counters, and freshness
  state.
- Kafka carries real-time event streams and recomputation triggers.
- `KiteToken` is an application entity but intentionally has no PostgreSQL table because the
  constitution forbids token persistence.

## PostgreSQL Tables

### `instrument_masters`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | Internal surrogate key |
| `instrument_token` | `bigint` | Unique, not null | Broker instrument identifier |
| `exchange` | `varchar(16)` | Not null | NSE, BSE, NFO, etc. |
| `tradingsymbol` | `varchar(64)` | Not null | Exchange symbol |
| `name` | `varchar(255)` | Not null | Display name |
| `instrument_type` | `varchar(32)` | Not null | EQ, MF, ETF, etc. |
| `segment` | `varchar(32)` | Not null | Cash or other segment |
| `tick_size` | `numeric(16,8)` | Not null | Price increment |
| `lot_size` | `integer` | Not null default 1 | Trading lot |
| `expiry_date` | `date` | Null | Only for derivative-capable instruments |
| `strike_price` | `numeric(18,4)` | Null | Reserved for future scope filtering |
| `isin` | `varchar(32)` | Null | Used for cross-source reconciliation |
| `sector_name` | `varchar(128)` | Null | Enrichment field |
| `market_cap_bucket` | `varchar(32)` | Null | Large, Mid, Small |
| `is_active` | `boolean` | Not null default true | De-listed or suspended handling |
| `last_synced_at` | `timestamptz` | Not null | Instrument master refresh timestamp |

Indexes:
- Unique index on `instrument_token`
- Composite index on `(exchange, tradingsymbol)`
- Partial index on `(is_active)` where `is_active = true`

### `trading_calendars`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `exchange` | `varchar(16)` | Not null | |
| `calendar_date` | `date` | Not null | |
| `session_type` | `varchar(32)` | Not null | Regular, Holiday, Muhurat, Special |
| `opens_at` | `time` | Null | |
| `closes_at` | `time` | Null | |
| `notes` | `text` | Null | Human-readable context |
| `source_ref` | `varchar(255)` | Null | Upstream calendar source |

Indexes:
- Unique index on `(exchange, calendar_date)`

### `holdings_current`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `quantity` | `numeric(20,8)` | Not null | Supports fractional MF units if needed |
| `average_price` | `numeric(18,4)` | Not null | Average acquisition price |
| `last_price` | `numeric(18,4)` | Null | Last known market price |
| `previous_close` | `numeric(18,4)` | Null | Used for day P&L |
| `current_value` | `numeric(20,4)` | Null | Derived snapshot field |
| `pnl_absolute` | `numeric(20,4)` | Null | Derived snapshot field |
| `pnl_percent` | `numeric(12,6)` | Null | Derived snapshot field |
| `holding_started_on` | `date` | Null | First acquisition date |
| `snapshot_at` | `timestamptz` | Not null | Last refresh time |

Indexes:
- Unique index on `instrument_id`
- Index on `snapshot_at desc`

### `positions_current`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `product_type` | `varchar(32)` | Not null | CNC, MIS, NRML, etc. |
| `position_type` | `varchar(32)` | Not null | Intraday, Delivery, CarryForward |
| `quantity` | `numeric(20,8)` | Not null | Signed quantity |
| `buy_quantity` | `numeric(20,8)` | Not null default 0 | |
| `sell_quantity` | `numeric(20,8)` | Not null default 0 | |
| `average_price` | `numeric(18,4)` | Null | |
| `last_price` | `numeric(18,4)` | Null | |
| `pnl_absolute` | `numeric(20,4)` | Null | |
| `snapshot_at` | `timestamptz` | Not null | |

Indexes:
- Unique index on `(instrument_id, product_type, position_type)`

### `orders`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `broker_order_id` | `varchar(64)` | Unique, not null | Broker order identifier |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `order_side` | `varchar(8)` | Not null | Buy or Sell |
| `order_type` | `varchar(16)` | Not null | Market, Limit, SL, etc. |
| `product_type` | `varchar(32)` | Not null | |
| `quantity` | `numeric(20,8)` | Not null | |
| `price` | `numeric(18,4)` | Null | Requested price |
| `status` | `varchar(32)` | Not null | Complete, Cancelled, Rejected, etc. |
| `placed_at` | `timestamptz` | Not null | |
| `updated_at` | `timestamptz` | Not null | |
| `raw_payload` | `jsonb` | Not null | Redacted source payload |

Indexes:
- Index on `(instrument_id, placed_at desc)`
- Index on `(status, updated_at desc)`

### `trades`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `broker_trade_id` | `varchar(64)` | Unique, not null | |
| `broker_order_id` | `varchar(64)` | Not null | Links back to order |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `trade_side` | `varchar(8)` | Not null | |
| `quantity` | `numeric(20,8)` | Not null | |
| `price` | `numeric(18,4)` | Not null | Execution price |
| `trade_value` | `numeric(20,4)` | Not null | |
| `fees_total` | `numeric(20,4)` | Null | Charges, taxes, broker fees |
| `executed_at` | `timestamptz` | Not null | |
| `trade_day` | `date` | Generated | Date bucket for analytics |

Indexes:
- Index on `(instrument_id, executed_at desc)`
- Index on `(trade_day)`

### `trade_fills`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `trade_id` | `bigint` | Not null, FK -> `trades.id` | |
| `fill_sequence` | `integer` | Not null | Fill order |
| `quantity` | `numeric(20,8)` | Not null | |
| `price` | `numeric(18,4)` | Not null | |
| `filled_at` | `timestamptz` | Not null | |
| `venue` | `varchar(32)` | Null | Exchange/venue detail |

Indexes:
- Unique index on `(trade_id, fill_sequence)`

### `dividends`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `record_date` | `date` | Null | |
| `payment_date` | `date` | Null | |
| `amount_per_unit` | `numeric(18,4)` | Not null | |
| `quantity_eligible` | `numeric(20,8)` | Not null | |
| `gross_amount` | `numeric(20,4)` | Not null | |
| `currency_code` | `char(3)` | Not null default 'INR' | |
| `source_type` | `varchar(32)` | Not null | CorporateAction or BrokerStatement |

Indexes:
- Index on `(instrument_id, payment_date desc)`

### `corporate_actions`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `action_type` | `varchar(32)` | Not null | Split, Bonus, Rights, Merger, Rename |
| `effective_date` | `date` | Not null | |
| `ratio_numerator` | `integer` | Null | |
| `ratio_denominator` | `integer` | Null | |
| `notes` | `text` | Null | |
| `source_ref` | `varchar(255)` | Null | |

Indexes:
- Index on `(instrument_id, effective_date desc)`

### `ohlcv_candles`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | Partition key component |
| `timeframe` | `varchar(16)` | Not null | 1m, 5m, 15m, 1h, 1d, 1w, 1mo |
| `candle_time` | `timestamptz` | Not null | Partition key component |
| `open_price` | `numeric(18,4)` | Not null | |
| `high_price` | `numeric(18,4)` | Not null | |
| `low_price` | `numeric(18,4)` | Not null | |
| `close_price` | `numeric(18,4)` | Not null | |
| `volume` | `numeric(24,8)` | Not null default 0 | |
| `oi` | `numeric(24,8)` | Null | Reserved for future excluded derivatives |
| `source_type` | `varchar(16)` | Not null | Historical or RealtimeAggregate |
| `adjustment_state` | `varchar(32)` | Not null | Raw, SplitAdjusted, CorporateActionAdjusted |

Primary key:
- `(instrument_id, timeframe, candle_time)`

Partitioning strategy:
- Parent table partitioned by RANGE on `candle_time` with monthly partitions.
- Each monthly partition subpartitioned by HASH on `instrument_id` into 16 partitions to keep
  write concurrency and query pruning balanced.

Indexes:
- Local index on `(instrument_id, timeframe, candle_time desc)`
- Local index on `(timeframe, candle_time desc)`

### `portfolio_snapshots`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `snapshot_at` | `timestamptz` | Not null | |
| `total_invested` | `numeric(20,4)` | Not null | |
| `current_value` | `numeric(20,4)` | Not null | |
| `pnl_absolute` | `numeric(20,4)` | Not null | |
| `pnl_percent` | `numeric(12,6)` | Not null | |
| `day_pnl_absolute` | `numeric(20,4)` | Null | |
| `cagr` | `numeric(12,6)` | Null | |
| `xirr` | `numeric(12,6)` | Null | |
| `dividend_income_total` | `numeric(20,4)` | Null | |
| `herfindahl_index` | `numeric(12,6)` | Null | |

Indexes:
- Unique index on `snapshot_at`

### `technical_indicator_snapshots`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `timeframe` | `varchar(16)` | Not null | |
| `calculated_at` | `timestamptz` | Not null | |
| `parameter_profile` | `varchar(64)` | Not null | Default or user-defined profile |
| `indicator_payload` | `jsonb` | Not null | All computed indicator values |
| `summary_score` | `numeric(10,4)` | Null | |
| `summary_band` | `varchar(16)` | Null | StrongBuy, Buy, Neutral, Sell, StrongSell |
| `pattern_payload` | `jsonb` | Null | Detected candlestick patterns |
| `support_resistance_payload` | `jsonb` | Null | Pivot/Fibonacci output |

Indexes:
- Unique index on `(instrument_id, timeframe, parameter_profile, calculated_at)`
- GIN index on `indicator_payload`

### `risk_metric_snapshots`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `snapshot_at` | `timestamptz` | Not null | |
| `benchmark_code` | `varchar(32)` | Not null | NIFTY50 by default |
| `metrics_payload` | `jsonb` | Not null | Ratios, volatility, drawdown, beta/alpha |
| `var_payload` | `jsonb` | Not null | Historical, Parametric, Monte Carlo |
| `correlation_payload` | `jsonb` | Not null | Correlation/covariance summary |
| `simulation_payload` | `jsonb` | Null | Forward simulation percentiles |

Indexes:
- Unique index on `(snapshot_at, benchmark_code)`

### `forecast_runs`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `scope_type` | `varchar(16)` | Not null | Instrument or Portfolio |
| `instrument_id` | `bigint` | Null, FK -> `instrument_masters.id` | Null for portfolio forecasts |
| `model_family` | `varchar(32)` | Not null | ARIMA, Prophet, Ensemble |
| `forecast_horizon` | `varchar(16)` | Not null | 5d, 10d, 30d, 3m, etc. |
| `generated_at` | `timestamptz` | Not null | |
| `forecast_payload` | `jsonb` | Not null | Forecast points and intervals |
| `accuracy_payload` | `jsonb` | Null | MAPE, RMSE, MAE |
| `seed_value` | `integer` | Null | Reproducibility metadata |

Indexes:
- Index on `(scope_type, instrument_id, generated_at desc)`

### `signals_current`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `signal_type` | `varchar(32)` | Not null | Technical, Forecast, Risk, Portfolio |
| `instrument_id` | `bigint` | Null, FK -> `instrument_masters.id` | Portfolio-level signals may be null |
| `severity` | `varchar(16)` | Not null | Info, Watch, Bullish, Bearish, Critical |
| `direction` | `varchar(16)` | Not null | Buy, Sell, Hold, Hedge, Alert |
| `confidence_score` | `numeric(10,4)` | Null | |
| `headline` | `varchar(255)` | Not null | |
| `rationale` | `text` | Not null | |
| `triggered_at` | `timestamptz` | Not null | |
| `expires_at` | `timestamptz` | Null | |
| `is_active` | `boolean` | Not null default true | |

Indexes:
- Index on `(is_active, triggered_at desc)`
- Index on `(instrument_id, is_active)`

### `indicator_profiles` (Phase 4 Remediation, FR-023)

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `profile_key` | `varchar(64)` | Not null, unique | Logical key, e.g. `default`, `swing`, `longterm` |
| `parameters` | `jsonb` | Not null | Per-indicator parameter map (periods, thresholds, overlays) |
| `is_default` | `boolean` | Not null default false | Exactly one row may be default |
| `created_at` | `timestamptz` | Not null | |
| `updated_at` | `timestamptz` | Not null | |

Indexes:
- Unique index on `(profile_key)`.
- Partial unique index on `(is_default)` where `is_default = true`.

### `notification_preferences` (Phase 4 Remediation, FR-071)

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `channel` | `varchar(16)` | Not null | `in_app`, `email` |
| `enabled` | `boolean` | Not null default true | |
| `email_address` | `varchar(255)` | Null | Required when `channel = 'email'` and `enabled = true` |
| `severity_floor` | `varchar(16)` | Not null | Minimum alert severity that triggers delivery |
| `quiet_hours` | `jsonb` | Null | Optional local-time suppression window |
| `created_at` | `timestamptz` | Not null | |
| `updated_at` | `timestamptz` | Not null | |

Indexes:
- Unique index on `(channel)`.

### `watchlists` and `watchlist_items`

`watchlists`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `name` | `varchar(128)` | Not null | |
| `description` | `text` | Null | |
| `display_order` | `integer` | Not null default 0 | Supports user ordering (FR-070) |
| `created_at` | `timestamptz` | Not null | |
| `updated_at` | `timestamptz` | Not null | |

`watchlist_items`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `watchlist_id` | `bigint` | Not null, FK -> `watchlists.id` | |
| `instrument_id` | `bigint` | Not null, FK -> `instrument_masters.id` | |
| `added_at` | `timestamptz` | Not null | |
| `sort_order` | `integer` | Not null default 0 | |

Indexes:
- Unique index on `(watchlist_id, instrument_id)`

### `alert_rules` and `alert_events`

`alert_rules`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `rule_type` | `varchar(32)` | Not null | Price, Technical, Risk, Portfolio |
| `scope_type` | `varchar(16)` | Not null | Instrument or Portfolio |
| `instrument_id` | `bigint` | Null, FK -> `instrument_masters.id` | |
| `condition_payload` | `jsonb` | Not null | Thresholds or signal parameters |
| `delivery_channels` | `jsonb` | Not null | InApp, Email |
| `is_enabled` | `boolean` | Not null default true | |
| `created_at` | `timestamptz` | Not null | |
| `updated_at` | `timestamptz` | Not null | |

`alert_events`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `alert_rule_id` | `bigint` | Null, FK -> `alert_rules.id` | System-generated alerts may be null |
| `signal_id` | `bigint` | Null, FK -> `signals_current.id` | |
| `instrument_id` | `bigint` | Null, FK -> `instrument_masters.id` | |
| `headline` | `varchar(255)` | Not null | |
| `message_body` | `text` | Not null | |
| `severity` | `varchar(16)` | Not null | |
| `delivered_channels` | `jsonb` | Not null | |
| `fired_at` | `timestamptz` | Not null | |
| `read_at` | `timestamptz` | Null | |

Indexes:
- Index on `(fired_at desc)`
- Index on `(read_at)`

### `rebalance_recommendations`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `generated_at` | `timestamptz` | Not null | |
| `target_model` | `varchar(32)` | Not null | EqualWeight, MarketCap, MinVariance, Custom |
| `input_payload` | `jsonb` | Not null | Current vs target allocations |
| `recommendation_payload` | `jsonb` | Not null | Suggested trades and rationale |
| `tax_loss_payload` | `jsonb` | Null | Harvest candidates |

Indexes:
- Index on `(generated_at desc)`

### `reports` and `export_jobs`

`reports`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `report_type` | `varchar(32)` | Not null | TearSheet, Monthly, Quarterly |
| `period_start` | `date` | Null | |
| `period_end` | `date` | Null | |
| `generated_at` | `timestamptz` | Not null | |
| `storage_uri` | `text` | Not null | Local file or object path |
| `metadata_payload` | `jsonb` | Not null | Includes disclaimers shown |

`export_jobs`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `bigserial` | Primary key | |
| `export_type` | `varchar(16)` | Not null | XLSX, CSV, PDF, OData |
| `scope_ref` | `varchar(128)` | Not null | Requested view or report scope |
| `status` | `varchar(16)` | Not null | Pending, Running, Complete, Failed |
| `requested_at` | `timestamptz` | Not null | |
| `completed_at` | `timestamptz` | Null | |
| `output_uri` | `text` | Null | |
| `error_message` | `text` | Null | |

Indexes:
- Index on `(status, requested_at desc)`

## Redis Key Patterns

| Key Pattern | TTL | Value | Purpose |
|-------------|-----|-------|---------|
| `session:{user_id}` | 1 day | Encrypted broker session metadata without persistent storage | Ephemeral Kite session |
| `ltp:{instrument_token}` | 2 seconds | Last traded price plus timestamp | Live quote cache |
| `freshness:{instrument_token}` | 2 seconds | Last tick timestamp and source status | Dashboard freshness indicators |
| `cache:indicators:{instrument_token}:{timeframe}:{profile}` | 5 minutes | Latest indicator snapshot | Hot technical reads |
| `cache:risk:portfolio:{benchmark}` | 15 minutes | Latest risk snapshot | Dashboard acceleration |
| `ratelimit:kite:{endpoint}` | Sliding window | Token-bucket counters | Brokerage rate limiting |
| `ws:subscriptions:{channel}` | Session scoped | Active subscribers | Channel fan-out accounting |

## Kafka Topic Schemas

### `market.ticks`

- Key: `instrument_token`
- Retention: 24 hours
- Payload:
  - `instrument_token` bigint
  - `exchange` string
  - `trading_symbol` string
  - `last_price` decimal
  - `last_quantity` decimal
  - `volume` decimal
  - `timestamp` timestamptz
  - `source_mode` string (`ltp`, `quote`, `full`)
  - `market_status` string

### `candles.{timeframe}`

- Key: `{instrument_token}:{timeframe}`
- Retention: 7 days
- Payload:
  - `instrument_token` bigint
  - `timeframe` string
  - `candle_time` timestamptz
  - `open`, `high`, `low`, `close` decimal
  - `volume` decimal
  - `source_type` string

### `analytics.triggers`

- Key: `scope_ref`
- Retention: 3 days
- Payload:
  - `trigger_type` string (`indicator_close`, `portfolio_change`, `nightly_forecast`, `manual_recompute`)
  - `scope_type` string (`instrument`, `portfolio`, `watchlist`)
  - `scope_ref` string
  - `requested_at` timestamptz
  - `priority` string

### `alerts.fired`

- Key: `alert_scope`
- Retention: 14 days
- Payload:
  - `alert_id` uuid
  - `rule_type` string
  - `severity` string
  - `headline` string
  - `message_body` string
  - `instrument_token` bigint nullable
  - `fired_at` timestamptz
  - `delivery_channels` array of string

## Index Strategy

- Time-series reads rely on `(instrument_id, timeframe, candle_time desc)` for candles.
- Holdings, positions, and portfolio snapshots favor descending snapshot time indexes for the
  dashboard's default current-state access pattern.
- Orders and trades use `(instrument_id, executed_at desc)` or `(status, updated_at desc)` to
  support journal filters and incremental sync.
- JSON payload tables that support ad-hoc filtering, such as indicator and risk snapshots, use
  GIN indexes only where query filters justify them.

## Materialized Views

### `mv_portfolio_daily_values`

- Grain: One row per trading day
- Purpose: Daily current value, invested value, total return, drawdown basis
- Refresh: Nightly and on end-of-day sync

### `mv_holdings_allocations_current`

- Grain: One row per holding in latest snapshot
- Purpose: Sector, market-cap, weight, and concentration dashboard cards
- Refresh: After each holdings sync

### `mv_trade_performance_daily`

- Grain: One row per trading day
- Purpose: Daily trade P&L, streak calculations, calendar heatmap source
- Refresh: After trade sync and nightly recomputation

### `mv_risk_inputs_returns`

- Grain: One row per instrument per trading day
- Purpose: Stable input set for risk and correlation calculations
- Refresh: After new daily candle availability

## Non-Persisted Entities

- `KiteToken`: Redis-only, encrypted, daily TTL, no database row.
- `UserSession`: Redis or Phoenix session boundary; database persistence is not required for
  v1.