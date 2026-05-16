# Analytics API Contract

## Overview

- Style: REST over HTTPS
- Base path: `/api/v1`
- Audience: Gateway API and trusted internal consumers
- Authentication: Internal trusted service boundary plus application session propagation
- Content type: `application/json`

## Shared Response Conventions

- Long-running or recomputed endpoints may return `request_id` and `progress_channel` metadata.
- Forecast, signal, suggestion, and report-generation responses include `disclaimers[]`.
- All computation responses include `generated_at`, `source_window`, and `tolerance_profile`
  metadata where relevant.

## Endpoints

### `POST /api/v1/analytics/technical/{symbol}`

- Purpose: Return complete technical analysis for one instrument.
- Request body:

```json
{
  "exchange": "NSE",
  "timeframes": ["1d", "1w", "1mo"],
  "parameter_profile": "default",
  "include_patterns": true,
  "include_support_resistance": true
}
```

- Response fields:
  - `instrument`
  - `timeframes[]`
  - `indicator_groups` with `trend`, `momentum`, `volatility`, `volume`, `returns`
  - `patterns[]`
  - `support_resistance`
  - `summary_score`

### `GET /api/v1/analytics/technical/{symbol}/summary`

- Purpose: Return the current technical summary score for a single timeframe.
- Query params:
  - `exchange` optional
  - `timeframe` required
  - `parameter_profile` optional
- Response fields:
  - `score`
  - `band`
  - `contributors[]`

### `POST /api/v1/analytics/risk/portfolio`

- Purpose: Return portfolio risk ratios and drawdown metrics.
- Request body:

```json
{
  "benchmark": "NIFTY50",
  "lookbacks": [30, 60, 90, 180, 365],
  "risk_free_rate_source": "RBI_REPO"
}
```

- Response fields:
  - `ratios`
  - `volatility`
  - `drawdown`
  - `beta_alpha`
  - `benchmark`

### `POST /api/v1/analytics/risk/var`

- Purpose: Return value-at-risk outputs across supported methods.
- Request body:

```json
{
  "confidence_levels": [0.95, 0.99],
  "include_methods": ["historical", "parametric", "monte_carlo"],
  "simulation_count": 10000,
  "seed": 42
}
```

- Response fields:
  - `historical`
  - `parametric`
  - `monte_carlo`
  - `plain_language_summary`

### `POST /api/v1/analytics/risk/montecarlo`

- Purpose: Return forward path simulations for the portfolio.
- Request body:
  - `horizon`
  - `simulation_count`
  - `seed`
  - `percentiles`
- Response fields:
  - `paths_summary`
  - `terminal_distribution`
  - `target_probability`
  - `drawdown_breach_probability`

### `POST /api/v1/analytics/risk/stress-test`

- Purpose: Evaluate portfolio impact under historical or custom scenarios.
- Request body:

```json
{
  "scenario_type": "historical",
  "scenario_code": "CRASH_2020_03",
  "custom_shocks": []
}
```

- Response fields:
  - `scenario`
  - `portfolio_impact`
  - `holding_impacts[]`

### `POST /api/v1/analytics/risk/correlation`

- Purpose: Return correlation and covariance outputs for current holdings.
- Request body:
  - `method` enum: `pearson`, `spearman`, `rolling`
  - `window_days` optional
- Response fields:
  - `correlation_matrix`
  - `covariance_matrix`
  - `marginal_risk_contribution`

### `POST /api/v1/analytics/forecast/{symbol}`

- Purpose: Return instrument forecast outputs.
- Request body:

```json
{
  "exchange": "NSE",
  "horizons": [5, 10, 30],
  "models": ["arima", "prophet", "ensemble"],
  "confidence_levels": [0.8, 0.95]
}
```

- Response fields:
  - `forecasts[]`
  - `accuracy_metrics`
  - `signals[]`
  - `disclaimers[]`

### `POST /api/v1/analytics/forecast/portfolio`

- Purpose: Return portfolio-level forward return forecast outputs.
- Request body:
  - `horizons`
  - `confidence_levels`
  - `seed` optional
- Response fields:
  - `portfolio_forecasts[]`
  - `distribution_summary`
  - `disclaimers[]`

### `GET /api/v1/analytics/trades/performance`

- Purpose: Return aggregate trade performance and rolling views.
- Query params:
  - `from`
  - `to`
  - `group_by` optional: `day`, `week`, `month`
- Response fields:
  - `summary_metrics`
  - `streaks`
  - `time_patterns`
  - `equity_curve`
  - `drawdown_curve`

### `GET /api/v1/analytics/signals`

- Purpose: Return active signals across holdings and watchlists.
- Query params:
  - `scope` optional: `holdings`, `watchlist`, `all`
  - `limit` optional
- Response fields:
  - `signals[]`
  - `generated_at`
  - `disclaimers[]`

### `POST /api/v1/analytics/rebalance`

- Purpose: Return allocation-gap analysis and rebalance actions.
- Request body:

```json
{
  "target_model": "equal_weight",
  "custom_targets": [],
  "include_tax_loss_candidates": true
}
```

- Response fields:
  - `current_allocation`
  - `target_allocation`
  - `recommended_actions[]`
  - `tax_loss_candidates[]`
  - `disclaimers[]`

### `POST /api/v1/reports/tearsheet`

- Purpose: Generate a portfolio tear sheet.
- Request body:
  - `period_start`
  - `period_end`
  - `benchmark`
  - `format` enum: `html`, `pdf`
- Response fields:
  - `report_id`
  - `status`
  - `download_uri`
  - `disclaimers[]`

### `POST /api/v1/reports/export`

- Purpose: Generate an export job for spreadsheet, flat-file, or report output.
- Request body:
  - `scope_type`
  - `scope_ref`
  - `format` enum: `xlsx`, `csv`, `pdf`
- Response fields:
  - `export_job_id`
  - `status`
  - `download_uri`

## Core Schema Notes

- `TechnicalIndicatorGroup` contains a list of indicator objects with `name`, `value`,
  `signal`, `explanation`, and `parameter_profile`.
- `RiskMetricsPayload` contains ratio, volatility, drawdown, benchmark, and variance
  decomposition sections.
- `ForecastPayload` contains forecast points, interval bounds, model metadata, and error
  metrics.
- `SignalPayload` contains `direction`, `confidence_score`, `headline`, `rationale`, and
  `expires_at`.
- `DisclaimerPayload` is an array of required legal strings rendered on downstream surfaces.

## Error Model

- `INSUFFICIENT_HISTORY` for unsupported lookback windows.
- `UNSUPPORTED_TIMEFRAME` for invalid timeframe requests.
- `COMPUTATION_TIMEOUT` when request scope exceeds current processing budget.
- `UPSTREAM_STALE_DATA` when analytics fall back to cached data outside freshness tolerance.