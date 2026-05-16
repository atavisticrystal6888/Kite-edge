# KiteEdge

> Self-hosted portfolio intelligence platform for Zerodha Kite users — deep analytics, risk quantification, forecasting, and smart suggestions with mathematical rigor.

[![Elixir](https://img.shields.io/badge/Elixir-1.16-purple?logo=elixir)](https://elixir-lang.org/)
[![Python](https://img.shields.io/badge/Python-3.11+-blue?logo=python)](https://python.org/)
[![React](https://img.shields.io/badge/React-18-61dafb?logo=react)](https://react.dev/)
[![Phoenix](https://img.shields.io/badge/Phoenix-1.7-orange?logo=phoenixframework)](https://phoenixframework.org/)
[![License](https://img.shields.io/badge/License-Private-red)]()

---

## Overview

KiteEdge is a **full-stack, analytics-only** platform that connects to your Zerodha Kite account and provides institutional-grade portfolio analytics — without ever executing trades. It combines an Elixir/Phoenix backend for real-time data streaming and API orchestration, a Python analytics engine for quantitative finance computations, and a React dashboard for interactive visualisation.

**Core Philosophy:**
- **Analytics only** — never executes trades on your behalf.
- **Mathematical rigor** — all predictions include confidence intervals, methodology citations, and mandatory disclaimers.
- **Reproducibility** — deterministic computation pipelines with transparent parameters.
- **Privacy-first** — self-hosted; your Kite tokens live only in Redis session cache (18h TTL) and are never persisted to disk.

---

## Features

### Portfolio Overview
- Real-time holdings with live P&L via Kite API
- Sector allocation, market-cap distribution, concentration risk (Herfindahl index)
- XIRR calculation and dividend tracking

### Technical Analysis (43+ Indicators)
- **Trend** — SMA, EMA, MACD, ADX, Ichimoku, Parabolic SAR, Aroon, TRIX, and more
- **Momentum** — RSI, Stochastic RSI, Williams %R, CCI, ROC, Ultimate Oscillator, KAMA
- **Volatility** — ATR, Bollinger Bands, Keltner Channel, Donchian Channel, Historical Volatility
- **Volume** — OBV, VWAP, CMF, MFI, ADI, Force Index
- Technical Summary Score \[-100, +100\] with Buy/Sell bands (TradingView-style)
- Multi-timeframe analysis (daily, weekly, monthly)

### Risk Analytics
- **Portfolio Ratios** — Sharpe, Sortino, Calmar, Information, Treynor, Beta, Alpha
- **Value at Risk** — Historical, Parametric (Gaussian), Conditional VaR / Expected Shortfall, Monte Carlo (10,000 GBM simulations)
- **Correlation Matrix** — Ledoit-Wolf shrinkage estimator heatmap
- **Stress Testing** — Historical scenarios (COVID-19, GFC, Demonetisation, Taper Tantrum) + custom scenarios
- **Drawdown Analysis** — Maximum drawdown depth, duration, and recovery time

### Forecasting
- **ARIMA/SARIMA** — Auto-fitted via statsmodels (AIC/BIC selection)
- **Facebook Prophet** — NSE trading calendar + weekly seasonality
- **Ensemble** — Inverse-MAE weighted average of both models
- **Validation** — Walk-forward backtesting with MAE, RMSE, MAPE, and directional accuracy

### Trade Analytics
- FIFO-matched trade history with realised P&L
- Win rate, profit factor, expectancy
- P&L calendar heatmap and equity curve with drawdown periods

### Suggestions & Alerts
- Signal screening ranked by composite confidence score
- Rebalancing recommendations (equal-weight or custom target)
- Price and percentage-change alerts via in-app notifications + email

### Reporting & Export
- QuantStats HTML tear sheet (monthly heatmaps, rolling metrics)
- Export to XLSX, CSV, PDF — all with mandatory disclaimers
- OData v4 feed for Power BI / Excel dynamic refresh
- Power BI streaming push endpoint

---

## Architecture

KiteEdge is built as a **polyglot microservice platform** inside an Elixir umbrella monorepo.

```
KiteEdge/
├── apps/
│   ├── kite_edge/          # Core domain — persistence, Kite API client, sync
│   ├── kite_edge_web/      # Phoenix REST gateway + WebSocket channels
│   ├── market_data/        # KiteTicker WebSocket → Kafka publisher
│   └── notification/       # Kafka → Broadway → alerts + email
├── analytics_engine/       # Python FastAPI microservice
├── data_pipeline/          # Python Kafka consumers (candles, indicators, alerts)
├── dashboard/              # React SPA (Vite + TypeScript)
├── config/                 # Shared Elixir configuration
├── infra/                  # Docker, Grafana, K6, Kafka, Nginx, monitoring
├── docs/                   # API reference, developer guide, user guide
└── specs/                  # Functional specifications
```

### Services

| Service | Tech | Role | Port |
|---|---|---|---|
| **Gateway** | Elixir / Phoenix | OAuth, REST API, WebSocket, proxy to analytics | `4000` |
| **Market Data** | Elixir / OTP | KiteTicker WebSocket → Kafka + Redis LTP cache | internal |
| **Analytics Engine** | Python / FastAPI | Indicators, risk metrics, VaR, forecasts, reports | `8001` |
| **Data Pipeline** | Python / Kafka | Candle aggregation, indicator computation, alert eval | internal |
| **Dashboard** | React / TypeScript | 8-page SPA with charts and real-time updates | `5173` |
| **Notification** | Elixir / Broadway | Kafka alert consumer → PubSub + email | internal |

### Data Flow

```
Browser (React :5173)
  ↕ REST + WebSocket (Phoenix Channels)
Phoenix Gateway (:4000)
  ├─→ Zerodha Kite API v5.1 (via Finch/Tesla)
  ├─→ PostgreSQL 16 (holdings, orders, trades, instruments)
  ├─→ Redis 7 (sessions, LTP cache, rate limiter)
  └─→ Analytics Engine (:8001)
Market Data Service
  └─→ KiteTicker WebSocket → Kafka (market.ticks)
Data Pipeline (Kafka consumers)
  ├─→ Candle Builder (1m, 5m, 15m, 1h, daily)
  ├─→ Indicator Updater (43 indicators via ta library)
  ├─→ Alert Evaluator (rule engine)
  └─→ Forecast Scheduler (nightly ARIMA + Prophet)
Notification Service (Broadway)
  └─→ alerts.fired topic → PubSub + email (Swoosh)
```

### WebSocket Channels

| Channel | Purpose |
|---|---|
| `portfolio:live` | Real-time holdings updates |
| `ticks:*` | Market data tick stream |
| `alerts:user` | Alert notifications |
| `analytics:progress` | Computation progress events |

---

## Tech Stack

| Layer | Technologies |
|---|---|
| **Backend** | Elixir 1.16, OTP 27, Phoenix 1.7, Ecto 3.11, Oban 2.17 |
| **Analytics** | Python 3.11+, FastAPI, pandas, NumPy, SciPy, scikit-learn, statsmodels, Prophet, QuantStats, ta |
| **Frontend** | React 18, TypeScript 5.3, Vite 5, Zustand, TanStack Query, Tailwind CSS, Recharts, Lightweight Charts |
| **Database** | PostgreSQL 16 |
| **Cache / Sessions** | Redis 7 |
| **Streaming** | Apache Kafka 3.7 (KRaft mode), Broadway |
| **Observability** | Prometheus, Grafana, Telemetry, Sentry |
| **HTTP** | Finch, Tesla, Axios, httpx |
| **Email** | Swoosh + gen_smtp |
| **Infrastructure** | Docker Compose, Nginx, K6 (load testing) |

---

## Prerequisites

- **Elixir** >= 1.16 and **Erlang/OTP** >= 27
- **Python** >= 3.11
- **Node.js** >= 18 and **npm**
- **Docker** and **Docker Compose** v2
- **Zerodha Kite Connect** API credentials (`api_key` and `api_secret`)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/atavisticrystal6888/Kite-edge.git
cd Kite-edge
```

### 2. Environment setup

Copy the example env file and fill in your credentials:

```bash
cp .env.example .env
```

Key variables to configure:

```env
POSTGRES_USER=kiteedge
POSTGRES_PASSWORD=<your-password>
POSTGRES_DB=kiteedge_dev

REDIS_URL=redis://localhost:6379

KITE_API_KEY=<your-kite-api-key>
KITE_API_SECRET=<your-kite-api-secret>

SECRET_KEY_BASE=<generate-with-mix-phx-gen-secret>
PHX_HOST=localhost
PHX_PORT=4000

ANALYTICS_ENGINE_URL=http://analytics-engine:8001
CORS_ORIGINS=http://localhost:5173
```

### 3. Start with Docker Compose (recommended)

```bash
docker compose up -d
```

This starts all services: PostgreSQL, Redis, Kafka, Gateway, Market Data, Analytics Engine, Data Pipeline, Dashboard, Notification, Prometheus, and Grafana.

| Service | URL |
|---|---|
| Dashboard | http://localhost:5173 |
| Phoenix API | http://localhost:4000 |
| Analytics Engine | http://localhost:8001 |
| Grafana | http://localhost:3001 |
| Prometheus | http://localhost:9090 |

### 4. Manual / Development setup

**Elixir backend:**

```bash
mix deps.get
mix ecto.setup       # creates DB, runs migrations, seeds
mix phx.server       # starts Phoenix on :4000
```

**Analytics Engine:**

```bash
cd analytics_engine
pip install -e ".[dev]"
uvicorn api.main:app --host 0.0.0.0 --port 8001 --reload
```

**Dashboard:**

```bash
cd dashboard
npm install
npm run dev          # starts Vite dev server on :5173
```

---

## API Reference

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/auth/kite/login` | Redirect to Kite OAuth |
| `GET` | `/auth/kite/callback` | OAuth callback, set session |
| `DELETE` | `/auth/kite/logout` | Clear session |

### Portfolio
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/portfolio/holdings` | Current holdings with P&L |
| `GET` | `/api/v1/portfolio/summary` | Summary with sector allocation, XIRR |

### Technical Analysis
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/analytics/technical/:symbol` | Full 43-indicator suite |
| `GET` | `/api/v1/analytics/technical/:symbol/summary` | Summary score \[-100, +100\] |

### Risk Analytics
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/analytics/risk/portfolio` | Sharpe, Sortino, Calmar, drawdown |
| `POST` | `/api/v1/analytics/risk/var` | VaR (Historical, Parametric, Monte Carlo) |
| `POST` | `/api/v1/analytics/risk/montecarlo` | Forward portfolio simulation |
| `POST` | `/api/v1/analytics/risk/stress-test` | Scenario-based stress testing |
| `POST` | `/api/v1/analytics/risk/correlation` | Correlation matrix |

### Forecasting
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/analytics/forecast/:symbol` | ARIMA + Prophet ensemble |
| `POST` | `/api/v1/analytics/forecast/portfolio` | Portfolio-level weighted forecast |

### Reports
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/reports/tearsheet` | QuantStats HTML tear sheet |
| `POST` | `/api/v1/reports/export` | XLSX / CSV / PDF export |
| `GET` | `/api/v1/reports/odata/holdings` | OData v4 entity set |

### Health & Metrics
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Liveness check (DB + Redis + analytics) |
| `GET` | `/metrics` | Prometheus-compatible metrics |

> Full API documentation: [`docs/api_and_methodology.md`](docs/api_and_methodology.md)

---

## Testing

```bash
# Elixir tests
mix test

# Analytics Engine tests
cd analytics_engine
pytest

# Dashboard tests
cd dashboard
npm test
```

---

## Project Structure

```
apps/kite_edge/            Elixir core — Ecto schemas, Kite API client, repo, sync logic
apps/kite_edge_web/        Phoenix controllers, channels, plugs, router, OpenAPI spec
apps/market_data/          KiteTicker binary WebSocket decoder, Kafka producer
apps/notification/         Broadway Kafka consumer, email dispatch via Swoosh
analytics_engine/          FastAPI — indicators, risk, VaR, forecasts, reports, trades
data_pipeline/             Kafka consumers — candle builder, indicator updater, alerts
dashboard/                 React SPA — pages, components, hooks, stores, services
config/                    Elixir config for dev/test/prod/runtime
infra/                     Docker, Grafana dashboards, K6 load tests, Kafka config, Nginx
docs/                      API reference, developer guide, user guide
specs/                     Functional specifications and requirements
```

---

## Documentation

- [API & Methodology Reference](docs/api_and_methodology.md) — endpoint specs, mathematical formulas, indicator definitions
- [Developer Guide](docs/DEVELOPER_GUIDE.md) — setup, code conventions, contribution workflow
- [User Guide](docs/USER_GUIDE_COMPLETE.md) — feature walkthroughs, UI screenshots, FAQ

---

## Observability

- **Prometheus** scrapes metrics from all services at `/metrics`
- **Grafana** dashboards (pre-configured) at http://localhost:3001
- **Sentry** integration for error tracking (configure `SENTRY_DSN`)
- **Telemetry** events across the Elixir umbrella for request latency, DB query time, Kafka throughput

---

## Disclaimer

> KiteEdge is an **analytics and informational tool only**. It does **not** execute trades, provide investment advice, or guarantee returns. All forecasts include confidence intervals and are presented for educational/analytical purposes. Past performance does not indicate future results. Users are solely responsible for their investment decisions. Please consult a SEBI-registered investment advisor before acting on any data presented by this platform.

---

## License

This is a private project. All rights reserved.

---

## Author

**Dhruv Singhal** — [GitHub](https://github.com/DH40187606_wipro)
