# Implementation Plan: KiteEdge Portfolio Intelligence Platform

**Branch**: `kiteedge` | **Date**: 2026-04-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/kiteedge/spec.md`

## Summary

Build KiteEdge as a self-hosted, single-user portfolio intelligence monorepo with six runtime
services: a Phoenix gateway for OAuth, APIs, and channels; an Elixir market-data service for
KiteTicker ingestion; a Python analytics engine for technical, risk, forecast, trade, and
reporting computations; Python Kafka consumers for aggregation and scheduled recomputation; a
React dashboard; and an Elixir notification service. The architecture isolates live Kite
session ownership to the Elixir boundary, keeps analytics reproducible and testable, and uses
PostgreSQL, Kafka, and Redis to support both historical and real-time workflows.

## Technical Context

**Language/Version**: Elixir 1.16+ with OTP 26+, Python 3.12+, React 18+ with TypeScript 5.3+  
**Primary Dependencies**: Phoenix 1.7+, Phoenix Channels, Ecto, Oban, Broadway, Tesla, Jason, Cachex, FastAPI, kiteconnect v5.1.0, ta v0.11.0, quantstats v0.0.81, scipy, numpy, pandas, statsmodels, prophet, scikit-learn, openpyxl, matplotlib, plotly, kafka-python, lightweight-charts, Recharts, TanStack Query, shadcn/ui, React Router, zustand  
**Storage**: PostgreSQL 16+ for historical and analytical data, Kafka 3.7+ for event streams, Redis 7+ for session/cache/rate-limiter state  
**Testing**: ExUnit, pytest, property-based financial tests, contract tests, Docker-backed integration tests, frontend component and end-to-end tests, k6 performance verification  
**Target Platform**: Self-hosted Linux containers for local development and production-like deployment  
**Project Type**: Polyglot web platform with real-time services, analytics APIs, and a browser dashboard  
**Performance Goals**: Technical analysis < 500 ms per instrument, portfolio risk analysis < 10 s, 10K Monte Carlo simulations for 50 assets < 30 s, dashboard load < 2 s, live quote freshness < 2 s  
**Constraints**: No automated trading, no persisted Kite secrets or tokens, offline-capable with staleness indicators, prediction/suggestion/report disclaimers required, reference-validation against ta/QuantStats/scipy, six-service cap for v1  
**Scale/Scope**: Single user, up to 100 actively tracked instruments, 5 years of daily history cached, real-time monitoring for holdings plus watchlist

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Gate 1 - Kite boundary ownership: PASS. Gateway API and Market Data service own live Kite
  authentication and streaming. Analytics Engine and Data Pipeline consume normalized data via
  PostgreSQL, Kafka, Redis, or internal APIs and do not persist Kite tokens.
- Gate 2 - Mathematical rigor: PASS. All financial outputs are mapped to reference-validation
  requirements in [research.md](./research.md) and represented as explicit service modules and
  stored analytical snapshots in [data-model.md](./data-model.md).
- Gate 3 - Test-first delivery: PASS. The plan assumes failing tests before implementation,
  Docker-backed integration tests for persistence flows, and property-based testing for
  indicators, risk, and forecasting outputs.
- Gate 4 - Real-time and historical duality: PASS. Kafka, Redis, PostgreSQL, and Phoenix
  Channels are used to keep the real-time and historical paths aligned around the same
  canonical candle and portfolio data.
- Gate 5 - Security and compliance: PASS. No plan component places trades, stores Kite
  tokens in the database, or transmits portfolio data to third-party analytics services.
- Gate 6 - Observability and freshness: PASS. Health endpoints, structured JSON logs, metrics,
  and freshness indicators are required for every runtime surface.
- Gate 7 - Legal disclaimer propagation: PASS. Prediction, suggestion, report, and login
  surfaces are represented in dashboard contracts and quickstart validation.

Post-design re-check: PASS. The supporting documents below preserve the same constitutional
constraints and do not introduce any justified violations.

## Research Summary

- Kite live token handling remains in Elixir-owned runtime boundaries to minimize secret
  propagation while keeping the approved SDK set available for controlled integration helpers.
- Historical data backfill should prioritize daily data windows and treat minute-level backfill
  as explicitly bounded because of Kite historical API interval limits.
- Technical summary scoring should use weighted consensus with transparent factor breakdowns.
- Historical VaR, parametric VaR, and Monte Carlo should all be exposed because they answer
  different user questions and provide accuracy-versus-speed tradeoffs.
- Lightweight Charts is the preferred candlestick surface because it supports overlays and
  interaction without the licensing and bundle overhead of heavier alternatives.

See [research.md](./research.md) for the complete decision log.

## Project Structure

### Documentation (this feature)

```text
specs/kiteedge/
|-- constitution.md
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   |-- gateway-api.md
|   |-- analytics-api.md
|   `-- websocket-api.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md
```

