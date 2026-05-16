# Mega-Prompt: Build a Zerodha Kite Portfolio Intelligence Platform

## Context & Role

You are a senior quantitative engineer and full-stack architect tasked with building **KiteEdge** — a production-grade portfolio intelligence platform that connects to Zerodha Kite to perform mathematical analysis, complex quantitative analysis, predictions, trade suggestions, and deep portfolio analytics. You will follow **Spec-Driven Development (SDD)** methodology using the GitHub Spec Kit workflow. Specifications are the source of truth; code serves specifications.

**CRITICAL DISCLAIMER**: This platform is a personal analytical tool. It does NOT execute trades automatically. All "suggestions" are informational signals, not investment advice. The system must display this disclaimer prominently on every page.

You are working inside a monorepo. The project will be built across **7 SDD phases**, each producing specific artifacts before moving to the next. Do NOT skip phases. Do NOT write implementation code until Phase 5.

---

## Phase 0: Constitution — Governing Principles

**Command**: `/speckit.constitution`

Create `specs/kiteedge/constitution.md` with the following immutable principles:

### Required Articles

**Article I: Kite API as the Single Source of Truth**
- All portfolio data (holdings, positions, orders, margins) is fetched exclusively from Zerodha Kite Connect API v3.
- Historical OHLCV data is fetched via Kite Connect's historical data API and cached locally in PostgreSQL.
- The system never stores Kite API credentials in code or database — session tokens are ephemeral, API keys are environment variables.
- Every Kite API call is rate-limited (3 requests/second), retried with exponential backoff, and logged.
- If Kite API is unavailable, the system operates in "offline mode" using cached data with a visible staleness indicator.

**Article II: Mathematical Rigor & Reproducibility**
- Every computation (indicator, metric, prediction, risk score) must be reproducible given the same input data.
- Statistical methods must specify their assumptions. Predictions must include confidence intervals, not point estimates.
- All financial formulas use the exact definitions from academic literature (e.g., Sharpe ratio uses excess returns over risk-free rate, not raw returns).
- Random processes (Monte Carlo, stochastic models) must accept a seed parameter for reproducibility.
- Results must be validated against known reference implementations (scipy, QuantStats, ta library) with < 0.01% deviation.

**Article III: Test-First Development**
- TDD is non-negotiable: Red → Green → Refactor.
- Financial computations require property-based testing (known inputs → known outputs from reference sources like NSE website, Investopedia examples).
- Integration tests must use real PostgreSQL via Docker, not mocks.
- Prediction models require backtesting on historical data with walk-forward validation.
- Every indicator must be tested against the `ta` Python library reference implementation.

**Article IV: Real-Time & Historical Duality**
- The system operates in two modes simultaneously:
  - **Historical mode**: Batch analysis on stored OHLCV + trade data (PostgreSQL).
  - **Real-time mode**: Live tick processing via Kite WebSocket (KiteTicker) for dashboards and alerts.
- Historical computations and real-time computations must produce identical results for the same data window.
- Real-time dashboards update via WebSocket push (Phoenix Channels), never polling.

**Article V: Performance & Scalability**
- Technical indicator computation: < 500ms for 43 indicators on 5 years of daily data per instrument.
- Portfolio risk analysis (VaR, Monte Carlo 10,000 simulations): < 10 seconds for 50-stock portfolio.
- Dashboard page load: < 2 seconds with pre-computed analytics.
- Historical data fetch + cache: 5 years of daily OHLCV for 500 instruments in < 30 minutes (initial load).
- Real-time tick processing: handle 100 instruments at full tick rate without dropping data.

**Article VI: Simplicity & YAGNI**
- Start simple: rule-based signals before ML, daily timeframe before intraday.
- No automated trade execution in v1 — this is an analytics platform only.
- No options analytics in v1 (complex; dedicated phase later).
- Maximum 6 services for v1. Additional services require justification.
- Use established libraries (`ta`, `quantstats`, `scipy`, `statsmodels`, `prophet`) — don't reimplement what exists.

**Article VII: Security & Compliance**
- Kite API secret and access tokens are NEVER persisted to database or logs.
- All API communication with Kite uses HTTPS.
- Session tokens expire daily (Kite enforces this); the system handles re-authentication gracefully.
- No sensitive portfolio data is transmitted to third-party services.
- All data stays local (self-hosted). No cloud analytics services for portfolio data.

**Article VIII: Observability**
- Structured JSON logging on every service.
- Health check endpoints per service.
- Kite API call metrics: success rate, latency, rate limit headroom.
- Computation metrics: time per indicator, time per analysis, cache hit rates.
- Data freshness indicators on every dashboard component.

### Governance
- Constitution supersedes all other documents.
- Amendments require written rationale and impact analysis.
- All PRs include constitution compliance checklist.

---

## Phase 1: Specification — What & Why (Not How)

**Command**: `/speckit.specify`

Create `specs/kiteedge/spec.md`. Focus on WHAT and WHY. No technology choices.

### Product Vision

KiteEdge is a self-hosted portfolio intelligence platform for Zerodha Kite users. It transforms raw brokerage data into actionable insights through mathematical analysis, risk quantification, predictive modeling, and trade performance analytics. It answers the questions every serious investor asks but Kite's default interface doesn't answer:

- *"What is my portfolio's true risk-adjusted return?"*
- *"Which of my holdings are showing bearish divergence right now?"*
- *"What's my Value at Risk for tomorrow?"*
- *"How correlated are my holdings — am I actually diversified?"*
- *"Which sectors am I overweight in relative to NIFTY 50?"*
- *"What would happen to my portfolio in a 2020-style crash?"*
- *"Are my recent trades improving or degrading my Sharpe ratio?"*

### Target Personas

1. **Active Retail Investor (Primary)** — Holds 15-50 stocks, makes 5-20 trades/month, wants data-driven insights without building spreadsheets manually.
2. **Swing Trader** — Holds positions for days to weeks, needs technical analysis signals, pattern recognition, and entry/exit suggestions.
3. **Long-Term Investor** — Holds positions for months/years, wants portfolio health monitoring, rebalancing suggestions, and risk alerts.
4. **Aspiring Quant** — Wants to learn quantitative analysis by seeing real computations on their own portfolio.

### User Stories — Prioritized & Independently Testable

