# KiteEdge — Developer Guide

> **Version:** 1.0.0 · **Last Updated:** May 2026
>
> Comprehensive technical reference for developers building, extending, and maintaining KiteEdge.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Technology Stack](#2-technology-stack)
3. [Repository Structure](#3-repository-structure)
4. [Development Environment Setup](#4-development-environment-setup)
5. [Elixir Umbrella Apps](#5-elixir-umbrella-apps)
6. [Python Analytics Engine](#6-python-analytics-engine)
7. [Python Data Pipeline](#7-python-data-pipeline)
8. [React Dashboard](#8-react-dashboard)
9. [Infrastructure Services](#9-infrastructure-services)
10. [API Reference](#10-api-reference)
11. [WebSocket Channels](#11-websocket-channels)
12. [Database Schema](#12-database-schema)
13. [Authentication & Security](#13-authentication--security)
14. [Configuration Reference](#14-configuration-reference)
15. [Testing Guide](#15-testing-guide)
16. [Build & Deployment](#16-build--deployment)
17. [Observability](#17-observability)
18. [Constitution & Design Principles](#18-constitution--design-principles)
19. [Troubleshooting](#19-troubleshooting)
20. [Contributing](#20-contributing)

---

## 1. Architecture Overview

KiteEdge is a **self-hosted portfolio intelligence platform** for Zerodha Kite users. It comprises six microservices organized as an Elixir umbrella with companion Python and React projects.

### System Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     Browser — React SPA (:5173)                        │
│  8 pages · TanStack Query · Recharts · Lightweight Charts · Tailwind  │
└────────┬──────────────────────────────────────────────┬────────────────┘
         │  REST (Axios)                                │  WebSocket
         ▼                                              ▼  (Phoenix Channels)
┌─────────────────────────────────────────────────────────────────────────┐
│            Phoenix Gateway — kite_edge_web (:4000)                     │
│  OAuth · REST API · Proxy to Python · WS Channels · Security Headers  │
├────────┬───────────┬───────────┬───────────┬──────────┬────────────────┤
│  Ecto  │  Finch    │  Redis    │  PubSub   │  Oban    │  Tesla         │
│  ↓     │  ↓        │  ↓        │  ↓        │  ↓       │  ↓             │
│  PG16  │  FastAPI  │  Sessions │  WS Bcast │  Jobs    │  Kite API      │
└────┬───┴─────┬─────┴─────┬────┴───────────┴──────────┴────────────────┘
     │         │           │
     ▼         ▼           ▼
┌──────────┐ ┌──────────────────────────────────┐ ┌───────────────────┐
│PostgreSQL│ │  Analytics Engine (FastAPI :8001) │ │   Redis 7         │
│  16      │ │  43+ indicators · Risk metrics   │ │   Session store   │
│          │ │  VaR · Monte Carlo · Forecast    │ │   Quote cache     │
│  Tables: │ │  Trade analytics · Signals       │ │   Rate counters   │
│  holdings│ │  Reports (HTML/XLSX/CSV/PDF)     │ │   18h TTL tokens  │
│  orders  │ │  scipy · ta · statsmodels        │ └───────────────────┘
│  trades  │ │  prophet · quantstats            │
│  instrs  │ └──────────────────────────────────┘
└──────────┘
                    ┌──────────────────────────────┐
┌───────────────┐   │  Data Pipeline (Python)       │
│  Kafka 3.7    │◄──│  Alert evaluator              │
│  (KRaft)      │──►│  Indicator updater            │
│               │   │  Forecast scheduler           │
│  Topics:      │   └──────────────────────────────┘
│  market.ticks │
│  candles.*    │   ┌──────────────────────────────┐
│  alerts.fired │──►│  Notification (Elixir)        │
└───────────────┘   │  Broadway consumer            │
                    │  In-app PubSub + Swoosh email │
┌───────────────┐   └──────────────────────────────┘
│  KiteTicker   │
│  WebSocket    │◄── MarketData GenServer (Elixir)
│  (Zerodha)    │    Binary frame decoder → Kafka publish
└───────────────┘
```

### Data Flow

1. **User authenticates** via Kite OAuth → session stored in Redis (18h TTL)
2. **Holdings sync** (Oban job) fetches from Kite API → persists to PostgreSQL
3. **Market data** streams via KiteTicker WebSocket → decoded → published to Kafka + Redis
4. **Data pipeline consumers** react to ticks: recompute indicators, evaluate alert rules, schedule forecasts
5. **Gateway proxies** analytics requests to Python FastAPI engine
6. **Dashboard** fetches REST data + subscribes to Phoenix channels for real-time updates
7. **Notifications** consume `alerts.fired` Kafka topic → broadcast in-app + email

---

## 2. Technology Stack

### Backend — Elixir / OTP

| Component | Version | Purpose |
|-----------|---------|---------|
| Elixir | 1.18+ | Functional language on BEAM VM |
| OTP | 27 | Fault-tolerant supervision trees |
| Phoenix | 1.7 | HTTP + WebSocket framework |
| Ecto | 3.11 | Database ORM with migrations |
| Oban | 2.17 | Background job scheduling |
| Tesla + Finch | 1.8 / 0.18 | HTTP client for Kite API + analytics proxy |
| Redix | 1.5 | Redis client |
| Cachex | 3.6 | In-memory caching |
| OpenApiSpex | 3.18 | OpenAPI specification generation |
| Broadway | 1.1 | Kafka consumer (notification service) |
| Swoosh | 1.16 | Email dispatch |

### Analytics — Python

| Component | Version | Purpose |
|-----------|---------|---------|
| Python | 3.12+ | Analytics runtime |
| FastAPI | latest | REST API framework |
| scipy | latest | XIRR calculation (brentq optimizer) |
| ta | 0.11.0 | Technical indicator library |
| statsmodels | latest | ARIMA time series forecasting |
| prophet | latest | Facebook Prophet forecasting |
| scikit-learn | latest | Ledoit-Wolf covariance estimation |
| pandas + numpy | latest | Data manipulation |
| quantstats | latest | QuantStats tear-sheet generation |
| reportlab | latest | PDF report generation |
| openpyxl | latest | Excel report generation |

### Frontend — React

| Component | Version | Purpose |
|-----------|---------|---------|
| React | 18.3 | UI framework |
| TypeScript | 5.3 | Type safety |
| Vite | 5.3 | Build tooling |
| TanStack Query | 5.51 | Server state management |
| Axios | latest | HTTP client |
| Phoenix (JS) | 1.7 | WebSocket channel client |
| Recharts | latest | Charting library |
| lightweight-charts | 4.1 | Candlestick / financial charts |
| Tailwind CSS | 3.4 | Utility-first styling |
| Vitest | 1.6 | Unit testing framework |

### Infrastructure

| Service | Version | Purpose |
|---------|---------|---------|
| PostgreSQL | 16 (Alpine) | Primary data store |
| Redis | 7 (Alpine) | Session store, quote cache |
| Kafka | 3.7 (KRaft) | Event streaming |
| Prometheus | 2.53 | Metrics collection |
| Grafana | 11.1 | Metrics dashboards |

---

## 3. Repository Structure

```
KiteEdge/
├── mix.exs                          # Root umbrella project
├── docker-compose.yml               # Full dev infrastructure
├── .env.example                     # Environment template
│
├── apps/
│   ├── kite_edge/                   # Core domain (Ecto, Kite client, sync)
│   │   ├── lib/kite_edge/
│   │   │   ├── application.ex       # Supervisor tree
│   │   │   ├── repo.ex              # Ecto repo
│   │   │   ├── kite/                # Kite API integration
│   │   │   │   ├── client.ex        # Tesla-based API wrapper
│   │   │   │   ├── session_store.ex # Redis ephemeral tokens
│   │   │   │   ├── rate_limiter.ex  # 3 req/sec token bucket
│   │   │   │   ├── request_pipeline.ex # Retry + backoff
│   │   │   │   └── error_mapper.ex  # Error normalization
│   │   │   ├── portfolio/           # Holdings, positions, XIRR, summary
│   │   │   ├── sync/               # Oban background sync workers
│   │   │   ├── market/             # Instrument master data
│   │   │   ├── settings/           # User preferences
│   │   │   ├── reports/            # Scheduled report jobs
│   │   │   └── logging/            # Sensitive data redaction
│   │   ├── priv/repo/migrations/   # Database migrations
│   │   └── test/
│   │
│   ├── kite_edge_web/               # Phoenix HTTP + WebSocket gateway
│   │   ├── lib/kite_edge_web/
│   │   │   ├── router.ex           # All route definitions
│   │   │   ├── endpoint.ex         # Phoenix endpoint config
│   │   │   ├── plugs/              # Security headers, auth middleware
│   │   │   ├── controllers/        # REST controllers
│   │   │   │   ├── auth_controller.ex
│   │   │   │   ├── portfolio/
│   │   │   │   ├── analytics/
│   │   │   │   ├── reports/
│   │   │   │   └── settings/
│   │   │   └── channels/           # WebSocket channels
│   │   │       ├── user_socket.ex
│   │   │       ├── portfolio_channel.ex
│   │   │       ├── ticks_channel.ex
│   │   │       ├── alerts_channel.ex
│   │   │       └── analytics_channel.ex
│   │   └── test/
│   │
│   ├── market_data/                 # KiteTicker WebSocket + Kafka publisher
│   │   └── lib/market_data/
│   │       ├── kite_ticker/
│   │       │   ├── connection.ex    # WebSocket lifecycle GenServer
│   │       │   └── decoder.ex       # Binary tick frame decoder
│   │       └── tick_publisher.ex    # Kafka + Redis publishing
│   │
│   └── notification/                # Alert consumer + email delivery
│       └── lib/notification/
│           ├── alert_consumer.ex    # Broadway Kafka processor
│           ├── email_adapter.ex     # Swoosh email composition
│           └── alert_history.ex     # Alert delivery persistence
│
├── analytics_engine/                # Python FastAPI service
│   ├── api/
│   │   ├── main.py                  # App entry + XIRR endpoint
│   │   ├── routes/                  # Route modules
│   │   └── services/               # Signal screening, rebalance, cache
│   ├── technical/                   # 43+ indicators, patterns, S/R
│   ├── risk/                        # Risk metrics, VaR, Monte Carlo
│   ├── forecast/                    # ARIMA, Prophet, ensemble
│   ├── portfolio/                   # XIRR calculation
│   ├── trades/                      # FIFO matching, performance
│   ├── reports/                     # Tearsheet, Excel, CSV, PDF
│   └── tests/                       # pytest suite (64+ tests)
│
├── data_pipeline/                   # Python Kafka consumers
│   ├── consumers/
│   │   ├── indicator_updater.py
│   │   ├── forecast_scheduler.py
│   │   └── alert_evaluator.py
│   └── tests/
│
├── dashboard/                       # React/Vite SPA
│   ├── src/
│   │   ├── App.tsx                  # Router + auth guards
│   │   ├── pages/                   # 8 page components
│   │   ├── components/              # Feature-specific components
│   │   ├── hooks/                   # Data fetching hooks
│   │   └── lib/                     # api.ts, ws.ts utilities
│   └── tests/
│
├── config/                          # Elixir environment configs
├── infra/                           # Docker, Prometheus, Grafana, Kafka
├── specs/                           # Specifications & constitution
└── docs/                            # Documentation
```

---

## 4. Development Environment Setup

### Prerequisites

| Requirement | Minimum Version |
|------------|-----------------|
| Elixir | 1.17+ (recommended 1.18) |
| Erlang/OTP | 27 |
| Python | 3.12+ |
| Node.js | 20+ |
| Docker + Docker Compose | Latest |
| Git | 2.x |

### Step 1: Clone and Configure

```bash
git clone <repo-url>
cd KiteEdge
cp .env.example .env
```

Edit `.env` with your credentials:
- **`KITE_API_KEY`** / **`KITE_API_SECRET`** — from [Kite Developer Console](https://developers.kite.trade/apps)
- **`SECRET_KEY_BASE`** — generate with `mix phx.gen.secret`
- Database, Redis, and Kafka defaults work with docker-compose

### Step 2: Start Infrastructure

```bash
docker-compose up -d postgres redis kafka kafka-init prometheus grafana
```

This starts:
- PostgreSQL 16 on port `5432`
- Redis 7 on port `6379`
- Kafka 3.7 (KRaft mode) on port `9092`
- Prometheus on port `9090`
- Grafana on port `3001`

Verify all services are healthy:
```bash
docker-compose ps
```

### Step 3: Elixir Gateway

```bash
# Install Elixir dependencies
mix deps.get

# Create database, run migrations, seed data
mix ecto.setup

# Start the Phoenix server
iex -S mix phx.server
```

The gateway starts on `http://localhost:4000`.

#### Corporate Proxy / TLS Issues

If behind a corporate proxy (e.g., Zscaler) that intercepts TLS:

```powershell
# Export CA bundle
$env:HEX_CACERTS_PATH = "$env:TEMP\cacerts.pem"

# Then run mix commands normally
mix deps.get
```

### Step 4: Python Analytics Engine

```bash
cd analytics_engine

# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate
# Activate (Linux/macOS)
source .venv/bin/activate

# Install with dev dependencies
pip install -e ".[dev]"

# Start the FastAPI server
uvicorn analytics_engine.api.main:app --host 0.0.0.0 --port 8001 --reload
```

The analytics engine starts on `http://localhost:8001`.

### Step 5: React Dashboard

```bash
cd dashboard

# Install dependencies
npm install

# Start dev server
npm run dev
```

The dashboard starts on `http://localhost:5173`.

### Step 6: Data Pipeline (Optional)

```bash
cd data_pipeline
pip install -e ".[dev]"
# Run individual consumers as needed
python -m data_pipeline.consumers.alert_evaluator
```

### Verification

| Service | URL | Expected |
|---------|-----|----------|
| Gateway | `http://localhost:4000/health` | `{"status": "ok"}` |
| Analytics | `http://localhost:8001/health` | `{"status": "ok"}` |
| Dashboard | `http://localhost:5173` | Login page |
| Grafana | `http://localhost:3001` | Login (admin/admin) |

---

## 5. Elixir Umbrella Apps

### 5.1 kite_edge — Core Domain

The central domain app containing business logic, Kite API integration, and data persistence.

#### Supervision Tree (`application.ex`)

```
KiteEdge.Application
├── KiteEdge.Repo                    # Ecto PostgreSQL connection pool
├── {Phoenix.PubSub, name: ...}      # PubSub for channel broadcasts
├── {Finch, name: KiteEdge.Finch}    # HTTP connection pool
├── {Cachex, name: :kite_cache}      # In-memory cache
├── KiteEdge.Kite.RateLimiter        # 3 req/sec token bucket
├── KiteEdge.Kite.SessionStore       # Redis-backed token store
└── {Oban, ...}                      # Background job processor
```

#### Kite API Client (`kite/client.ex`)

The Tesla-based HTTP client wraps all Kite API calls with:
- **Rate limiting** — acquires token from `RateLimiter` before every call
- **Request pipeline** — automatic retry with exponential backoff
- **Error mapping** — normalizes Kite errors to internal types
- **Credential injection** — adds auth headers from `SessionStore`

```elixir
# Usage pattern
KiteEdge.Kite.Client.get_holdings(session_id)
# → {:ok, holdings_list} | {:error, :token_expired} | {:error, :upstream_unavailable}
```

#### Session Store (`kite/session_store.ex`)

GenServer backed by Redis. Stores Kite access tokens with 18-hour TTL.

**Critical design constraint (Constitution Principle VII):** Tokens are NEVER persisted to PostgreSQL, logs, or source control.

```elixir
SessionStore.put(session_id, %{"access_token" => "xxx", "user_id" => "yyy"})
SessionStore.fetch(session_id)  # → {:ok, payload} | :error
SessionStore.delete(session_id)
```

#### Rate Limiter (`kite/rate_limiter.ex`)

Token-bucket GenServer enforcing the 3 req/sec Kite API cap (Constitution Principle I).

- Bucket refills every 1 second
- Callers block via `GenServer.call(:acquire, :infinity)` until a token is available
- Unused tokens carry over between refill intervals (up to capacity)

#### Sync Workers (`sync/`)

Oban-powered background jobs that synchronize data from Kite:

| Worker | Schedule | Action |
|--------|----------|--------|
| `HoldingsSync` | Every 5 min during market hours | Fetch holdings → upsert to DB |
| `TradesSync` | Post market close | Fetch day's trade history |
| `InstrumentMasterSync` | Daily | Refresh instrument list |
| `HistoricalBackfill` | On-demand | 5 years daily OHLCV for all instruments |

#### Portfolio Modules (`portfolio/`)

| Module | Key Functions |
|--------|---------------|
| `HoldingsQuery` | `list_holdings/1` with freshness classification |
| `Summary` | Portfolio totals, allocation breakdowns |
| `SectorClassification` | Map instruments to sectors |
| `MarketCapDistribution` | Large/mid/small-cap buckets |
| `ConcentrationRisk` | Herfindahl-Hirschman Index |
| `HoldingReturns` | Per-holding XIRR, CAGR |
| `DividendSummary` | Total dividends, per-holding yield |
| `OfflineMode` | Freshness status: `live` / `stale` / `offline` |

#### Logging Redactor (`logging/redactor.ex`)

Scrubs sensitive fields from structured logs before emission:

```elixir
@sensitive_keys ~w(access_token api_secret api_key password token
                   authorization cookie secret private_key
                   refresh_token session_id bearer)
```

Any map key containing one of these substrings gets replaced with `"[REDACTED]"`.

### 5.2 kite_edge_web — Phoenix Gateway

The HTTP + WebSocket interface for all external clients.

#### Router (`router.ex`)

Pipeline structure:
- `:browser` — session, CSRF, security headers
- `:api` — JSON accept, CORS, `RequireSession` plug

Route scopes:
- `/auth/kite/*` — OAuth login/callback/logout (no auth required)
- `/api/v1/*` — All API endpoints (auth required)
- `/health`, `/metrics` — Infrastructure (no auth)

#### Plugs

| Plug | Purpose |
|------|---------|
| `SecurityHeaders` | Injects CSP, HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection |
| `RequireSession` | Extracts session cookie → validates against Redis → injects user into conn assigns |

#### Controllers

Controllers follow a consistent pattern:
1. Extract params from request
2. Call domain module or proxy to analytics engine
3. Return JSON response with appropriate status

Analytics controllers proxy requests to the Python FastAPI engine via Finch HTTP client.

### 5.3 market_data — Real-Time Tick Ingestion

#### Connection GenServer

Maintains a persistent WebSocket connection to KiteTicker (Kite's real-time data feed):
- Auto-reconnect on disconnection
- Subscribe/unsubscribe to instrument tokens
- Heartbeat monitoring

#### Binary Decoder

Decodes Kite's proprietary binary tick frame format into structured data:
- Last traded price, volume, OHLC
- Market depth (5 levels bid/ask)
- Timestamp, instrument token

#### Tick Publisher

Publishes decoded ticks to:
- **Kafka** `market.ticks` topic — for downstream consumers
- **Redis** — quote cache for REST API freshness

### 5.4 notification — Alert Delivery

#### Broadway Consumer

Processes messages from `alerts.fired` Kafka topic:
1. Deserialize alert payload
2. Broadcast via Phoenix PubSub → appears in dashboard alerts channel
3. Optionally dispatch email via Swoosh SMTP adapter
4. Persist to `alert_history` for audit trail

---

## 6. Python Analytics Engine

### 6.1 Architecture

```
analytics_engine/
├── api/
│   ├── main.py              # FastAPI app, health, XIRR endpoint
│   ├── routes/
│   │   ├── technical.py     # POST /api/v1/analytics/technical/{symbol}
│   │   ├── risk.py          # POST /api/v1/analytics/risk/*
│   │   ├── forecast.py      # POST /api/v1/analytics/forecast/*
│   │   ├── trades.py        # GET /api/v1/analytics/trades/performance
│   │   ├── signals.py       # GET /api/v1/analytics/signals
│   │   └── reports.py       # POST /api/v1/reports/*
│   └── services/
│       ├── signals.py       # Signal screening + ranking
│       ├── rebalance.py     # Portfolio rebalance logic
│       ├── diversification.py # HHI concentration analysis
│       └── cache.py         # TTL-based computation caching
├── technical/               # Indicator computation
├── risk/                    # Risk analytics
├── forecast/                # Time series forecasting
├── portfolio/               # XIRR
├── trades/                  # Trade analytics
└── reports/                 # Report generation
```

### 6.2 Technical Indicators (`technical/`)

#### `indicators.py` — 43+ Indicators

**Trend Indicators:**
- SMA (20, 50, 200-period)
- EMA (12, 26-period)
- MACD (12, 26, 9)
- ADX (14-period)
- Ichimoku Cloud (9, 26, 52)
- Parabolic SAR
- Aroon (25-period)
- SuperTrend

**Momentum Indicators:**
- RSI (14-period)
- Stochastic RSI
- Williams %R
- CCI (20-period)
- ROC (12-period)
- Ultimate Oscillator
- KAMA
- TSI

**Volatility Indicators:**
- Bollinger Bands (20, 2σ)
- ATR (14-period)
- Keltner Channel
- Donchian Channel
- Historical Volatility (20-period)

**Volume Indicators:**
- OBV
- VWAP
- Chaikin Money Flow
- Money Flow Index
- Accumulation/Distribution
- Force Index
- Ease of Movement
- Volume Price Trend
- Negative Volume Index

All indicators use the `ta` library and are validated against reference implementations within 0.01% deviation.

#### `summary.py` — Technical Summary Score

Computes a composite score in `[-100, +100]` from weighted signals:

| Score Range | Classification |
|-------------|---------------|
| > +50 | **Strong Buy** |
| +20 to +50 | **Buy** |
| -20 to +20 | **Neutral** |
| -50 to -20 | **Sell** |
| < -50 | **Strong Sell** |

#### `patterns.py` — Chart Pattern Detection

Detects: Head-and-Shoulders, Double Top/Bottom, Triangle, Wedge patterns.

#### `support_resistance.py` — Support/Resistance Levels

Pivot-based level detection with fractal confirmation.

### 6.3 Risk Analytics (`risk/`)

#### `metrics.py` — Risk Ratios

| Metric | Formula |
|--------|---------|
| Sharpe Ratio | $(R_p - R_f) / \sigma_p$ annualized |
| Sortino Ratio | $(R_p - R_f) / \sigma_{downside}$ |
| Calmar Ratio | $R_{annual} / MaxDD$ |
| Information Ratio | $(R_p - R_b) / \sigma_{tracking}$ |
| Treynor Ratio | $(R_p - R_f) / \beta$ |
| Beta | $\text{Cov}(R_p, R_m) / \text{Var}(R_m)$ |
| Jensen's Alpha | $R_p - [R_f + \beta(R_m - R_f)]$ |

Plus rolling variants (30/60/90-day windows) and drawdown analysis (depth, duration, recovery).

#### `var.py` — Value at Risk

Three VaR methodologies:

1. **Historical VaR** — empirical quantile of actual return distribution + CVaR (Expected Shortfall)
2. **Parametric VaR** — Gaussian assumption: $VaR = \mu - z_\alpha \times \sigma$
3. **Monte Carlo VaR** — GBM simulation with drift + diffusion, terminal distribution quantile

Default confidence levels: 95% and 99%.

#### `montecarlo.py` — Forward Simulation

10,000 GBM paths over configurable horizon (default 252 trading days):
- Terminal distribution percentiles (5th, 25th, 50th, 75th, 95th)
- Mean / std / probability of loss
- Input validation: `horizon >= 1`

#### `correlation.py` — Correlation Analysis

- Pearson and Spearman correlation matrices
- Ledoit-Wolf shrinkage covariance estimator (scikit-learn)
- Marginal risk contribution per asset

#### `stress.py` — Scenario Analysis

Historical stress scenarios:
- COVID-19 crash (March 2020)
- Global Financial Crisis (2008)
- Indian Demonetisation (November 2016)
- Taper Tantrum (2013)

### 6.4 Forecasting (`forecast/`)

#### `arima.py`

ARIMA(5,1,0) via `statsmodels`. Returns point forecasts + confidence intervals.

#### `prophet_model.py`

Facebook Prophet with:
- Indian NSE trading calendar (holidays, half-days)
- Weekly seasonality mode
- Uncertainty intervals

#### `ensemble.py`

Inverse-MAE weighted average of ARIMA + Prophet predictions. Higher-accuracy model gets more weight.

#### `signals.py` — Signal Detection

| Signal | Logic |
|--------|-------|
| MA Crossover | EMA(12) crosses above/below EMA(26) |
| RSI Divergence | Price makes new low but RSI higher (bullish) |
| Bollinger Squeeze | BB inside Keltner Channel = volatility compression |
| Volume-Price Divergence | Price rising on declining volume (bearish) |

#### `accuracy.py` — Accuracy Metrics

- MAE (Mean Absolute Error)
- RMSE (Root Mean Squared Error)
- MAPE (Mean Absolute Percentage Error)
- Directional Accuracy (% correct up/down predictions)

### 6.5 Trade Analytics (`trades/`)

#### `cost_basis.py` — FIFO Matching

Matches buy and sell orders using First-In-First-Out methodology, producing `MatchedTrade` dataclasses with:
- Symbol, buy/sell prices, quantity
- P&L (absolute), holding period
- Buy/sell dates

#### `performance.py` — Performance Metrics

- **Per-trade P&L**: return % per matched trade
- **Summary**: win rate, avg win/loss, expectancy, profit factor, streaks
- **Equity curve**: cumulative P&L with proper drawdown tracking
- **Holding period**: avg/median/min/max holding days

### 6.6 Reports (`reports/`)

| Module | Output | Format |
|--------|--------|--------|
| `tearsheet.py` | QuantStats tear sheet | HTML |
| `excel.py` | Workbook with holdings, P&L, indicators, risk | XLSX |
| `csv_export.py` | Holdings, trades, signals tables | CSV |
| `pdf_export.py` | Tear sheet with legal disclaimers | PDF |
| `disclaimers.py` | Legal text constants | — |

All reports include mandatory disclaimers per Constitution Principle VI.

---

## 7. Python Data Pipeline

### Architecture

Three Kafka consumers, each running as independent Python processes:

#### Alert Evaluator (`alert_evaluator.py`)

- **Input:** `market.ticks` Kafka topic
- **Logic:** Evaluates tick data against user-defined `AlertRule`s (price_above, price_below, pct_change)
- **Output:** Matching alerts published to `alerts.fired` topic

```python
@dataclass
class AlertRule:
    symbol: str
    condition: str      # "price_above" | "price_below" | "pct_change"
    threshold: float

def evaluate_tick(tick: dict, rules: list[AlertRule]) -> list[dict]:
    # Returns list of fired alerts
```

#### Indicator Updater (`indicator_updater.py`)

- **Input:** `candles.1m`, `candles.5m`, etc.
- **Logic:** On candle close, recomputes technical indicators for affected symbol/timeframe
- **Output:** Updated indicator values stored in Redis/PostgreSQL

#### Forecast Scheduler (`forecast_scheduler.py`)

- **Trigger:** Daily at market close (via Oban cron in kite_edge)
- **Logic:** Generates fresh ARIMA + Prophet forecasts for all held instruments
- **Output:** Forecast results stored for next-day dashboard display

---

## 8. React Dashboard

### 8.1 Project Setup

```bash
# Install
npm install

# Dev server (port 5173)
npm run dev

# Production build
npm run build

# Type check
npx tsc --noEmit

# Test
npm test

# Test with coverage
npm test -- --coverage
```

### 8.2 Configuration

**`vite.config.ts`:**
- Path alias: `@/` → `src/`
- Dev server port: 5173
- React plugin with SWC

**Environment variables (`.env`):**
```
VITE_GATEWAY_URL=http://localhost:4000
VITE_KITE_API_KEY=your-api-key
```

### 8.3 Routing & Auth Guards

All protected routes are wrapped in `<RequireAuth>`:

```tsx
<Routes>
  <Route path="/" element={<LoginPage />} />
  <Route path="/dashboard" element={<RequireAuth><PortfolioOverviewPage /></RequireAuth>} />
  <Route path="/analysis" element={<RequireAuth><InstrumentAnalysisPage /></RequireAuth>} />
  {/* ... all other routes similarly guarded */}
</Routes>
```

`RequireAuth` calls `GET /api/v1/auth/status` and redirects to `/` if unauthenticated.

### 8.4 Data Fetching Hooks

All data fetching uses TanStack Query for caching, deduplication, and background refresh:

| Hook | Query Key | Endpoint | Stale Time |
|------|-----------|----------|-----------|
| `useAuth()` | `['auth', 'status']` | GET `/api/v1/auth/status` | 60s |
| `usePortfolioOverview()` | `['portfolio', 'holdings']` | GET `/api/v1/portfolio/holdings` | 5s |
| `useTechnicalAnalysis()` | `['technical', symbol, exchange]` | POST `/api/v1/analytics/technical/{symbol}` | manual |
| `useRiskDashboard()` | `['risk', 'portfolio']` | POST `/api/v1/analytics/risk/portfolio` | manual |
| `useSettings()` | `['settings']` | GET `/api/v1/settings/*` | 60s |
| `useWatchlists()` | `['watchlists']` | GET `/api/v1/watchlists` | manual |
| `useInstrumentLookup()` | `['instruments', query]` | GET `/api/v1/instruments/search` | manual |

### 8.5 WebSocket Integration (`lib/ws.ts`)

Phoenix Channel client with connection reuse and channel deduplication:

```typescript
getSocket()                          // Singleton WebSocket connection
joinChannel(topic, params?)          // Idempotent — returns existing channel if already joined
leaveChannel(topic)                  // Cleanup — removes from registry
```

Channels used:
- `portfolio:live` — portfolio tick updates
- `alerts:{user_id}` — real-time alert notifications
- `analytics:{request_id}` — long computation progress

### 8.6 HTTP Client (`lib/api.ts`)

Axios instance with:
- Base URL from `VITE_GATEWAY_URL` env var
- `withCredentials: true` for session cookies
- **401 interceptor** — auto-redirects to login on session expiry

### 8.7 Component Architecture

```
components/
├── auth/
│   ├── RequireAuth.tsx              # Route guard
│   └── LoginFooterDisclaimer.tsx    # Login page disclaimer
├── portfolio/
│   ├── AllocationCharts.tsx         # Sector + market-cap pie charts
│   └── HoldingDetailDrawer.tsx      # Slide-out holding detail
├── technical/
│   ├── InstrumentSearch.tsx         # Typeahead instrument search
│   ├── IndicatorConfigPanel.tsx     # Custom indicator parameters
│   ├── SummaryGauge.tsx             # [-100,+100] visual gauge
│   ├── SummaryBreakdown.tsx         # Category breakdown table
│   └── TimeframeComparison.tsx      # Multi-TF comparison view
├── charts/
│   ├── CandlestickChart.tsx         # Lightweight Charts integration
│   └── IndicatorOverlays.tsx        # Indicator overlay rendering
├── risk/
│   ├── RiskCards.tsx                 # Sharpe/Sortino/Calmar cards
│   ├── VaRHistogram.tsx             # VaR distribution chart
│   ├── MonteCarloFan.tsx            # Simulation fan chart
│   ├── DrawdownChart.tsx            # DD depth + recovery
│   ├── CorrelationHeatmap.tsx       # Matrix heatmap
│   └── StressScenarioPanel.tsx      # Scenario impact table
├── forecast/
│   ├── ForecastChart.tsx            # Forecast + confidence intervals
│   ├── SignalFeed.tsx               # Signal event feed
│   ├── ModelAccuracy.tsx            # MAE/RMSE/MAPE display
│   └── Disclaimer.tsx              # Prediction disclaimer
├── trades/
│   ├── TradeHistory.tsx             # Trade history table
│   ├── EquityCurve.tsx              # Equity + drawdown chart
│   ├── PerformanceDashboard.tsx     # Win rate, expectancy, streaks
│   └── PLCalendar.tsx               # Calendar heat-map
├── suggestions/
│   ├── SignalCards.tsx               # Ranked signal cards
│   ├── AlertConfig.tsx              # Alert rule configuration
│   ├── AlertChannelSettings.tsx     # In-app/email toggle
│   ├── Rebalancer.tsx               # Rebalance calculator
│   ├── DiversificationRadar.tsx     # HHI radar chart
│   ├── WatchlistManager.tsx         # CRUD watchlists
│   └── Disclaimer.tsx              # Suggestion disclaimer
├── reports/
│   ├── TearSheetViewer.tsx          # HTML tearsheet viewer
│   ├── ExportCenter.tsx             # Export format selector
│   ├── PowerBIConnectionGuide.tsx   # Power BI setup guide
│   └── ReportDisclaimer.tsx         # Report disclaimer
└── shared/
    ├── Disclaimer.tsx               # Reusable disclaimer (4 variants)
    └── FreshnessIndicator.tsx       # Live/stale/offline badge
```

---

## 9. Infrastructure Services

### Docker Compose Services

```yaml
services:
  postgres:     # Port 5432 - PostgreSQL 16 Alpine
  redis:        # Port 6379 - Redis 7 Alpine (no persistence)
  kafka:        # Port 9092 - Bitnami Kafka 3.7 (KRaft mode)
  kafka-init:   # One-shot topic creation
  prometheus:   # Port 9090 - Metrics collection
  grafana:      # Port 3001 - Dashboard visualization
  gateway:      # Port 4000 - Elixir Phoenix
  market_data:  # KiteTicker WebSocket consumer
  notification: # Broadway Kafka consumer
  analytics_engine: # Port 8001 - Python FastAPI
  data_pipeline:    # Python Kafka consumers
  dashboard:    # Port 5173 - React Vite
```

### Kafka Topics

Created by `infra/kafka/create-topics.sh`:

| Topic | Partitions | Purpose |
|-------|-----------|---------|
| `market.ticks` | 4 | Real-time tick data from KiteTicker |
| `candles.1m` | 2 | 1-minute aggregated candles |
| `candles.5m` | 2 | 5-minute aggregated candles |
| `candles.15m` | 2 | 15-minute aggregated candles |
| `candles.1d` | 1 | Daily candles |
| `alerts.fired` | 2 | Triggered alert events |

### Redis Key Patterns

| Pattern | TTL | Purpose |
|---------|-----|---------|
| `kiteedge:session:{id}` | 18h | Kite access token storage |
| `kiteedge:quote:{token}` | 30s | Latest tick quote cache |
| `kiteedge:rate:{node}` | 1s | Rate limiter state |

---

## 10. API Reference

### Authentication

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/auth/kite/login` | GET | No | Redirects to Kite OAuth login |
| `/auth/kite/callback` | GET | No | OAuth callback, creates session |
| `/auth/kite/logout` | DELETE | Yes | Clears session from Redis |
| `/api/v1/auth/status` | GET | No | Returns `{authenticated: bool}` |

### Portfolio

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/portfolio/holdings` | GET | Yes | Current holdings with live prices |
| `/api/v1/portfolio/summary` | GET | Yes | Portfolio totals + allocation |
| `/portfolio/xirr` | POST | Yes | XIRR calculation (Python direct) |

**Holdings Response:**
```json
{
  "data": [
    {
      "tradingsymbol": "RELIANCE",
      "exchange": "NSE",
      "instrument_token": 738561,
      "quantity": 10,
      "average_price": "2450.50",
      "last_price": "2523.75",
      "pnl": "732.50",
      "day_change": "15.25",
      "day_change_pct": "0.61",
      "sector": "Energy"
    }
  ],
  "meta": {
    "freshness": "live",
    "synced_at": "2026-05-16T10:30:00Z"
  }
}
```

### Technical Analysis

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/analytics/technical/{symbol}` | POST | Yes | Full indicator suite |
| `/api/v1/analytics/technical/{symbol}/summary` | GET | Yes | Summary score + band |

**Request Body:**
```json
{
  "exchange": "NSE",
  "timeframes": ["1d"],
  "parameter_profile": "default",
  "include_patterns": true,
  "include_support_resistance": true
}
```

### Risk Analytics

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/analytics/risk/portfolio` | POST | Yes | Risk ratios, volatility, drawdown |
| `/api/v1/analytics/risk/var` | POST | Yes | VaR (3 methods, 2 confidence levels) |
| `/api/v1/analytics/risk/montecarlo` | POST | Yes | Forward simulation (10K paths) |
| `/api/v1/analytics/risk/stress-test` | POST | Yes | Historical scenario analysis |
| `/api/v1/analytics/risk/correlation` | POST | Yes | Correlation matrix + Ledoit-Wolf |

### Forecasting

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/analytics/forecast/{symbol}` | POST | Yes | ARIMA + Prophet ensemble |
| `/api/v1/analytics/forecast/portfolio` | POST | Yes | Portfolio-level aggregation |

### Trade Analytics

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/analytics/trades/performance` | GET | Yes | FIFO P&L, metrics, equity curve |

### Signals & Suggestions

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/analytics/signals` | GET | Yes | Ranked signal feed |
| `/api/v1/analytics/rebalance` | POST | Yes | Rebalance recommendations |

### Reports

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/reports/tearsheet` | POST | Yes | QuantStats HTML tear sheet |
| `/api/v1/reports/export` | POST | Yes | XLSX / CSV / PDF export |
| `/api/v1/reports/odata/holdings` | GET | Yes | OData v4 entity set |
| `/api/v1/reports/odata/$metadata` | GET | Yes | OData CSDL metadata |
| `/api/v1/reports/powerbi/push` | POST | Yes | Power BI streaming push |

### Settings

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/v1/watchlists` | GET | Yes | List watchlists |
| `/api/v1/watchlists` | POST | Yes | Create watchlist |
| `/api/v1/watchlists/:id` | PUT | Yes | Update watchlist |
| `/api/v1/watchlists/:id` | DELETE | Yes | Delete watchlist |
| `/api/v1/settings/indicator-profile` | GET | Yes | Get indicator params |
| `/api/v1/settings/indicator-profile` | POST | Yes | Save indicator params |

### Infrastructure

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/health` | GET | No | Liveness check (DB + Redis + analytics) |
| `/metrics` | GET | No | Prometheus-compatible metrics |

---

## 11. WebSocket Channels

Phoenix Channel connections via `wss://localhost:4000/socket`.

### portfolio:live

Portfolio tick updates. Broadcasts on every tick for held instruments.

```javascript
const ch = joinChannel('portfolio:live')
ch.on('tick', (payload) => {
  // payload: { instrument_token, last_price, volume, timestamp }
})
```

### alerts:{user_id}

Real-time alert notifications when user-defined rules fire.

```javascript
const ch = joinChannel(`alerts:${userId}`)
ch.on('alert_fired', (payload) => {
  // payload: { symbol, condition, threshold, current_value, fired_at }
})
```

### analytics:{request_id}

Progress updates for long-running computations.

```javascript
const ch = joinChannel(`analytics:${requestId}`)
ch.on('progress', (payload) => {
  // payload: { step, total_steps, message }
})
ch.on('complete', (payload) => {
  // payload: { result }
})
```

### ticks:{instrument_token}

Raw tick data for individual instruments (used by candlestick chart).

---

## 12. Database Schema

### Core Tables

```sql
-- Instrument master data (500+ instruments)
CREATE TABLE instrument_masters (
  id            BIGSERIAL PRIMARY KEY,
  instrument_token INTEGER UNIQUE NOT NULL,
  tradingsymbol VARCHAR NOT NULL,
  exchange      VARCHAR NOT NULL,  -- 'NSE' | 'BSE'
  name          VARCHAR,
  sector_name   VARCHAR,
  market_cap_bucket VARCHAR,       -- 'large' | 'mid' | 'small'
  instrument_type VARCHAR,         -- 'EQ' | 'ETF'
  is_active     BOOLEAN DEFAULT true,
  inserted_at   TIMESTAMP NOT NULL,
  updated_at    TIMESTAMP NOT NULL
);

-- Current portfolio holdings
CREATE TABLE holdings_current (
  id            BIGSERIAL PRIMARY KEY,
  user_id       VARCHAR NOT NULL,
  instrument_id BIGINT REFERENCES instrument_masters(id),
  quantity      INTEGER NOT NULL,
  average_price DECIMAL(12,4) NOT NULL,
  last_price    DECIMAL(12,4),
  pnl_absolute  DECIMAL(12,4),
  pnl_percent   DECIMAL(8,4),
  synced_at     TIMESTAMP,
  inserted_at   TIMESTAMP NOT NULL,
  updated_at    TIMESTAMP NOT NULL
);

-- Historical orders
CREATE TABLE orders (
  id            BIGSERIAL PRIMARY KEY,
  user_id       VARCHAR NOT NULL,
  instrument_id BIGINT REFERENCES instrument_masters(id),
  order_id      VARCHAR UNIQUE NOT NULL,
  transaction_type VARCHAR NOT NULL, -- 'BUY' | 'SELL'
  filled_quantity INTEGER NOT NULL,
  average_price DECIMAL(12,4) NOT NULL,
  status        VARCHAR NOT NULL,
  order_timestamp TIMESTAMP NOT NULL,
  inserted_at   TIMESTAMP NOT NULL
);

-- User watchlists
CREATE TABLE watchlists (
  id            BIGSERIAL PRIMARY KEY,
  user_id       VARCHAR NOT NULL,
  name          VARCHAR NOT NULL,
  symbols       VARCHAR[] NOT NULL DEFAULT '{}',
  inserted_at   TIMESTAMP NOT NULL,
  updated_at    TIMESTAMP NOT NULL
);

-- Trading calendar (NSE/BSE)
CREATE TABLE trading_calendars (
  id            BIGSERIAL PRIMARY KEY,
  exchange      VARCHAR NOT NULL,
  calendar_date DATE NOT NULL,
  session_type  VARCHAR NOT NULL, -- 'regular' | 'holiday' | 'half_day'
  opens_at      TIME,
  closes_at     TIME,
  UNIQUE(exchange, calendar_date)
);

-- Notification preferences
CREATE TABLE notification_preferences (
  id            BIGSERIAL PRIMARY KEY,
  user_id       VARCHAR UNIQUE NOT NULL,
  in_app_enabled BOOLEAN DEFAULT true,
  email_enabled BOOLEAN DEFAULT false,
  price_threshold_pct DECIMAL(5,2) DEFAULT 5.0,
  inserted_at   TIMESTAMP NOT NULL,
  updated_at    TIMESTAMP NOT NULL
);

-- Indicator profiles (per-user custom params)
CREATE TABLE indicator_profiles (
  id            BIGSERIAL PRIMARY KEY,
  user_id       VARCHAR NOT NULL,
  profile_name  VARCHAR NOT NULL DEFAULT 'default',
  rsi_window    INTEGER DEFAULT 14,
  sma_windows   INTEGER[] DEFAULT '{20,50,200}',
  ema_windows   INTEGER[] DEFAULT '{12,26}',
  bb_window     INTEGER DEFAULT 20,
  bb_std        DECIMAL(3,1) DEFAULT 2.0,
  atr_window    INTEGER DEFAULT 14,
  inserted_at   TIMESTAMP NOT NULL,
  updated_at    TIMESTAMP NOT NULL,
  UNIQUE(user_id, profile_name)
);

-- Alert history
CREATE TABLE alert_history (
  id            BIGSERIAL PRIMARY KEY,
  user_id       VARCHAR NOT NULL,
  symbol        VARCHAR NOT NULL,
  condition     VARCHAR NOT NULL,
  threshold     DECIMAL(12,4) NOT NULL,
  current_value DECIMAL(12,4) NOT NULL,
  fired_at      TIMESTAMP NOT NULL,
  delivered_via VARCHAR[] DEFAULT '{}', -- ['in_app', 'email']
  inserted_at   TIMESTAMP NOT NULL
);
```

### Migrations

Located in `apps/kite_edge/priv/repo/migrations/`. Run with:

```bash
mix ecto.migrate       # Apply pending migrations
mix ecto.rollback      # Roll back last migration
mix ecto.reset         # Drop + create + migrate + seed
```

---

## 13. Authentication & Security

### OAuth Flow

```
                                ┌──────────────┐
                                │  Kite Login   │
     ┌──────┐  1. Click Login   │  Page         │
     │ User │ ──────────────►  │ (kite.trade)  │
     └──────┘                   │               │
        ▲                       └──────┬────────┘
        │                              │ 2. User authorizes
        │                              ▼
        │                       ┌──────────────┐
        │  5. Set cookie &      │  Callback     │
        │     redirect to       │  /auth/kite/  │
        │     /dashboard        │  callback     │
        │◄─────────────────────│               │
        │                       │  3. Exchange   │
        │                       │  request_token │
        │                       │  for access_   │
        │                       │  token         │
        │                       │               │
        │                       │  4. Store in   │
        │                       │  Redis (18h)  │
        │                       └──────────────┘
```

### Security Measures

| Measure | Implementation |
|---------|---------------|
| **Token Storage** | Redis only, 18h TTL, NEVER in PostgreSQL/logs |
| **Session Cookie** | httpOnly, Secure, SameSite=Lax |
| **Rate Limiting** | 3 req/sec to Kite API (token-bucket GenServer) |
| **HTTPS** | All Kite API communication over TLS |
| **CSP** | `default-src 'self'` |
| **HSTS** | `max-age=31536000; includeSubDomains` |
| **XSS Protection** | `X-XSS-Protection: 1; mode=block` |
| **Clickjacking** | `X-Frame-Options: DENY` |
| **MIME Sniffing** | `X-Content-Type-Options: nosniff` |
| **Log Redaction** | 13 sensitive key patterns scrubbed |
| **CORS** | `cors_plug` with configured allowed origins |
| **Auth Guards** | All `/api/v1/*` routes require valid session |
| **401 Handling** | Axios interceptor auto-redirects to login |

---

## 14. Configuration Reference

### Environment Variables

```bash
# ── Application ──────────────────────────────────────
KITEEDGE_ENV=dev                     # dev | test | prod
SECRET_KEY_BASE=<64-byte-hex>        # mix phx.gen.secret
PHX_HOST=localhost                   # Hostname for URL generation
PHX_PORT=4000                        # Gateway HTTP port

# ── PostgreSQL ───────────────────────────────────────
POSTGRES_HOST=postgres               # Hostname (docker service name)
POSTGRES_PORT=5432
POSTGRES_USER=kiteedge
POSTGRES_PASSWORD=kiteedge
POSTGRES_DB=kiteedge
DATABASE_URL=ecto://...              # Full Ecto URL

# ── Redis ────────────────────────────────────────────
REDIS_URL=redis://redis:6379/0       # Session store + cache

# ── Kafka ────────────────────────────────────────────
KAFKA_BOOTSTRAP_SERVERS=kafka:9092   # Bootstrap address

# ── Zerodha Kite ─────────────────────────────────────
KITE_API_KEY=                        # From developers.kite.trade
KITE_API_SECRET=                     # From developers.kite.trade
KITE_REDIRECT_URL=http://localhost:4000/auth/kite/callback
KITE_RATE_LIMIT_PER_SECOND=3        # Do not exceed 3

# ── Analytics Engine ─────────────────────────────────
ANALYTICS_ENGINE_URL=http://analytics_engine:8001
ANALYTICS_ENGINE_TIMEOUT_MS=15000    # Request timeout

# ── Notification ─────────────────────────────────────
NOTIFY_EMAIL_ENABLED=false           # Enable email alerts
NOTIFY_EMAIL_FROM=alerts@kiteedge.local
SMTP_HOST=                           # SMTP server hostname
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_TLS=true

# ── Observability ────────────────────────────────────
LOG_LEVEL=info                       # debug | info | warning | error
PROMETHEUS_ENABLED=true
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin
```

### Elixir Config Files

| File | Purpose |
|------|---------|
| `config/config.exs` | Shared configuration across all environments |
| `config/dev.exs` | Development-specific overrides |
| `config/test.exs` | Test environment (isolated DB, no Kafka) |
| `config/prod.exs` | Production settings (runtime config) |

### Dashboard Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `VITE_GATEWAY_URL` | `http://localhost:4000` | Gateway base URL |
| `VITE_KITE_API_KEY` | — | Displayed on login button |

---

## 15. Testing Guide

### Python Analytics Engine

```bash
cd analytics_engine

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=analytics_engine --cov-report=term-missing

# Run specific test file
pytest tests/test_risk_metrics.py -v

# Run benchmarks
pytest tests/benchmarks/ -v

# Important: Set PYTHONPATH for imports
$env:PYTHONPATH = "d:\Elixir\KiteEdge"  # Windows
export PYTHONPATH="$(pwd)"              # Linux/macOS
```

**Test files (64+ tests):**

| Test File | Coverage |
|-----------|----------|
| `test_indicators_trend.py` | SMA, EMA, MACD, ADX, Ichimoku |
| `test_indicators_momentum.py` | RSI, Stochastic, Williams %R, CCI, ROC |
| `test_indicators_volatility_volume.py` | BB, ATR, OBV, VWAP, MFI |
| `test_risk_metrics.py` | Sharpe, Sortino, Beta, Alpha, drawdown |
| `test_var_historical_parametric.py` | Historical + Parametric VaR |
| `test_var_montecarlo.py` | Monte Carlo VaR |
| `test_correlation.py` | Correlation matrix, Ledoit-Wolf |
| `test_stress.py` | Scenario analysis |
| `test_forecast_arima.py` | ARIMA model fitting |
| `test_forecast_prophet.py` | Prophet with seasonality |
| `test_forecast_signals.py` | Signal detection tests |
| `test_trade_performance.py` | FIFO P&L, win rate, equity curve |
| `test_trade_execution.py` | Slippage analysis |
| `test_technical_summary.py` | Summary score banding |
| `test_suggestions_signals.py` | Signal screening + ranking |
| `test_reports_tearsheet.py` | Tearsheet generation |
| `test_reports_export.py` | XLSX/CSV export |
| `test_reports_pdf.py` | PDF export |
| `test_rebalance.py` | Rebalance logic |
| `test_portfolio_forecast.py` | Portfolio forecast |
| `test_xirr_holdings.py` | XIRR calculation |

### React Dashboard

```bash
cd dashboard

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test
npm test -- src/tests/App.test.tsx

# Type check
npx tsc --noEmit

# Lint
npx eslint src/
```

**Test suite:** 9+ tests covering component rendering, routing, and hook behavior.

### Elixir

```bash
# Run all tests
mix test

# Run specific app tests
mix test apps/kite_edge/test/
mix test apps/kite_edge_web/test/

# Run with coverage (excoveralls)
mix coveralls

# Compile check
mix compile --warnings-as-errors
```

### Data Pipeline

```bash
$env:PYTHONPATH = "d:\Elixir\KiteEdge"
pytest data_pipeline/tests/ -v
```

### Continuous Integration Checklist

1. ✅ `mix compile --warnings-as-errors`
2. ✅ `mix test`
3. ✅ `pytest analytics_engine/tests/ -v`
4. ✅ `pytest data_pipeline/tests/ -v`
5. ✅ `cd dashboard && npx tsc --noEmit`
6. ✅ `cd dashboard && npm test`
7. ✅ `cd dashboard && npx vite build`

---

## 16. Build & Deployment

### Development (Docker Compose)

```bash
# Start everything
docker-compose up -d

# Start only infrastructure
docker-compose up -d postgres redis kafka kafka-init prometheus grafana

# View logs
docker-compose logs -f gateway

# Rebuild a service
docker-compose build gateway
docker-compose up -d gateway
```

### Production Build

#### Elixir Release

```bash
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix release kite_edge

# Start release
_build/prod/rel/kite_edge/bin/kite_edge start
```

#### Python Analytics Engine

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY pyproject.toml .
RUN pip install .
COPY . .
CMD ["uvicorn", "analytics_engine.api.main:app", "--host", "0.0.0.0", "--port", "8001"]
```

#### React Dashboard

```bash
cd dashboard
npm run build
# Serve dist/ with any static file server (nginx, caddy, etc.)
```

### Production Architecture Target

```
AWS ECS / Kubernetes
├── Gateway (Elixir release) → ALB → :4000
├── Analytics Engine (Python) → Internal NLB → :8001
├── Market Data (Elixir release) → Internal
├── Notification (Elixir release) → Internal
├── Data Pipeline (Python) → Internal
├── Dashboard (Static) → CloudFront/S3
│
├── RDS PostgreSQL 16
├── ElastiCache Redis 7
└── MSK (Managed Kafka)
```

---

## 17. Observability

### Health Check

```bash
curl http://localhost:4000/health
# {"status": "ok", "db": "connected", "redis": "connected", "analytics": "reachable"}
```

### Prometheus Metrics

Available at `http://localhost:4000/metrics`:

- `kite_api_requests_total` — Kite API call count by endpoint and status
- `kite_api_request_duration_seconds` — Latency histogram
- `kite_rate_limit_waits_total` — Rate limiter wait count
- `phoenix_endpoint_duration_seconds` — Request duration
- `oban_job_duration_seconds` — Background job execution time
- `analytics_computation_duration_seconds` — Analytics request duration

### Grafana Dashboards

Access at `http://localhost:3001` (admin/admin):

Pre-configured dashboards:
- **KiteEdge Overview** — Request rates, error rates, latencies
- **Kite API Health** — API success rate, rate limit utilization
- **Background Jobs** — Oban job execution, queue depths

### Structured Logging

All services emit JSON-structured logs with automatic sensitive field redaction:

```json
{
  "timestamp": "2026-05-16T10:30:00.000Z",
  "level": "info",
  "module": "KiteEdge.Kite.Client",
  "message": "holdings fetched",
  "user_id": "ABC123",
  "access_token": "[REDACTED]",
  "duration_ms": 245
}
```

---

## 18. Constitution & Design Principles

KiteEdge development is governed by 8 constitutional principles:

### I. Kite API as Single Source of Truth
All portfolio data originates from Kite. 3 req/sec limit enforced. Offline mode with freshness indicators when Kite is unavailable.

### II. Mathematical Rigor & Reproducibility
All computations are reproducible given identical inputs. Monte Carlo accepts seed parameters. Validated against reference implementations within 0.01%.

### III. Test-First Development
Red → Green → Refactor. Known-answer tests for financial computations. Walk-forward validation for forecasts.

### IV. Real-Time & Historical Duality
Historical and real-time computations yield identical results. Live updates via Phoenix Channels, not polling.

### V. Performance & Scalability
- Indicators: < 500ms for 5 years daily data
- Risk analysis: < 10s for 50-stock portfolio
- Page load: < 2s with pre-computed analytics
- Backfill: 500 instruments × 5 years < 30 minutes
- Tick processing: 100 instruments at full rate

### VI. Simplicity & YAGNI
Rule-based/statistical methods before ML. Analytics-only (no trade execution). 6 services maximum.

### VII. Security & Compliance
Tokens never in logs/DB. HTTPS only. Data stays self-hosted. Daily session expiry handled.

### VIII. Observability
Structured JSON logs. Health checks. Prometheus metrics. Rate limit and latency tracking.

---

## 19. Troubleshooting

### Common Issues

#### Elixir: `** (MatchError) no match of right hand side value: {:error, ...}` in SessionStore
**Cause:** Redis is not running.
**Fix:** Start Redis: `docker-compose up -d redis`

#### Elixir: TLS/SSL errors with `mix deps.get`
**Cause:** Corporate proxy intercepting HTTPS (Zscaler, etc.)
**Fix:**
```powershell
$env:HEX_CACERTS_PATH = "$env:TEMP\cacerts.pem"
# Export your corporate CA bundle to that path first
```

#### Python: `ModuleNotFoundError: No module named 'analytics_engine'`
**Cause:** PYTHONPATH not set.
**Fix:**
```powershell
$env:PYTHONPATH = "d:\Elixir\KiteEdge"
```

#### Dashboard: 401 errors / redirected to login
**Cause:** Kite session expired (18h TTL) or gateway not running.
**Fix:** Click "Sign in with Kite" to re-authenticate. Ensure gateway is running on port 4000.

#### Dashboard: WebSocket connection failed
**Cause:** Gateway not running or CORS issue.
**Fix:** Verify `VITE_GATEWAY_URL` matches the gateway address. Check gateway logs for CORS errors.

#### Analytics: Slow risk computation
**Cause:** Large portfolio (50+ holdings) with Monte Carlo simulation.
**Fix:** Reduce `simulations` parameter. Default 10,000 sims is usually sufficient.

#### Kafka: Topics not created
**Cause:** `kafka-init` container failed.
**Fix:**
```bash
docker-compose restart kafka-init
docker-compose logs kafka-init
```

---

## 20. Contributing

### Code Style

- **Elixir:** Follow `mix format` conventions. Module docs required for public functions.
- **Python:** Follow PEP 8. Type hints for all function signatures.
- **TypeScript:** ESLint + Prettier. Strict TypeScript (`noEmit` must pass).
- **All:** Constitution principles are non-negotiable constraints.

### Pull Request Checklist

- [ ] All tests pass (`mix test`, `pytest`, `npm test`)
- [ ] TypeScript compiles (`npx tsc --noEmit`)
- [ ] Vite builds (`npx vite build`)
- [ ] No sensitive data in code or logs
- [ ] Disclaimers present on any prediction/suggestion/report surface
- [ ] Constitution principles respected
- [ ] New financial computations include known-answer tests

### Branch Strategy

- `main` — stable, deployable
- `develop` — integration branch
- `feature/*` — feature branches
- `fix/*` — bug fix branches

---

*This document is maintained alongside the codebase. Update it when adding new features, endpoints, or architectural changes.*