### Source Code (repository root)

```text
apps/
|-- kite_edge/
|-- kite_edge_web/
|-- market_data/
`-- notification/

analytics_engine/
|-- api/
|-- technical/
|-- risk/
|-- forecast/
|-- trades/
|-- reports/
`-- tests/

data_pipeline/
`-- consumers/

dashboard/
|-- src/
|   |-- components/
|   |-- hooks/
|   |-- contexts/
|   |-- pages/
|   `-- lib/
`-- tests/

infra/
|-- docker/
|-- kafka/
`-- monitoring/

docker-compose.yml
```

**Structure Decision**: Use a polyglot monorepo with explicit service boundaries. Elixir owns
Kite-facing real-time and API boundaries, Python owns deterministic analytics and consumers,
and the React dashboard consumes REST plus Phoenix Channel streams. Shared documentation stays
under `specs/kiteedge` so subsequent phases use a fixed artifact path instead of feature-
numbered directories.

## Service Architecture

### 1. Gateway API

- Technology: Elixir, Phoenix, Ecto, Tesla, Oban, Cachex.
- Responsibilities:
  - Manage Kite OAuth redirect and session exchange.
  - Proxy brokerage reads with rate limiting, retries, and circuit breaking.
  - Serve portfolio, holdings, instrument, and trade endpoints to the dashboard.
  - Publish live portfolio and alert events through Phoenix Channels.
  - Schedule recurring sync work for holdings, instruments, and historical refresh.
- Data ownership:
  - Writes current holdings, positions, orders, trades, dividends, and snapshots to
    PostgreSQL.
  - Stores ephemeral access tokens in Redis only.

### 2. Market Data Service

- Technology: Elixir, KiteTicker integration, Kafka producer, Redis cache updater.
- Responsibilities:
  - Maintain the live WebSocket connection to Kite.
  - Manage instrument subscriptions for holdings and watchlist instruments.
  - Normalize ticks and publish them to `market.ticks`.
  - Update Redis LTP cache and freshness metadata.
  - Handle reconnection, backoff, and market-mode transitions.

### 3. Analytics Engine

- Technology: Python, FastAPI, ta, QuantStats, scipy, statsmodels, prophet, pandas,
  scikit-learn, openpyxl.
- Responsibilities:
  - Compute technical indicators, summary scores, patterns, support/resistance.
  - Compute risk metrics, VaR, covariance, stress testing, and forward simulations.
  - Generate price and portfolio forecasts plus forecast accuracy metrics.
  - Compute trade performance, cost basis, and execution quality outputs.
  - Generate tear sheets and export payloads.
- Boundary rule:
  - Consumes normalized data from PostgreSQL, Kafka, Redis, or internal APIs.
  - Does not persist or own long-lived Kite authentication state.

### 4. Data Pipeline

- Technology: Python consumers on Kafka.
- Responsibilities:
  - Aggregate ticks to OHLCV candles across supported timeframes.
  - Recompute indicators on candle close.
  - Recompute risk metrics on portfolio changes and schedules.
  - Evaluate alert rules and publish alert events.
  - Retrain forecast models on nightly batches.

### 5. Dashboard

