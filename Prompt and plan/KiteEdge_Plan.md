# KiteEdge — Project Plan & Summary

## Project Overview
**KiteEdge** is a self-hosted portfolio intelligence platform for Zerodha Kite users. It connects to the Kite Connect API to perform mathematical analysis, complex quantitative analysis, predictions, trade suggestions, and deep portfolio analytics.

## Key Facts
- **Platform type**: Personal analytical tool (single user, self-hosted)
- **NOT**: An automated trading system — no orders are ever placed programmatically
- **SDD Workflow**: 7 phases (Constitution → Specify → Plan → Tasks → Analyze → Implement → Verify)

## Architecture (6 Services)

| # | Service | Tech | Role |
|---|---------|------|------|
| 1 | Gateway API | Elixir/Phoenix | Kite OAuth, REST API, Phoenix Channels, Oban scheduled jobs |
| 2 | Market Data | Elixir + KiteTicker | WebSocket ticks → Kafka → Redis LTP cache |
| 3 | Analytics Engine | Python/FastAPI | Technical (43 indicators), Risk (VaR, Monte Carlo), Forecast (ARIMA, Prophet), Trades, Reports |
| 4 | Data Pipeline | Python/Kafka | Tick aggregation, indicator computation, alert evaluation, nightly forecasts |
| 5 | Dashboard | React/TypeScript | 8 page sections, TradingView charts, real-time via Phoenix Channels |
| 6 | Notification | Elixir/Broadway | Kafka alerts → in-app toasts + email |

## User Stories (29 across 7 priorities)

| Priority | Group | Count | Key Capabilities |
|----------|-------|-------|-------------------|
| P1 | Portfolio Overview | US1-5 | Kite OAuth, holdings P&L, XIRR, sector allocation, dividends |
| P2 | Technical Analysis | US6-10 | 43 indicators, candlestick charts, Technical Summary Score, multi-timeframe |
| P3 | Risk Analytics | US11-15 | Sharpe/Sortino/VaR, correlation matrix, stress testing, Monte Carlo |
| P4 | Predictions | US16-18 | ARIMA + Prophet forecasts, trend signals, portfolio return forecast |
| P5 | Trade Analysis | US19-22 | Trade history, win rate, slippage, equity curve |
| P6 | Suggestions | US23-26 | Screening signals, rebalancing, tax-loss harvesting, alerts |
| P7 | Reporting | US27-29 | QuantStats tear sheets, Excel/CSV/PDF export, Power BI |

## Research Incorporated

### Kite Connect API v5.1.0
- KiteConnect: orders, positions, holdings, instruments, historical OHLCV, margins
- KiteTicker WebSocket: real-time ticks (modes: LTP/Quote/Full)
- Rate limits: 3 requests/second
- Historical data: minute data 60 days max, daily data 2000 days max per request
- OAuth flow: redirect → request_token → access_token (daily expiry)

### Technical Analysis (ta library v0.11.0)
- **Volume (9)**: MFI, ADI, OBV, CMF, VWAP, Force Index, EoM, VPT, NVI
- **Volatility (5)**: ATR, Bollinger Bands, Keltner Channel, Donchian Channel, Ulcer Index
- **Trend (15)**: SMA, EMA, WMA, MACD, ADX, Vortex, TRIX, Mass Index, CCI, DPO, KST, Ichimoku, Parabolic SAR, STC, Aroon
- **Momentum (11)**: RSI, Stochastic RSI, TSI, Ultimate Osc, Stochastic Osc, Williams %R, AO, KAMA, ROC, PPO, PVO
- **Others (3)**: Daily Return, Daily Log Return, Cumulative Return

### QuantStats v0.0.81
- Stats: Sharpe, Sortino, Calmar, VaR, CVaR, max drawdown, rolling greeks, Kelly criterion, information ratio, win rate, profit factor
- Plots: snapshot, drawdown, monthly heatmap, rolling beta/sharpe/sortino/volatility, Monte Carlo
- Reports: HTML tear sheets
- Monte Carlo simulations with bust/goal probability

### Forecasting
- ARIMA/SARIMA via statsmodels (auto-fitting with AIC/BIC)
- Facebook Prophet with NSE calendar holidays and weekly seasonality
- Ensemble: weighted average based on rolling backtesting accuracy

## Implementation Phases (10 task phases, ~200 tasks)

1. **Project Setup** (12-16 tasks): Monorepo, Docker Compose, CI/CD
2. **Kite Integration** (16-20 tasks): OAuth, API client, rate limiting, KiteTicker, instrument master
3. **Portfolio Overview MVP** (20-26 tasks): Holdings, XIRR, sector allocation, live P&L
4. **Technical Analysis** (22-28 tasks): 43 indicators, candlestick charts, summary score
5. **Risk Analytics** (24-30 tasks): Sharpe/VaR/Monte Carlo, correlation, stress testing
6. **Predictions** (18-22 tasks): ARIMA, Prophet, signals, disclaimers
7. **Trade Analysis** (16-20 tasks): FIFO P&L, win rate, equity curve
8. **Suggestions** (16-20 tasks): Screening, rebalancing, alerts
9. **Reporting** (12-16 tasks): Tear sheets, Excel, Power BI
10. **Polish** (18-24 tasks): Performance, security, monitoring, offline mode

## Files in This Folder

| File | Description |
|------|-------------|
| `KiteEdge_Master_Prompt.md` | Full ~6,000 word SDD mega-prompt for KiteEdge |
| `KiteEdge_Launch_Prompt.md` | Short companion prompt to start execution |
| `KiteEdge_Plan.md` | This file — project summary and plan |
| `ExperimentHub_Master_Prompt.md` | A/B Testing platform SDD prompt |
| `TicketFlow_Master_Prompt.md` | Customer Support Ticket System SDD prompt |
| `TicketFlow_Launch_Prompt.md` | TicketFlow short launch prompt |

## Key Decisions
- **No automated trading**: Platform is analytics-only, never places orders
- **F&O excluded** from v1 (too complex, planned for v2)
- **Single user**: Personal tool, no multi-tenant
- **Python for analytics**: ta, quantstats, statsmodels are Python ecosystem
- **Elixir for real-time/API**: Excellent for WebSocket, Kafka, concurrent processing
- **Legal disclaimers**: Required on every prediction/suggestion page
- **Offline mode**: Cached data with staleness indicator when Kite API unavailable
