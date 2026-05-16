# KiteEdge – User Guide (T200)

> **Note:** This is the quick-start summary. For the full comprehensive guide, see [USER_GUIDE_COMPLETE.md](USER_GUIDE_COMPLETE.md).

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 20+
- Elixir 1.17+ / OTP 27
- Python 3.12+
- Zerodha Kite Connect API key

### 1 Clone & configure
```bash
git clone <repo-url> && cd KiteEdge
cp .env.example .env
# Edit .env with your Kite API key/secret, DB credentials, etc.
```

### 2 Start infrastructure
```bash
docker-compose up -d   # PostgreSQL, Redis, Kafka, Zookeeper
```

### 3 Backend (Elixir)
```bash
mix deps.get
mix ecto.setup          # create + migrate + seed
iex -S mix phx.server   # starts on :4000
```

### 4 Analytics Engine (Python)
```bash
cd analytics_engine
python -m venv .venv && .venv/Scripts/activate  # Windows
pip install -e ".[dev]"
uvicorn analytics_engine.api.main:app --port 8000
```

### 5 Dashboard (React)
```bash
cd dashboard
npm install
npm run dev              # starts on :5173
```

### 6 Open in browser
Navigate to http://localhost:5173 → click **Sign in with Kite** → authorise on Kite → redirected back with live portfolio.

---

## Features

### Portfolio Overview
- Real-time holdings with live prices via WebSocket
- Sector allocation donut chart, market-cap distribution bar chart
- Concentration risk badges, XIRR returns, dividend summary

### Technical Analysis
- Search any NSE/BSE instrument
- 30+ indicators across trend, momentum, volatility, volume categories
- Summary gauge score [-100, +100] with Buy/Sell bands
- Multi-timeframe comparison (1D, 1W, 1M)
- Candlestick chart with indicator overlays (lightweight-charts)

### Risk Dashboard
- Portfolio risk ratios: Sharpe, Sortino, Calmar, Max Drawdown
- VaR (Historical, Parametric, Monte Carlo) with histogram
- Correlation heat-map with Ledoit-Wolf shrinkage
- Drawdown chart with recovery periods
- Monte Carlo forward simulation fan chart
- Stress testing: COVID-19, GFC, Demonetisation, Taper Tantrum

### Predictions
- ARIMA + Prophet ensemble forecasts with confidence intervals
- Signal detection: MA crossover, RSI divergence, Bollinger squeeze
- Model accuracy metrics (MAE, RMSE, MAPE, directional accuracy)
- Disclaimer: "Forecasts are statistical projections, not investment advice"

### Trade Journal
- FIFO-matched trade history with P&L
- Win rate, expectancy, profit factor metrics
- P&L calendar heat-map
- Equity curve chart

### Suggestions & Alerts
- Ranked signal cards with confidence scores
- Rebalance calculator (equal-weight / custom)
- Diversification analysis with improvement suggestions
- Alert rules: price above/below, % change
- Watchlist management
- In-app + email notification channels

### Reports
- QuantStats HTML tear sheet
- Export: XLSX, CSV, PDF (with disclaimers)
- OData v4 feed for Power BI / Excel integration
- Power BI streaming push endpoint

### Settings
- Indicator parameter profiles (persist per-user)
- Notification channel preferences
- Watchlist CRUD

---

## Architecture

```
Browser ←WS→ Phoenix Channels ←PubSub→ KiteTicker
Browser ←HTTP→ Phoenix API ←Finch→ Analytics Engine (FastAPI)
                              ←Ecto→ PostgreSQL
                              ←Redis→ Session + Cache
Kafka ← tick_publisher → candles.*, alerts.fired
```

## Security
- Kite tokens: Redis-only, 18 h TTL, never persisted to DB/logs
- Rate limiter: 3 req/sec to Kite API
- Security headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options
- Sensitive log redaction for access_token, api_secret fields