- Technology: React, TypeScript, lightweight-charts, Recharts, TanStack Query, shadcn/ui.
- Responsibilities:
  - Render the eight major user-facing sections: portfolio, technical, risk, predictions,
    trades, suggestions, reports, settings, and supporting shared views.
  - Subscribe to Phoenix Channels for live profit and loss, tick, alert, and progress events.
  - Surface legal disclaimers on every prediction, suggestion, report, and login surface.

### 6. Notification Service

- Technology: Elixir, Broadway, Phoenix PubSub, optional email transport.
- Responsibilities:
  - Consume `alerts.fired` events from Kafka.
  - Persist alert history and unread state.
  - Deliver real-time in-app notifications and optional email alerts.

## Data and Interface Artifacts

- [data-model.md](./data-model.md) defines PostgreSQL tables, partitioning, Kafka contracts,
  Redis keys, index strategy, and materialized views.
- [contracts/gateway-api.md](./contracts/gateway-api.md) defines the dashboard-facing REST
  boundary for holdings, positions, quotes, portfolio history, and trade retrieval.
- [contracts/analytics-api.md](./contracts/analytics-api.md) defines computation endpoints for
  analytics, risk, forecasts, signals, rebalancing, and report generation.
- [contracts/websocket-api.md](./contracts/websocket-api.md) defines Phoenix Channel topics,
  event payloads, and subscription expectations for live features.
- [quickstart.md](./quickstart.md) defines the manual Phase 2 validation path for the core
  flows.

## Infrastructure Plan

- PostgreSQL 16 stores historical market data, synced portfolio records, analytical snapshots,
  report metadata, and configuration state.
- Kafka 3.7 carries market ticks, candle events, analytics triggers, and fired alerts.
- Redis 7 stores ephemeral Kite sessions, rate-limiter counters, live quotes, freshness flags,
  and hot analytical caches.
- Docker Compose provisions all required local development services, including the dashboard,
  gateway, analytics engine, and data pipeline.
- Production targets remain ECS, RDS, ElastiCache, and MSK-compatible without changing the
  logical service boundaries.

## Delivery Sequence

1. Establish monorepo scaffolding and local infra.
2. Build Kite integration and instrument synchronization boundaries.
3. Deliver portfolio overview MVP for US1-US5.
4. Add technical analysis for US6-US10.
5. Add risk analytics for US11-US15.
6. Add forecasting for US16-US18.
7. Add trade analysis for US19-US22.
8. Add suggestions and alerts for US23-US26.
9. Add reporting and export for US27-US29.
10. Finish with performance, security, observability, and offline hardening.

## Source Structure Addenda (Phase 4 Remediation)

- `analytics_engine/api/services/` hosts orchestration services invoked by `analytics_engine/api/routes/`: `signals.py`, `rebalance.py`, `diversification.py`, and the shared `cache.py` helper. These modules own cross-module composition that does not belong in pure `risk/`, `technical/`, or `forecast/` packages.
- `dashboard/src/pages/SettingsPage.tsx` is the Settings surface declared by the plan. It hosts indicator-profile preferences (FR-023), watchlist management (FR-070), and notification-channel preferences (FR-071).
- `apps/kite_edge/lib/kite_edge/settings/` owns persisted user preferences: `indicator_profile.ex` and `notification_preferences.ex`.
- `apps/kite_edge/lib/kite_edge/watchlists.ex` owns the watchlist Ecto context.
- `apps/notification/lib/notification/email_adapter.ex` is the optional Swoosh email transport for alert delivery (FR-071).
- `analytics_engine/reports/pdf_export.py` and `analytics_engine/reports/disclaimers.py` cover printable export (FR-074) and cross-export disclaimer embedding (Constitution Principle 8).
- `apps/kite_edge_web/lib/kite_edge_web/controllers/reports/powerbi_controller.ex` serves the Power BI streaming dataset; the OData endpoint remains at `.../odata_controller.ex` (FR-075).

## Complexity Tracking

No constitutional violations require justification in this plan. The architecture uses exactly
six services, avoids automated trading, keeps live Kite session ownership narrow, and relies on
established libraries instead of custom reimplementation where approved libraries exist.