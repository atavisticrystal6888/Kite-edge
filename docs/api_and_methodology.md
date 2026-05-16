# KiteEdge – API & Methodology Reference (T199)

> **Note:** For the full developer documentation including architecture, setup, testing, and deployment, see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md).

## 1 Authentication

| Endpoint | Method | Description |
|---|---|---|
| `/auth/kite/login` | GET | Redirects to Kite login page |
| `/auth/kite/callback` | GET | Handles Kite OAuth callback, sets session cookie |
| `/auth/kite/logout` | POST | Clears session from Redis |

**Security notes:**
- Kite access tokens are stored only in Redis with 18 h TTL.
- No token is ever written to PostgreSQL or logs.

## 2 Portfolio

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/api/v1/portfolio/holdings` | GET | ✓ | Current holdings from Kite |
| `/api/v1/portfolio/summary` | GET | ✓ | Portfolio summary with sector allocation, market-cap distribution |
| `/api/v1/portfolio/xirr` | POST | ✓ | XIRR calculation via scipy brentq |

## 3 Technical Analysis

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/api/v1/analytics/technical/{symbol}` | POST | ✓ | Full indicator suite (trend, momentum, volatility, volume, returns) |
| `/api/v1/analytics/technical/{symbol}/summary` | GET | ✓ | Summary score [-100,+100] with band classification |

### Indicator methodology
- **Trend**: SMA(20,50,200), EMA(12,26), MACD, ADX, Ichimoku
- **Momentum**: RSI(14), Stochastic, Williams %R, CCI, ROC
- **Volatility**: ATR(14), Bollinger Bands(20,2), Keltner Channel, Historical Vol(20)
- **Volume**: OBV, VWAP, MFI, Accumulation/Distribution
- **Summary scoring**: Weighted linear combination → normalised to [-100,+100] → bands: Strong Buy (>50), Buy (>20), Neutral, Sell (<-20), Strong Sell (<-50)

## 4 Risk Analytics

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/analytics/risk/portfolio` | POST | Sharpe, Sortino, Calmar, max drawdown, rolling metrics |
| `/api/v1/analytics/risk/var` | POST | VaR: Historical, Parametric (Gaussian), Monte Carlo |
| `/api/v1/analytics/risk/montecarlo` | POST | Forward portfolio simulation with path percentiles |
| `/api/v1/analytics/risk/stress-test` | POST | Historical scenario (COVID, GFC, Demonetisation, Taper Tantrum) |
| `/api/v1/analytics/risk/correlation` | POST | Correlation matrix, Ledoit-Wolf shrinkage covariance |

### VaR methodology
- **Historical**: Empirical quantile of daily returns
- **Parametric**: Gaussian assumption, μ - z_α × σ
- **Monte Carlo**: GBM paths with drift + diffusion, quantile of terminal distribution

## 5 Forecasting

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/analytics/forecast/{symbol}` | POST | ARIMA + Prophet ensemble with confidence intervals |
| `/api/v1/analytics/forecast/portfolio` | POST | Portfolio-level weighted forecast aggregation |

### Forecast methodology
- ARIMA(5,1,0) via statsmodels auto_arima
- Prophet with Indian trading-calendar seasonality
- Ensemble: inverse-MAE weighted average

## 6 Trade Analytics

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/analytics/trades/performance` | GET | FIFO cost-basis matching, win/loss metrics, equity curve |

## 7 Suggestions & Signals

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/analytics/signals` | GET | Screened signals ranked by composite confidence score |
| `/api/v1/analytics/rebalance` | POST | Equal-weight or custom rebalance recommendations |

## 8 Reports

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/reports/tearsheet` | POST | QuantStats HTML tear sheet |
| `/api/v1/reports/export` | POST | XLSX / CSV / PDF export |
| `/api/v1/reports/odata/holdings` | GET | OData v4 entity set |
| `/api/v1/reports/odata/$metadata` | GET | OData CSDL metadata |
| `/api/v1/reports/powerbi/push` | POST | Power BI streaming push |

## 9 Infrastructure

| Endpoint | Method | Description |
|---|---|---|
| `/health` | GET | DB + Redis + analytics-engine liveness |
| `/metrics` | GET | Prometheus-compatible metrics |

## Disclaimers

All forecast, suggestion, and report surfaces carry mandatory disclaimers:
- **Login**: "KiteEdge is a personal portfolio-analytics tool …"
- **Prediction**: "Forecasts are statistical projections, not investment advice …"
- **Suggestion**: "Signals are heuristic screens, not recommendations …"
- **Report**: "Report data may have reconciliation differences …"