**P1 — Portfolio Overview & Holdings Analysis (MVP)**
- US1: User connects their Kite account (OAuth login via Kite Connect) and sees all current holdings with real-time P&L.
- US2: User views portfolio composition: sector allocation pie chart, market cap distribution, top holdings by weight, concentration risk (Herfindahl index).
- US3: User sees per-holding analysis: current price, average buy price, P&L (absolute + %), holding period, annualized return, XIRR.
- US4: User views portfolio summary metrics: total invested, current value, total P&L, day's P&L, overall CAGR, XIRR.
- US5: User sees dividend tracking: received dividends per holding, dividend yield, total dividend income.

**P2 — Technical Analysis Engine**
- US6: User selects any instrument (from holdings or search) and views a comprehensive technical analysis dashboard with 43+ indicators organized by category:
  - **Trend**: SMA(20,50,200), EMA(12,26), MACD, ADX, Ichimoku Cloud, Parabolic SAR, Aroon, SuperTrend
  - **Momentum**: RSI(14), Stochastic RSI, Williams %R, CCI, ROC, Ultimate Oscillator, KAMA, TSI
  - **Volatility**: Bollinger Bands(20,2), ATR(14), Keltner Channel, Donchian Channel, historical volatility
  - **Volume**: OBV, VWAP, CMF, MFI, ADI, Force Index, Volume Profile
