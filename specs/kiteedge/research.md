# KiteEdge Research Decisions

## Decision 1 - Live Kite access stays at the Elixir boundary

- **Decision**: Gateway API and Market Data service own live Kite authentication and streaming.
  Python services consume normalized data through PostgreSQL, Kafka, Redis, or internal APIs.
- **Rationale**: This minimizes token exposure, matches the constitution's security rules, and
  keeps the real-time boundary in the concurrency model best suited for long-lived sockets.
- **Alternatives considered**:
  - Allow each service to authenticate independently: rejected because it multiplies secret
    handling and rate-limit contention.
  - Centralize all logic in Python: rejected because it weakens the Elixir real-time boundary
    defined by the master architecture.

## Decision 2 - Keep Kite Connect API v3 and kiteconnect v5.1.0 as separate references

- **Decision**: Use Kite Connect API v3 as the external brokerage contract wording and
  kiteconnect v5.1.0 as the approved Python SDK dependency reference.
- **Rationale**: The source material distinguishes the API surface from the client library
  version; both can coexist without contradiction.
- **Alternatives considered**:
  - Collapse everything to API v3 only: rejected because the approved Python SDK version would
    be lost from planning artifacts.
  - Collapse everything to SDK version only: rejected because it obscures the brokerage API
    contract itself.

## Decision 3 - Historical backfill prioritizes daily candles

- **Decision**: Treat 5 years of daily history as the primary cached horizon for holdings and
  watchlist analytics. Intraday historical fetches remain bounded to the windows needed for the
  active user stories.
- **Rationale**: Kite historical API limits minute data more aggressively than daily data, and
  most v1 analytics depend on consistent daily history.
- **Alternatives considered**:
  - Cache full multi-year minute data for all instruments: rejected because it conflicts with
    source limits and adds unnecessary storage and backfill time for v1.
  - Fetch history on demand only: rejected because it risks slow analysis and degraded offline
    behavior.

## Decision 4 - Technical summary uses weighted consensus

- **Decision**: Compute the technical summary score with category weights of trend 35%,
  momentum 30%, volatility 20%, and volume 15%, while preserving a per-factor explanation.
- **Rationale**: Weighted consensus approximates the user value of a TradingView-style summary
  without hiding the underlying factors.
- **Alternatives considered**:
  - Equal weights across all indicators: rejected because it overweights noisy or redundant
    signals.
  - Opaque heuristic score: rejected because it would violate explainability expectations.

## Decision 5 - Offer all three VaR modes

- **Decision**: Expose historical, parametric, and Monte Carlo VaR as first-class methods.
- **Rationale**: Each method serves a different tradeoff among realism, speed, and assumption
  transparency, and the spec explicitly calls for all three.
- **Alternatives considered**:
  - Historical only: rejected because users lose fast benchmark estimation and model-based
    comparisons.
  - Monte Carlo only: rejected because it is slower and less transparent for quick checks.

## Decision 6 - Use Ledoit-Wolf shrinkage as the default stabilized covariance estimate

- **Decision**: Present sample covariance and rolling correlation views, but default advanced
  risk workflows to shrinkage-based covariance when enough assets are involved.
- **Rationale**: Shrinkage reduces instability for portfolios with limited observations relative
  to asset count.
- **Alternatives considered**:
  - Sample covariance only: rejected because it becomes unstable for denser portfolios.
  - Heavy optimization frameworks in v1: rejected because they exceed the simplicity boundary.

## Decision 7 - Prefer ARIMA plus Prophet over ML-heavy forecasting in v1

- **Decision**: Use autoregressive and seasonality-aware statistical forecasting as the v1
  forecasting stack, then combine them through an accuracy-weighted ensemble.
- **Rationale**: These methods are explainable, match the approved libraries, and satisfy the
  product goal without introducing unnecessary ML complexity.
- **Alternatives considered**:
  - LSTM or transformer models: rejected because they add complexity, data demands, and weaker
    interpretability for v1.
  - Single-model forecasting only: rejected because ensemble outputs improve resilience to
    changing market regimes.

## Decision 8 - Candlestick recognition stays rule-based in v1

- **Decision**: Implement top candlestick patterns with explicit rule logic and publish the
  pattern definitions used.
- **Rationale**: Rule-based patterns are auditable, easy to test, and sufficient for the v1
  scope.
- **Alternatives considered**:
  - Depend on TA-Lib pattern recognition exclusively: rejected because it adds another opaque
    dependency and weakens transparency.
  - Skip patterns entirely: rejected because they are explicitly part of the requested scope.

## Decision 9 - Use NSE/BSE-aware trading calendars with freshness badges

- **Decision**: Market status, holiday handling, and special trading sessions are modeled in a
  dedicated trading calendar dataset and propagated to dashboard freshness indicators.
- **Rationale**: Users must distinguish between normal staleness, market closure, and upstream
  failure.
- **Alternatives considered**:
  - Infer market status only from quote movement: rejected because it is unreliable around
    holidays and special sessions.
  - Hard-code market closures into UI logic: rejected because it is hard to maintain.

## Decision 10 - Compute XIRR with Newton-Raphson and explicit fallback handling

- **Decision**: Use Newton-Raphson as the primary XIRR solution method, with bounded retries,
  multiple initial guesses, and explicit user-facing fallback when convergence fails.
- **Rationale**: XIRR is a core metric for holdings with irregular cash flows, and convergence
  behavior must be handled deliberately.
- **Alternatives considered**:
  - Simple CAGR approximation: rejected because it fails for irregular cash flows.
  - Black-box calculator behavior: rejected because it weakens reproducibility and testing.

## Decision 11 - Use lightweight-charts for candlestick visualization

- **Decision**: Use lightweight-charts for primary price visualization and Recharts for broader
  portfolio analytics.
- **Rationale**: This keeps candlestick rendering specialized, performant, and lightweight while
  using a general charting library where it fits better.
- **Alternatives considered**:
  - Highcharts: rejected because of licensing and bundle overhead.
  - Plotly.js for all dashboard charts: rejected because it is heavier than necessary for the
    core interaction model.

## Decision 12 - Prediction and suggestion outputs always carry disclaimers in payload design

- **Decision**: Forecast, signal, suggestion, and report contracts include disclaimer fields so
  clients can render required legal language consistently.
- **Rationale**: The constitution requires disclaimer propagation on specific surfaces, and
  contract-level support reduces the chance of omission in later phases.
- **Alternatives considered**:
  - Hard-code disclaimers only in frontend pages: rejected because it risks omissions in report
    generation and API-driven consumers.
  - Exclude disclaimers from payloads entirely: rejected because it weakens compliance checks.