- US7: User views interactive candlestick charts with indicator overlays, support/resistance levels, and drawing tools.
- US8: System generates a **Technical Summary Score** per instrument: Strong Buy / Buy / Neutral / Sell / Strong Sell — based on consensus of all indicators (like TradingView's technical summary).
- US9: User configures custom indicator parameters (e.g., change RSI period from 14 to 21).
- US10: User views multi-timeframe analysis: daily, weekly, monthly indicators side-by-side.

**P3 — Risk Analytics & Portfolio Mathematics**
- US11: User views portfolio risk dashboard:
  - **Sharpe Ratio** (annualized, using RBI repo rate as risk-free rate)
  - **Sortino Ratio** (downside deviation only)
  - **Calmar Ratio** (return / max drawdown)
  - **Information Ratio** (vs NIFTY 50 benchmark)
  - **Beta** (vs NIFTY 50) and **Alpha** (Jensen's alpha)
  - **Treynor Ratio**
  - **Max Drawdown** (depth, duration, recovery time)
  - **Volatility** (annualized standard deviation, rolling 30/60/90 day)
- US12: User views **Value at Risk (VaR)** analysis:
  - Historical VaR (95%, 99% confidence)
  - Parametric VaR (variance-covariance method)
  - Conditional VaR / Expected Shortfall
  - Monte Carlo VaR (10,000 simulations)
  - Displayed as: "There is a 5% chance your portfolio loses more than ₹X,XX,XXX tomorrow"
- US13: User views **correlation matrix** heatmap of all holdings — identifying which stocks move together and which provide diversification.
- US14: User views **stress testing** / scenario analysis:
  - Historical scenarios: "What if March 2020 crash repeats?" "What if 2008 GFC repeats?"
  - Custom scenarios: "What if NIFTY drops 15%?" "What if IT sector drops 25%?"
  - Impact on portfolio value with per-holding breakdown.
- US15: User views **Monte Carlo simulation** of portfolio forward returns:
  - 1,000-10,000 simulated paths for 1 month / 3 months / 1 year
  - Probability distribution of terminal portfolio value
  - Probability of hitting target return / probability of drawdown exceeding X%

**P4 — Predictions & Forecasting**
- US16: User views **price forecast** for any instrument:
  - ARIMA/SARIMA model: next 5/10/30 days with confidence intervals
  - Facebook Prophet model: captures seasonality, holiday effects (NSE trading calendar)
  - Ensemble forecast: weighted average of models
  - Display: "RELIANCE predicted price in 30 days: ₹2,850-₹3,100 (80% CI)"
  - Disclaimer: "This is a statistical projection, not investment advice"
- US17: User views **trend prediction signals**:
  - Moving average crossover signals (Golden Cross / Death Cross)
  - MACD signal line crossovers
  - RSI overbought/oversold with divergence detection
  - Bollinger Band squeeze (low volatility → breakout prediction)
  - Volume-price divergence alerts
- US18: User views **portfolio return forecast**:
  - Expected portfolio return over 1/3/6/12 months
  - Based on historical returns + current momentum + mean reversion
  - Confidence intervals and probability distributions

**P5 — Trade Analysis & Performance**
- US19: User views complete **trade history** synced from Kite: all executed orders with timestamp, price, quantity, type, P&L per trade.
- US20: User views **trade performance metrics**:
  - Win rate (% of profitable trades)
  - Average win vs average loss (profit factor)
  - Expectancy per trade (average P&L)
  - Maximum consecutive wins/losses
  - Risk-reward ratio achieved vs planned
  - P&L by day of week, time of day, month (pattern detection)
  - Holding period analysis: average holding period for winners vs losers
- US21: User views **execution quality analysis**:
  - Slippage: difference between intended price and executed price
  - Market impact: price movement caused by own order (for larger orders)
  - Best execution analysis: could the trade have been executed at a better price within the day?
- US22: User views **rolling performance**: weekly/monthly P&L, cumulative returns chart, drawdown chart, rolling Sharpe ratio.

**P6 — Suggestions & Signals**
- US23: User views **daily screening signals** across their watchlist + holdings:
  - "RELIANCE: RSI crossed below 30 (oversold), MACD bullish crossover forming" → Potential Buy
  - "TCS: Price hit upper Bollinger Band, RSI > 70, volume declining" → Potential Sell
  - "HDFC BANK: Golden Cross (50 SMA crossed above 200 SMA)" → Bullish Signal
- US24: User views **portfolio rebalancing suggestions**:
  - Current allocation vs target allocation (user-defined or model: equal weight, market-cap weight, min-variance)
  - Specific trades needed to rebalance: "Buy 10 shares of X, Sell 5 shares of Y"
  - Tax-loss harvesting opportunities: holdings with unrealized losses that can be booked
- US25: User views **diversification analysis with suggestions**:
  - Sector concentration risk with "Add exposure to [sector]" suggestions
  - Correlation-based suggestions: "Your top 5 holdings have >0.8 correlation — consider adding [low-correlation stock]"
  - Market cap diversification: "85% large-cap, consider 10-15% mid-cap allocation"
- US26: User receives **alerts** (in-app + optional email):
  - SLA breach equivalent: "RELIANCE dropped 5% intraday — abnormal move"
  - Technical: "INFY RSI hit oversold zone"
  - Portfolio: "Your portfolio drawdown exceeded 10%"
  - Risk: "Your Value at Risk increased 50% this week"

**P7 — Reporting & Export**
- US27: User generates a **portfolio tear sheet** (HTML report exportable to PDF):
  - Performance summary, risk metrics, drawdown analysis, monthly returns heatmap
  - Sector allocation, holding period analysis, top contributors/detractors
  - Modeled after QuantStats HTML tear sheets
- US28: User exports any dashboard/analysis to:
  - Excel (XLSX with formatted tables and charts)
  - CSV (raw data)
  - PDF (formatted report)
  - Power BI (REST endpoint / OData for live dashboards)
- US29: User views **monthly/quarterly performance report** automatically generated:
  - Period return, benchmark comparison, attribution analysis, risk evolution

### Edge Cases (must be addressed)
- What happens when a stock in holdings gets delisted or undergoes a name change?
- How are corporate actions handled (stock splits, bonuses, rights issues) in return calculations?
- How is XIRR computed for holdings with multiple buy transactions at different prices?
- What happens during market holidays — does the system show stale data or explicit "market closed" state?
- How are holdings in different exchanges (NSE vs BSE) handled for the same company?
- What happens when Kite API session expires mid-day?
- How are mutual fund holdings (via Coin) handled differently from direct equity?
- How are intraday positions (closed same day) tracked vs delivery positions?
- What about F&O positions — are they in scope or explicitly excluded for v1?

### Functional Requirements (FR-001 through FR-070+)
Write 70+ functional requirements covering:

**Kite Integration (FR-001 to FR-010)**
- OAuth authentication flow with Kite Connect
- Fetch and cache: holdings, positions, orders, trades, instruments, historical OHLCV, margins, profile
- WebSocket subscription for real-time LTP/OHLCV on holdings + watchlist
- Automatic session refresh handling (daily re-auth notification)
- Rate limiting (3 req/sec) with queue and backoff
- Instrument master sync (daily refresh of tradeable instruments)
- NSE/BSE trading calendar awareness (holidays, market hours)

**Technical Analysis (FR-011 to FR-025)**
- 43+ indicators from ta library categories: Volume (9), Volatility (5), Trend (15), Momentum (11), Others (3)
- Configurable indicator parameters (period, deviation, etc.)
- Multi-timeframe support: 1min, 5min, 15min, 30min, 1hr, daily, weekly, monthly
- Technical Summary Score algorithm (weighted consensus of all indicators)
- Support/resistance level detection (pivot points, Fibonacci retracement)
- Candlestick pattern recognition (Doji, Hammer, Engulfing, Morning Star, etc. — top 20 patterns)
- Chart annotations: trend lines, channels, Fibonacci levels

**Risk Analytics (FR-026 to FR-042)**
- Sharpe, Sortino, Calmar, Information, Treynor ratios (annualized)
- Jensen's Alpha, Beta (vs NIFTY 50, NIFTY 500, sectoral indices)
- Rolling metrics (30, 60, 90, 180, 365 day windows)
- Value at Risk: Historical, Parametric, Monte Carlo (configurable confidence: 90%, 95%, 99%)
- Conditional VaR / Expected Shortfall
- Maximum Drawdown (depth, duration, recovery)
- Correlation matrix (Pearson, Spearman, rolling)
- Covariance matrix estimation (sample, Ledoit-Wolf shrinkage)
- Portfolio variance decomposition (marginal risk contribution per holding)
- Stress testing with historical and custom scenarios
- Monte Carlo forward simulation (geometric Brownian motion, correlated multi-asset)

**Predictions (FR-043 to FR-052)**
- ARIMA/SARIMA model fitting and forecasting with AIC/BIC model selection
- Prophet model with NSE calendar holidays and weekly seasonality
- Ensemble forecasting (weighted average of multiple models)
- Confidence interval estimation (80%, 95%)
- Forecast accuracy tracking: MAPE, RMSE, MAE on rolling out-of-sample tests
- Moving average crossover signal generation
- Divergence detection (price vs RSI, price vs OBV, price vs MACD)
- Bollinger Band squeeze detection (volatility contraction)
- Volume-price trend divergences

**Trade Analysis (FR-053 to FR-062)**
- Trade history sync from Kite (all executed orders with fills)
- Per-trade P&L computation (FIFO method for cost basis)
- Win rate, profit factor, expectancy, consecutive W/L
- Holding period analysis (winners vs losers)
- P&L patterns by time (day of week, month, hour)
- Execution quality: slippage computation
- Rolling equity curve, drawdown curve
- Benchmark comparison (trade returns vs buy-and-hold NIFTY)

**Suggestions (FR-063 to FR-070)**
- Daily screening engine: scan technical indicators across holdings + watchlist
- Signal generation: buy/sell/hold with confidence and contributing factors
- Portfolio rebalancing calculator (target vs actual allocation)
- Tax-loss harvesting opportunity detection
- Diversification analysis and improvement suggestions
- Alert engine: configurable thresholds for price, technical, risk alerts
- Watchlist management with custom instrument lists

### Non-Functional Requirements
- NFR-001: Technical indicator computation < 500ms per instrument (5 years daily)
- NFR-002: Full portfolio risk analysis < 10s for 50 holdings
- NFR-003: Monte Carlo (10K sims, 50 assets) < 30s
- NFR-004: Dashboard load < 2s (pre-computed analytics)
- NFR-005: Historical data backfill (500 instruments × 5 years) < 30 minutes
- NFR-006: Real-time tick processing: 100 instruments without drops
- NFR-007: Data freshness: LTP within 2 seconds of market tick
- NFR-008: System operates in offline mode with cached data when Kite API is down
- NFR-009: All computations reproducible given identical input data and seed
- NFR-010: XIRR computation accuracy matches popular financial calculators within 0.01%

### Key Entities
- Instrument, InstrumentMaster, Exchange, TradingCalendar
- Holding, Position, Order, Trade, Fill
- OHLCVCandle, TickData, RealTimeQuote
- TechnicalIndicatorResult, TechnicalSummaryScore, CandlestickPattern
- PortfolioSnapshot, PortfolioMetric, RiskMetric, CorrelationMatrix
- VaRResult, MonteCarloSimulation, StressTestScenario, StressTestResult
- ForecastModel, ForecastResult, ForecastAccuracyMetric
- TradePerformanceMetric, ExecutionQualityMetric
- Signal, Alert, AlertRule, Watchlist
- RebalanceSuggestion, DiversificationAnalysis
- Report, ExportJob, TearSheet
- UserSession, KiteToken (ephemeral — NOT persisted)

### Success Criteria
- SC-001: Holdings appear within 5 seconds of Kite login.
- SC-002: All 43 technical indicators compute correctly (validated against ta library).
- SC-003: Sharpe/Sortino/VaR match QuantStats output within 0.1%.
- SC-004: ARIMA forecast MAPE < 5% on 30-day predictions for NIFTY 50 components.
- SC-005: Portfolio tear sheet generates in < 5 seconds.
- SC-006: Real-time P&L updates within 2 seconds of market tick.
- SC-007: User finds 3+ actionable insights within 5 minutes of first login.

---

## Phase 2: Implementation Plan — Technical Architecture

**Command**: `/speckit.plan`

Create `specs/kiteedge/plan.md` and all supporting documents.

### Technical Context

```
Language/Versions:
  - Backend API / Real-time: Elixir 1.16+ / OTP 26+ / Phoenix 1.7+
  - Analytics Engine: Python 3.12+
  - Dashboard Frontend: React.js 18+ with TypeScript
  - Data Pipeline Workers: Python 3.12+

Primary Dependencies:
  Elixir/Phoenix:
    - Phoenix LiveView + Channels (real-time dashboards)
    - Ecto (PostgreSQL ORM)
    - Broadway (Kafka consumer)
    - Jason, Tesla (HTTP client for Kite API)
    - Oban (background job scheduling)
    - Cachex (in-memory caching for hot data)

  Python Analytics:
    - kiteconnect v5.1.0 (official Zerodha Python client)
    - ta v0.11.0 (43 technical indicators: Volume, Volatility, Trend, Momentum)
    - quantstats v0.0.81 (portfolio analytics: Sharpe, Sortino, VaR, Monte Carlo, drawdowns, tear sheets)
    - scipy + numpy (statistical computations, optimization)
    - statsmodels (ARIMA/SARIMA, time series decomposition)
    - prophet (Facebook Prophet for seasonality-aware forecasting)
    - pandas (data manipulation, XIRR computation)
    - scikit-learn (correlation analysis, covariance estimation, Ledoit-Wolf shrinkage)
    - openpyxl (Excel export), matplotlib + plotly (chart generation for reports)
    - FastAPI (analytics REST API)
    - kafka-python (event consumption)

  React:
    - lightweight-charts (TradingView open-source charts for candlestick/indicators)
    - Recharts (portfolio analytics charts)
    - TanStack Query (data fetching + caching)
    - shadcn/ui (component library)
    - React Router, zustand (state management)

  Infrastructure:
    - Apache Kafka 3.7+ (real-time tick streaming, analytics events)
    - PostgreSQL 16+ (historical data, analytics results, configurations)
    - Redis 7+ (real-time LTP cache, session cache, rate limiters)
    - Docker Compose (local dev)
    - AWS: ECS + RDS + ElastiCache + MSK (production)

Storage Strategy:
  - PostgreSQL: OHLCV historical data (partitioned by instrument + month), holdings snapshots,
    trade history, analytics results, configurations, watchlists, alerts
  - Kafka: Real-time tick events, analytics computation triggers, alert events
  - Redis: Live LTP cache (per instrument, 2s TTL), Kite session tokens (daily TTL),
    rate limiter counters, pre-computed indicator cache

Performance:
  - Indicator computation: < 500ms per instrument
  - Portfolio risk: < 10s for 50 holdings
  - Monte Carlo (10K × 50 assets): < 30s
  - Dashboard: < 2s load

Scale (v1):
  - 1 user (personal portfolio tool)
  - Up to 100 instruments tracked
  - 5 years historical daily data cached
  - Real-time ticks for holdings + watchlist (up to 100 instruments)
```

### Architecture — Service Breakdown

**1. Gateway API (Elixir/Phoenix)**
- Kite OAuth flow: redirect to Kite login → receive request_token → exchange for access_token
- Proxies all Kite API calls with rate limiting (3 req/sec), retry, circuit breaker
- Serves REST API for dashboard (holdings, positions, orders, portfolio metrics)
- Phoenix Channels for real-time push: live P&L, tick data, alert notifications
- Oban jobs: scheduled data sync (holdings every 5 min during market hours, instruments daily, historical data nightly)
- Stores access_token in Redis only (ephemeral, never database)

**2. Market Data Service (Elixir + KiteTicker via NIF/Port)**
- Manages WebSocket connection to Kite for real-time tick data
- Subscribes to instruments in holdings + watchlist
- Publishes normalized tick events to Kafka topic `market.ticks`
- Maintains Redis LTP cache (updated every tick, 2s TTL for freshness indicator)
- Handles reconnection, subscription management, mode switching (LTP/Quote/Full)
- Manages Kite instrument master (daily sync of ~100K+ instruments)

**3. Analytics Engine (Python/FastAPI)**
- **Technical Analysis Module**: Wraps `ta` library for all 43 indicators + custom composites
  - Input: OHLCV DataFrame. Output: indicator values + signal interpretation
  - Technical Summary Score: weighted consensus (trend 35%, momentum 30%, volatility 20%, volume 15%)
  - Candlestick pattern recognition
  - Support/resistance via pivot points + Fibonacci
- **Risk Analytics Module**: Wraps `quantstats` + custom implementations
  - Portfolio metrics: Sharpe, Sortino, Calmar, Information, Treynor, Alpha, Beta
  - VaR engine: Historical, Parametric, Monte Carlo
  - Correlation matrix, covariance estimation (Ledoit-Wolf)
  - Stress testing engine: historical scenarios + custom factor shocks
  - Monte Carlo portfolio simulation (multivariate geometric Brownian motion)
- **Forecasting Module**: `statsmodels` + `prophet`
  - ARIMA auto-fitting (auto_arima via pmdarima or manual grid search)
  - Prophet with NSE calendar, weekly effects
  - Ensemble: weighted average based on rolling backtesting accuracy
  - Signal generation: crossover detection, divergence analysis, squeeze detection
- **Trade Analysis Module**: Custom computations
  - Trade-level P&L (FIFO cost basis matching)
  - Performance metrics: win rate, profit factor, expectancy, consecutive streaks
  - Execution quality: slippage computation, time-based P&L patterns
- **Reporting Module**: `quantstats` tear sheets + `openpyxl` + `matplotlib`
  - HTML tear sheet generation
  - Excel report generation with formatted sheets
  - CSV bulk export
- Exposes REST API consumed by Gateway API / Dashboard

**4. Data Pipeline (Python Kafka consumers)**
- `ticks-to-ohlcv`: Aggregates real-time ticks from Kafka into OHLCV candles (1min, 5min, 15min)
- `indicator-computer`: On new candle close, recomputes affected indicators → caches results
- `risk-recomputer`: On portfolio change or daily schedule, recomputes risk metrics
- `alert-evaluator`: On new tick/candle, evaluates alert rules → publishes alerts to Kafka
- `forecast-scheduler`: Nightly batch: retrain models, generate next-day forecasts

**5. Dashboard (React.js + TypeScript)**
- **Portfolio Overview**: Holdings table with P&L, sector allocation charts, portfolio summary cards
- **Instrument Analysis**: Candlestick chart (lightweight-charts), indicator panels, technical summary gauge, multi-timeframe view
- **Risk Dashboard**: Risk metric cards, VaR visualization (histogram + tail), correlation heatmap, drawdown chart, Monte Carlo fan chart
- **Predictions**: Forecast charts with confidence bands, signal list with explanations, model accuracy metrics
- **Trade Journal**: Trade history table with filters, performance metrics dashboard, equity curve, P&L calendar heatmap
- **Suggestions**: Signal feed (buy/sell/alert cards with rationale), rebalancing calculator, diversification radar chart
- **Reports**: Tear sheet viewer, export center (Excel/CSV/PDF), Power BI connection guide
- **Settings**: Watchlist management, alert configuration, indicator parameter customization, benchmark selection
- Real-time updates via Phoenix Channels (P&L, ticks, alerts)

**6. Notification Service (Elixir/Broadway Kafka consumer)**
- Consumes alert events from Kafka
- In-app notifications via Phoenix PubSub → Channels → dashboard toast
- Optional email alerts (configurable via settings)
- Alert history log with read/unread status

### Supporting Documents to Generate

**`data-model.md`**:
- All tables with columns, types, constraints
- OHLCV partitioning strategy (by instrument_id, range by date — monthly partitions)
- Kafka topic schemas: `market.ticks`, `candles.{timeframe}`, `analytics.triggers`, `alerts.fired`
- Redis key patterns: `ltp:{instrument_token}`, `session:{user_id}`, `cache:indicators:{instrument}:{timeframe}`, `ratelimit:kite:{endpoint}`
- Index strategy for OHLCV queries (instrument_id + datetime range)
- Materialized views for portfolio snapshots and aggregated metrics

**`contracts/gateway-api.md`** — OpenAPI 3.1:
- `GET /api/v1/portfolio/holdings` — Current holdings with real-time P&L
- `GET /api/v1/portfolio/positions` — Day positions
- `GET /api/v1/portfolio/summary` — Aggregate metrics
- `GET /api/v1/portfolio/history` — Daily portfolio value time series
- `GET /api/v1/instruments/{symbol}/ohlcv` — Historical candles
- `GET /api/v1/instruments/{symbol}/quote` — Real-time quote
- `GET /api/v1/instruments/search` — Instrument search
- `GET /api/v1/trades` — Trade history

**`contracts/analytics-api.md`** — OpenAPI 3.1:
- `POST /api/v1/analytics/technical/{symbol}` — Full technical analysis (all indicators)
- `GET /api/v1/analytics/technical/{symbol}/summary` — Technical Summary Score
- `POST /api/v1/analytics/risk/portfolio` — Portfolio risk metrics
- `POST /api/v1/analytics/risk/var` — Value at Risk computation
- `POST /api/v1/analytics/risk/montecarlo` — Monte Carlo simulation
- `POST /api/v1/analytics/risk/stress-test` — Stress test scenarios
- `POST /api/v1/analytics/risk/correlation` — Correlation matrix
- `POST /api/v1/analytics/forecast/{symbol}` — Price forecast
- `POST /api/v1/analytics/forecast/portfolio` — Portfolio return forecast
- `GET /api/v1/analytics/trades/performance` — Trade performance metrics
- `GET /api/v1/analytics/signals` — Current active signals
- `POST /api/v1/analytics/rebalance` — Rebalancing suggestions
- `POST /api/v1/reports/tearsheet` — Generate portfolio tear sheet
- `POST /api/v1/reports/export` — Generate export (Excel/CSV)

**`contracts/websocket-api.md`**:
- Channel: `portfolio:live` — real-time P&L updates per holding
- Channel: `ticks:{instrument_token}` — live tick data for charts
- Channel: `alerts:user` — alert notifications
- Channel: `analytics:progress` — long-running computation progress

**`research.md`**:
- Kite Connect API rate limits and optimal batching strategies
- Kite historical data API: interval limits (minute data only 60 days, daily data 2000 days max per request)
- Technical Summary Score: weighting methodology comparison (TradingView-style vs custom)
- VaR methods comparison: Historical vs Parametric vs Monte Carlo (accuracy, speed, assumptions)
- Covariance estimation: sample vs Ledoit-Wolf vs shrinkage (impact on portfolio optimization)
- Time series forecasting for stocks: ARIMA vs Prophet vs LSTM (accuracy, compute, complexity tradeoffs)
- Candlestick pattern recognition: rule-based vs TA-Lib vs custom (accuracy benchmarks)
- NSE trading calendar: holidays, muhurat trading, special sessions — data sources
- XIRR computation: Newton-Raphson method, edge cases (multiple buys, partial sells, dividends)
- Indian market specifics: T+1 settlement, corporate action adjustments, BSE/NSE instrument mapping
- Chart library comparison: lightweight-charts vs Highcharts vs plotly.js (features, license, bundle size)

**`quickstart.md`**:
1. Login with Kite → see holdings with real-time P&L (happy path end-to-end)
2. View RELIANCE technical analysis: RSI, MACD, Bollinger Bands on candlestick chart
3. View portfolio risk: Sharpe ratio, VaR, correlation matrix
4. Run Monte Carlo simulation on portfolio → see probability distribution
5. View daily signals: identify one buy/sell signal with rationale
6. Generate portfolio tear sheet → export to HTML
7. Verify: Sharpe ratio matches QuantStats reference implementation

---

## Phase 3: Task Breakdown

**Command**: `/speckit.tasks`

Create `specs/kiteedge/tasks.md` with granular, parallelizable tasks.

### Required Task Phases

**Phase 1: Project Setup (12-16 tasks)**
- Monorepo: Elixir umbrella app, Python packages (analytics_engine, data_pipeline), React app
- Docker Compose: PostgreSQL 16, Kafka (KRaft), Redis 7
- Ecto migrations framework
- Kafka topic creation scripts
- CI/CD (GitHub Actions): lint, test, build
- Environment configuration (Kite API key, secret as env vars — NEVER in code)
- Seed data: NSE trading calendar, instrument master sample

**Phase 2: Kite Integration Foundation (16-20 tasks)**
- Kite OAuth login flow (Elixir/Phoenix controller)
- Kite API client wrapper with rate limiting (3 req/sec), retry, circuit breaker (Elixir)
- Session management: access_token in Redis with daily expiry, re-auth notification
- Holdings fetch + storage (Ecto schema, Phoenix controller)
- Positions fetch + storage
- Orders/trades sync
- Instrument master sync (daily job — ~100K instruments)
- Historical OHLCV fetch + cache (backfill 5 years daily for holdings)
- Kite API rate limit queue (GenServer with token bucket)
- KiteTicker WebSocket connection (Elixir Port or NIF) for real-time ticks
- Tick publisher: KiteTicker → Kafka `market.ticks`
- Redis LTP cache updater (every tick)
- Offline mode: detect API unavailability → serve cached data with staleness indicator

**Phase 3: US1-US5 — Portfolio Overview MVP (20-26 tasks)**
- Holding enrichment: add sector, market cap, instrument metadata from instrument master
- XIRR computation per holding (Newton-Raphson, handles multiple buys)
- Day P&L computation (current price vs previous close)
- Portfolio aggregation: total value, total P&L, CAGR, XIRR
- Sector allocation computation (classify instruments by sector)
- Market cap distribution
- Concentration risk: Herfindahl-Hirschman Index
- Dividend tracking (if data available from Kite orders/corporate actions)
- React: Portfolio overview page (holdings table, summary cards)
- React: Sector allocation pie chart, market cap distribution (Recharts)
- React: Per-holding detail drawer (price, avg cost, P&L, holding period, XIRR)
- Phoenix Channels: live P&L push to dashboard
- Integration test: Kite login → holdings display → P&L updates in real-time

**Phase 4: US6-US10 — Technical Analysis (22-28 tasks)**
- Python technical module: wrap `ta` library for all 43 indicators
  - Volume indicators (9): MFI, ADI, OBV, CMF, Force Index, EoM, VPT, NVI, VWAP
  - Volatility (5): ATR, Bollinger Bands, Keltner Channel, Donchian Channel, Ulcer Index
  - Trend (15): SMA, EMA, WMA, MACD, ADX, Vortex, TRIX, Mass Index, CCI, DPO, KST, Ichimoku, Parabolic SAR, STC, Aroon, SuperTrend
  - Momentum (11): RSI, Stochastic RSI, TSI, Ultimate Osc, Stochastic Osc, Williams %R, AO, KAMA, ROC, PPO, PVO
  - Others (3): Daily Return, Daily Log Return, Cumulative Return
- Property-based tests: every indicator against `ta` reference on sample OHLCV
- Technical Summary Score algorithm (weighted consensus)
- Support/resistance detection (pivot points + Fibonacci retracement)
- Candlestick pattern recognition (top 20 patterns: Doji, Hammer, Engulfing, etc.)
- Multi-timeframe support (daily, weekly, monthly — aggregate OHLCV)
- Configurable parameters API (user overrides for indicator periods)
- FastAPI endpoint: `POST /analytics/technical/{symbol}`
- React: Candlestick chart (lightweight-charts) with indicator overlays
- React: Technical Summary Score gauge (Strong Buy → Strong Sell)
- React: Indicator configuration panel
- React: Multi-timeframe comparison view

**Phase 5: US11-US15 — Risk Analytics (24-30 tasks)**
- Sharpe, Sortino, Calmar, Information, Treynor ratio computations (reference: QuantStats)
- Jensen's Alpha, Beta computation (vs NIFTY 50 daily returns)
- Rolling metrics (30/60/90/180/365 day windows)
- Max Drawdown computation (depth, duration, recovery)
- Historical VaR (95%, 99%)
- Parametric VaR (variance-covariance)
- Monte Carlo VaR (multivariate GBM, 10K simulations)
- Conditional VaR / Expected Shortfall
- Correlation matrix (Pearson + Spearman) and rolling correlation
- Covariance estimation (Ledoit-Wolf shrinkage)
- Marginal risk contribution per holding
- Stress testing: historical scenarios (March 2020, 2008 GFC, 2016 demonetization)
- Stress testing: custom factor shocks
- Monte Carlo forward simulation (correlated GBM, fan chart)
- Property-based tests: all metrics against QuantStats / scipy reference
- FastAPI endpoints for all risk computations
- React: Risk dashboard (metric cards, color-coded by severity)
- React: VaR histogram + tail visualization
- React: Correlation heatmap (interactive)
- React: Drawdown chart
- React: Monte Carlo fan chart (with percentile bands)
- React: Stress test scenario picker + impact table

**Phase 6: US16-US18 — Predictions & Forecasting (18-22 tasks)**
- ARIMA model: auto-fitting (AIC/BIC), forecast with confidence intervals
- Prophet model: NSE calendar holidays, weekly seasonality
- Ensemble: weighted average + accuracy-based weight adjustment
- Forecast accuracy tracking (MAPE, RMSE, MAE on rolling out-of-sample)
- Signal generation: MA crossovers (Golden Cross, Death Cross)
- Signal generation: RSI divergence detection (price makes new high, RSI doesn't)
- Signal generation: MACD crossovers + histogram reversal
- Signal generation: Bollinger Band squeeze detector
- Signal generation: Volume-price divergence
- Portfolio return forecast (aggregate per-holding forecasts)
- FastAPI endpoints for forecasts and signals
- React: Forecast chart with confidence bands
- React: Signal feed (card list with rationale, confidence, contributing indicators)
- React: Forecast accuracy leaderboard (model comparison)
- Nightly batch job: retrain models, generate forecasts, compute signals
- **PROMINENT disclaimer on every prediction view**

**Phase 7: US19-US22 — Trade Analysis (16-20 tasks)**
- Trade history sync from Kite (complete order fill history)
- FIFO cost basis computation per instrument
- Trade-level P&L
- Win rate, profit factor, expectancy, consecutive W/L computation
- Holding period analysis (winners vs losers)
- P&L by time patterns (day of week, month, hour)
- Execution quality: slippage computation
- Rolling equity curve + drawdown curve
- FastAPI endpoints for trade performance
- React: Trade history table with search/filter
- React: Trade performance dashboard (metrics cards + charts)
- React: P&L calendar heatmap (daily P&L colored by magnitude)
- React: Equity curve + drawdown chart

**Phase 8: US23-US26 — Suggestions & Alerts (16-20 tasks)**
- Daily screening engine: iterate holdings + watchlist, compute indicators, detect signals
- Signal ranking by confidence and significance
- Rebalancing calculator: target allocation → required trades
- Tax-loss harvesting: identify holdings with unrealized losses > threshold
- Diversification analyzer: sector concentration, correlation-based suggestions
- Alert rule engine: configurable thresholds (price, RSI, SLA-like drawdown alerts)
- Kafka alert pipeline: signal detected → alert event → notification
- Alert history storage
- React: Signal feed with actionable cards
- React: Rebalancing calculator (current vs target with trade list)
- React: Diversification radar chart
- React: Alert configuration panel
- React: Alert notification toasts (real-time via Phoenix Channels)

**Phase 9: US27-US29 — Reporting & Export (12-16 tasks)**
- QuantStats-based HTML tear sheet generation
- Excel export: formatted XLSX with holdings, metrics, charts
- CSV export for all data endpoints
- Power BI OData endpoint for live analytics
- Scheduled reports (daily/weekly summary — Oban job)
- React: Tear sheet viewer (HTML iframe or native rendering)
- React: Export center (download queue, format picker)
- React: Power BI connection guide

**Phase 10: Polish & Hardening (18-24 tasks)**
- Performance: indicator computation parallelization (per instrument)
- Performance: pre-computation scheduler (recompute top indicators on candle close)
- Performance: Redis caching for hot analytics queries
- Security: Kite token handling audit (no leaks to logs, no DB persistence)
- Security: CORS, CSP headers, input sanitization
- Error handling: graceful Kite API errors (rate limit, session expired, market closed)
- Documentation: API docs (Swagger), user guide, analytics methodology reference
- Monitoring: Prometheus metrics, Grafana dashboards (Kite API health, computation times)
- Load testing: k6 scripts for dashboard, indicator computation, risk analysis
- Offline mode polish: cached data indicators, "last updated X minutes ago" badges
- Mobile-responsive dashboard (core views only)

### Task Format
```
- [ ] T{NNN} [P?] [US{N}] {Description} — {exact file path}
```

---

## Phase 4: Pre-Implementation Analysis

**Command**: `/speckit.analyze`

Cross-artifact consistency checks:
1. Every FR → component in plan.md
2. Every plan component → tasks in tasks.md
3. API contracts match data model
4. Every indicator in spec → implementation task → test task
5. QuantStats metric list → risk analytics tasks
6. Kite API endpoint usage → rate limit budget analysis (fit within 3 req/sec)
7. Constitution compliance (especially Article I security, Article II rigor)
8. Performance feasibility for stated goals

---

## Phase 5: Implementation

**Command**: `/speckit.implement`

Execute per tasks.md with TDD.

### Implementation Structure

**Elixir Umbrella**
```
apps/
  kite_edge/           # Core: Ecto schemas, Kite API client, business logic
  kite_edge_web/       # Phoenix: REST controllers, Channels, OAuth flow, LiveView
  market_data/         # KiteTicker WebSocket → Kafka publisher, Redis LTP cache
  notification/        # Kafka consumer → in-app + email alerts
```

**Python Packages**
```
analytics_engine/
  api/                 # FastAPI main app
  technical/
    indicators.py      # ta library wrapper (all 43 indicators)
    summary.py         # Technical Summary Score algorithm
    patterns.py        # Candlestick pattern recognition
    support_resistance.py
  risk/
    metrics.py         # Sharpe, Sortino, Alpha, Beta, etc.
    var.py             # VaR (Historical, Parametric, Monte Carlo)
    correlation.py     # Correlation + covariance
    stress.py          # Stress testing engine
    montecarlo.py      # Forward Monte Carlo simulation
  forecast/
    arima.py           # ARIMA/SARIMA auto-fitting
    prophet_model.py   # Prophet with NSE calendar
    ensemble.py        # Ensemble combiner
    signals.py         # Crossover, divergence, squeeze detection
  trades/
    performance.py     # Win rate, profit factor, expectancy
    cost_basis.py      # FIFO cost basis computation
    execution.py       # Slippage analysis
  reports/
    tearsheet.py       # QuantStats HTML tear sheet
    excel.py           # openpyxl Excel generation
    csv_export.py
  tests/
    test_indicators.py     # All 43 indicators vs ta reference
    test_risk_metrics.py   # All metrics vs QuantStats reference
    test_var.py            # VaR against known distributions
    test_forecast.py       # ARIMA/Prophet on synthetic data
    test_xirr.py           # XIRR edge cases

data_pipeline/
  consumers/
    tick_aggregator.py     # Ticks → OHLCV candles
    indicator_updater.py   # On candle close → recompute indicators
    risk_recomputer.py     # Scheduled risk recomputation
    alert_evaluator.py     # Evaluate alert rules on new data
    forecast_scheduler.py  # Nightly model retraining
```

**React Dashboard**
```
dashboard/
  src/
    components/
      portfolio/       # HoldingsTable, SummaryCards, SectorChart, CompositionView
      charts/          # CandlestickChart (lightweight-charts), IndicatorOverlays
      technical/       # IndicatorPanel, SummaryGauge, PatternList, TimeframeToggle
      risk/            # RiskCards, VaRHistogram, CorrelationHeatmap, DrawdownChart, MonteCarloFan
      forecast/        # ForecastChart, SignalFeed, ModelAccuracy, Disclaimer
      trades/          # TradeHistory, PerformanceDash, EquityCurve, PLCalendar
      suggestions/     # SignalCards, Rebalancer, DiversificationRadar, AlertConfig
      reports/         # TearSheetViewer, ExportCenter
      shared/          # PLBadge, TickerSearch, Sparkline, FreshnessIndicator
    hooks/             # TanStack Query hooks for all API endpoints
    contexts/          # Auth (Kite session), WebSocket (Phoenix), Settings
    pages/
    lib/
      api.ts           # Typed API client
      ws.ts            # Phoenix Channels client
      formatters.ts    # INR formatting, percentage, dates, etc.
  tests/
```

### Docker Compose
```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: kiteedge_dev
      POSTGRES_USER: kiteedge
      POSTGRES_PASSWORD: kiteedge_dev
    ports: ["5432:5432"]
    volumes: [pg_data:/var/lib/postgresql/data]
  kafka:
    image: apache/kafka:3.7.0
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
    ports: ["9092:9092"]
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
  gateway:
    build: { context: ., dockerfile: apps/kite_edge_web/Dockerfile }
    depends_on: [postgres, kafka, redis]
    ports: ["4000:4000"]
    environment:
      DATABASE_URL: ecto://kiteedge:kiteedge_dev@postgres/kiteedge_dev
      KITE_API_KEY: ${KITE_API_KEY}
      KITE_API_SECRET: ${KITE_API_SECRET}
      KAFKA_BROKERS: kafka:9092
      REDIS_URL: redis://redis:6379
  analytics:
    build: { context: ., dockerfile: analytics_engine/Dockerfile }
    depends_on: [postgres]
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://kiteedge:kiteedge_dev@postgres/kiteedge_dev
  pipeline:
    build: { context: ., dockerfile: data_pipeline/Dockerfile }
    depends_on: [postgres, kafka]
    environment:
      DATABASE_URL: postgresql://kiteedge:kiteedge_dev@postgres/kiteedge_dev
      KAFKA_BROKERS: kafka:9092
  dashboard:
    build: { context: ., dockerfile: dashboard/Dockerfile }
    depends_on: [gateway]
    ports: ["3000:3000"]
volumes:
  pg_data:
```

---

## Phase 6: Verification

**Command**: `/speckit.verify`

### Automated Verification
1. **Unit tests**: 100% pass, all services
2. **Indicator accuracy**: All 43 indicators match `ta` library reference within 0.001%
3. **Risk metric accuracy**: Sharpe/Sortino/VaR/drawdown match QuantStats within 0.1%
4. **XIRR accuracy**: Matches online XIRR calculators within 0.01% on 10 test cases
5. **Monte Carlo**: VaR from MC converges to parametric VaR within 2% for normal distributions (statistical test)
6. **Forecast**: ARIMA MAPE < 5% on NIFTY 50 30-day backtest
7. **Integration test**: Login → fetch holdings → compute indicators → compute risk → generate tear sheet
8. **Performance**: k6 benchmarks meet NFR thresholds
9. **Security**: Kite token not present in any log, DB dump, or API response body
10. **Real-time**: LTP updates reach dashboard within 2 seconds of simulated tick

### Manual Verification (Quickstart)
1. Login with Kite → holdings appear with live P&L
2. Select RELIANCE → view RSI, MACD, Bollinger Bands on candlestick chart → verify Technical Summary Score
3. View portfolio Sharpe ratio → cross-verify with manual calculation on a spreadsheet
4. Run VaR analysis → verify "5% chance of losing ₹X" statement
5. View correlation matrix → verify highly correlated pairs make intuitive sense (e.g., HDFC Bank and Kotak Bank)
6. Generate 30-day RELIANCE forecast → verify confidence intervals displayed with disclaimer
7. View signals → verify at least one signal has clear, explainable rationale
8. Generate tear sheet → export to HTML → verify it opens correctly with all charts
9. Export holdings to Excel → verify formatted correctly
10. Disconnect network → verify offline mode shows cached data with staleness indicator

---

## Global Constraints

### Artifact Summary
| Phase | Artifacts | Location |
|---|---|---|
| 0. Constitution | `constitution.md` | `specs/kiteedge/` |
| 1. Specification | `spec.md` | `specs/kiteedge/` |
| 2. Plan | `plan.md`, `data-model.md`, `research.md`, `quickstart.md`, `contracts/*.md` | `specs/kiteedge/` |
| 3. Tasks | `tasks.md` | `specs/kiteedge/` |
| 4. Analysis | `analysis-report.md` | `specs/kiteedge/` |
| 5. Implementation | Source code, tests, Docker | Root |
| 6. Verification | Results, benchmarks | `specs/kiteedge/verification/` |

### Technology Versions
```
Elixir: 1.16.x (OTP 26)       Python: 3.12.x
Node.js: 20 LTS               PostgreSQL: 16.x
Kafka: 3.7.x (KRaft)          Redis: 7.x
React: 18.x                   TypeScript: 5.3+
kiteconnect: 5.1.x            ta: 0.11.x
quantstats: 0.0.81            prophet: 1.1.x
statsmodels: 0.14.x           scikit-learn: 1.4.x
lightweight-charts: 4.x       Docker Compose: 3.8+
```

### Out of Scope for v1
- Automated trade execution (analysis only — NEVER place orders programmatically)
- Options/F&O analytics (complex; dedicated v2 feature)
- Intraday tick-by-tick backtesting engine
- Portfolio optimization solver (Markowitz efficient frontier — v2)
- Social features (sharing, leaderboards)
- Mobile app
- Multi-broker support (Zerodha Kite only)
- Fundamental analysis (PE ratio, earnings — requires separate data source)
- News sentiment analysis
- Multi-user / multi-tenant (personal tool for single user)

### Critical Legal Disclaimers (MUST be implemented)
- "This tool is for informational purposes only. It does not constitute investment advice."
- "Past performance does not guarantee future results."
- "Predictions are statistical projections with inherent uncertainty."
- "Always consult a qualified financial advisor before making investment decisions."
- These disclaimers must appear on: every prediction page, every suggestion page, every report, the login page footer.

---

## Execution Instructions

Execute phases sequentially. Each phase MUST produce complete artifacts before the next begins.

1. Phase 0 (Constitution) → establish principles
2. Phase 1 (Specify) → full PRD, no tech decisions
3. Phase 2 (Plan) → architecture + all supporting docs
4. Phase 3 (Tasks) → granular, parallelizable tasks with exact file paths
5. Phase 4 (Analyze) → cross-artifact consistency
6. Phase 5 (Implement) → TDD, service by service
7. Phase 6 (Verify) → automated tests, manual walkthrough, accuracy benchmarks

After each phase, summarize outputs and state readiness for next phase.

If ambiguities or conflicts arise, STOP and resolve before proceeding.

**Begin with Phase 0: Constitution.**
