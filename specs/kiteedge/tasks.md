# Tasks: KiteEdge Portfolio Intelligence Platform

**Input**: Design documents from `/specs/kiteedge/`
**Prerequisites**: constitution.md, spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are REQUIRED. Every foundational or user-story slice begins with failing tests before implementation tasks.

**Organization**: Tasks are grouped by the 10 implementation phases defined for KiteEdge. Story-specific tasks carry `[USN]` labels. Shared infrastructure tasks omit story labels.

## Format: `[ID] [P?] [Story] Description - exact file path`

- `[P]` marks work that can proceed in parallel because it touches different files with no dependency on unfinished tasks.
- `[Story]` maps the task to the user story that primarily owns the behavior.
- Every task ends with the exact intended file path.

## Phase 1: Project Setup (Shared Infrastructure)

**Purpose**: Establish the monorepo, local infrastructure, CI, and development defaults.

- [x] T001 Initialize the Elixir umbrella root and shared aliases - mix.exs
- [x] T002 Create the core Elixir application manifest - apps/kite_edge/mix.exs
- [x] T003 [P] Create the Phoenix web application manifest - apps/kite_edge_web/mix.exs
- [x] T004 [P] Create the market data application manifest - apps/market_data/mix.exs
- [x] T005 [P] Create the notification application manifest - apps/notification/mix.exs
- [x] T006 [P] Create the analytics engine Python package manifest - analytics_engine/pyproject.toml
- [x] T007 [P] Create the data pipeline Python package manifest - data_pipeline/pyproject.toml
- [x] T008 [P] Create the dashboard package manifest and scripts - dashboard/package.json
- [x] T009 Define the local multi-service container stack - docker-compose.yml
- [x] T010 [P] Create the Kafka topic bootstrap script - infra/kafka/create-topics.sh
- [x] T011 [P] Create the environment template with Kite secret placeholders - .env.example
- [x] T012 [P] Configure the CI workflow for mix, pytest, and npm checks - .github/workflows/ci.yml
- [x] T013 [P] Configure Ecto repo and migration defaults - apps/kite_edge/config/config.exs
- [x] T014 [P] Configure repository-wide linting and formatting defaults - .formatter.exs
- [x] T015 [P] Seed the trading calendar and sample instrument data - apps/kite_edge/priv/repo/seeds.exs

---

## Phase 2: Kite Integration Foundation (Blocking Prerequisites)

**Purpose**: Implement the Kite-facing foundations that every later user story depends on.

**Critical**: No story work begins before this phase is complete.

### Tests for Foundational Slice (REQUIRED)

- [x] T016 [P] Add OAuth controller integration tests for Kite login and callback handling - apps/kite_edge_web/test/kite_edge_web/controllers/auth_controller_test.exs
- [x] T017 [P] Add Kite client tests for request pacing, retry, and error mapping - apps/kite_edge/test/kite_edge/kite/client_test.exs
- [x] T018 [P] Add holdings and positions sync integration tests with PostgreSQL - apps/kite_edge/test/kite_edge/sync/holdings_sync_test.exs
- [x] T019 [P] Add market tick ingestion tests for WebSocket, Kafka, and Redis flow - apps/market_data/test/market_data/kite_ticker/connection_test.exs

### Implementation

- [x] T020 Implement the OAuth routes and callback controller - apps/kite_edge_web/lib/kite_edge_web/controllers/auth_controller.ex
- [x] T021 Implement ephemeral Kite session storage in Redis - apps/kite_edge/lib/kite_edge/kite/session_store.ex
- [x] T022 Implement the Kite API client wrapper - apps/kite_edge/lib/kite_edge/kite/client.ex
- [x] T023 Implement the token-bucket rate limiter for Kite calls - apps/kite_edge/lib/kite_edge/kite/rate_limiter.ex
- [x] T024 Implement retry, backoff, and circuit-breaker request orchestration - apps/kite_edge/lib/kite_edge/kite/request_pipeline.ex
- [x] T025 Create the core market and portfolio migration set - apps/kite_edge/priv/repo/migrations/20260416010100_create_core_market_tables.exs
- [x] T026 Create the instrument master schema - apps/kite_edge/lib/kite_edge/market/instrument_master.ex
- [x] T027 Create the holding schema - apps/kite_edge/lib/kite_edge/portfolio/holding.ex
- [x] T028 Create the position schema - apps/kite_edge/lib/kite_edge/portfolio/position.ex
- [x] T029 Implement the holdings and positions sync workers - apps/kite_edge/lib/kite_edge/sync/holdings_sync.ex
- [x] T030 Implement the orders and trades sync service - apps/kite_edge/lib/kite_edge/sync/trades_sync.ex
- [x] T031 Implement the instrument master refresh job - apps/kite_edge/lib/kite_edge/sync/instrument_master_sync.ex
- [x] T032 Implement the historical OHLCV backfill job - apps/kite_edge/lib/kite_edge/sync/historical_backfill.ex
- [x] T033 Implement the KiteTicker connection manager - apps/market_data/lib/market_data/kite_ticker/connection.ex
- [x] T034 Implement Kafka tick publishing and Redis quote cache updates - apps/market_data/lib/market_data/tick_publisher.ex
- [x] T035 Implement offline-mode freshness and stale-data fallback handling - apps/kite_edge/lib/kite_edge/portfolio/offline_mode.ex

**Checkpoint**: Brokerage authentication, synchronized portfolio inputs, historical candles, and live tick transport are ready for user-facing work.

---

## Phase 3: US1-US5 - Portfolio Overview MVP

**Goal**: Deliver the first complete daily-use slice: sign in, see live holdings, review composition, inspect holding performance, and view dividend context.

**Independent Test**: Complete Kite login, land on the overview, confirm holdings and summary metrics render, inspect one holding detail view, and verify dividend data where available.

### Tests for Portfolio Overview (REQUIRED)

- [x] T036 [P] [US1] Add contract tests for the holdings endpoint - apps/kite_edge_web/test/kite_edge_web/controllers/portfolio/holdings_controller_test.exs
- [x] T037 [P] [US1] Add end-to-end login-to-holdings flow tests - apps/kite_edge_web/test/integration/holdings_login_flow_test.exs
- [x] T038 [P] [US2] Add component tests for sector allocation and composition widgets - dashboard/tests/portfolio/sector_allocation.test.tsx
- [x] T039 [P] [US3] Add regression tests for holding-return and XIRR scenarios - analytics_engine/tests/test_xirr_holdings.py
- [x] T040 [P] [US4] Add contract tests for the portfolio summary endpoint - apps/kite_edge_web/test/kite_edge_web/controllers/portfolio/summary_controller_test.exs
- [x] T041 [P] [US5] Add dividend aggregation tests for holding-level and portfolio totals - apps/kite_edge/test/kite_edge/portfolio/dividend_summary_test.exs

### Implementation

- [x] T042 [US1] Implement the holdings query service - apps/kite_edge/lib/kite_edge/portfolio/holdings_query.ex
- [x] T043 [US1] Implement the holdings controller endpoint - apps/kite_edge_web/lib/kite_edge_web/controllers/portfolio/holdings_controller.ex
- [x] T044 [US1] Implement live holdings broadcasting over Phoenix Channels - apps/kite_edge_web/lib/kite_edge_web/channels/portfolio_channel.ex
- [x] T045 [US2] Implement the portfolio composition calculator - apps/kite_edge/lib/kite_edge/portfolio/composition.ex
- [x] T046 [US2] Implement sector classification enrichment - apps/kite_edge/lib/kite_edge/portfolio/sector_classification.ex
- [x] T047 [US2] Implement market-cap distribution aggregation - apps/kite_edge/lib/kite_edge/portfolio/market_cap_distribution.ex
- [x] T048 [US2] Implement concentration-risk calculation - apps/kite_edge/lib/kite_edge/portfolio/concentration_risk.ex
- [x] T049 [US3] Implement per-holding return calculations - apps/kite_edge/lib/kite_edge/portfolio/holding_returns.ex
- [x] T050 [US3] Implement XIRR calculation service for holdings - apps/kite_edge/lib/kite_edge/portfolio/xirr.ex
- [x] T051 [US4] Implement portfolio summary aggregation - apps/kite_edge/lib/kite_edge/portfolio/summary.ex
- [x] T052 [US4] Implement the summary controller endpoint - apps/kite_edge_web/lib/kite_edge_web/controllers/portfolio/summary_controller.ex
- [x] T053 [US5] Implement dividend ingestion normalization - apps/kite_edge/lib/kite_edge/portfolio/dividend_ingestor.ex
- [x] T054 [US5] Implement dividend summary aggregation - apps/kite_edge/lib/kite_edge/portfolio/dividend_summary.ex
- [x] T055 [US1] Build the portfolio overview page - dashboard/src/pages/PortfolioOverviewPage.tsx
- [x] T056 [US2] Build sector allocation and market-cap chart components - dashboard/src/components/portfolio/AllocationCharts.tsx
- [x] T057 [US3] Build the holding detail drawer - dashboard/src/components/portfolio/HoldingDetailDrawer.tsx
- [x] T058 [US1] Add the portfolio overview query hook and live channel state wiring - dashboard/src/hooks/usePortfolioOverview.ts

**Checkpoint**: US1-US5 are independently demoable through the overview dashboard.

---

## Phase 4: US6-US10 - Technical Analysis

**Goal**: Deliver full instrument technical analysis, chart overlays, configurable studies, summary scoring, and multi-timeframe comparison.

**Independent Test**: Open one instrument, verify indicator groups and chart overlays render, change an indicator parameter, and compare daily, weekly, and monthly views.

### Tests for Technical Analysis (REQUIRED)

- [x] T059 [P] [US6] Add regression tests for trend indicator outputs against the approved reference set - analytics_engine/tests/test_indicators_trend.py
- [x] T060 [P] [US6] Add regression tests for momentum indicator outputs against the approved reference set - analytics_engine/tests/test_indicators_momentum.py
- [x] T061 [P] [US6] Add regression tests for volatility, volume, and return indicators - analytics_engine/tests/test_indicators_volatility_volume.py
- [x] T062 [P] [US8] Add property-based tests for the technical summary weighting model - analytics_engine/tests/test_technical_summary.py
- [x] T063 [P] [US7] Add API contract tests for full technical analysis responses - analytics_engine/tests/test_technical_api.py
- [x] T064 [P] [US10] Add UI integration tests for the multi-timeframe comparison flow - dashboard/tests/technical/multi_timeframe.test.tsx

### Implementation

- [x] T065 [US6] Implement trend indicator wrappers - analytics_engine/technical/indicators.py
- [x] T066 [US6] Implement momentum indicator wrappers - analytics_engine/technical/indicators.py
- [x] T067 [US6] Implement volatility indicator wrappers - analytics_engine/technical/indicators.py
- [x] T068 [US6] Implement volume and return indicator wrappers - analytics_engine/technical/indicators.py
- [x] T069 [US8] Implement the technical summary scorer - analytics_engine/technical/summary.py
- [x] T070 [US7] Implement support and resistance detection - analytics_engine/technical/support_resistance.py
- [x] T071 [US7] Implement candlestick pattern recognition - analytics_engine/technical/patterns.py
- [x] T072 [US10] Implement timeframe aggregation support on candle updates - data_pipeline/consumers/indicator_updater.py
- [x] T073 [US9] Implement persisted indicator parameter profiles - apps/kite_edge/lib/kite_edge/settings/indicator_profile.ex
- [x] T074 [US6] Implement technical analysis API routes - analytics_engine/api/routes/technical.py
- [x] T075 [US6] Expose the gateway proxy for technical endpoints - apps/kite_edge_web/lib/kite_edge_web/controllers/analytics/technical_controller.ex
- [x] T076 [US7] Build the candlestick chart component - dashboard/src/components/charts/CandlestickChart.tsx
- [x] T077 [US7] Build the indicator overlay layer - dashboard/src/components/charts/IndicatorOverlays.tsx
- [x] T078 [US8] Build the technical summary gauge - dashboard/src/components/technical/SummaryGauge.tsx
- [x] T079 [US8] Build the summary contributor breakdown panel - dashboard/src/components/technical/SummaryBreakdown.tsx
- [x] T080 [US9] Build the indicator configuration panel - dashboard/src/components/technical/IndicatorConfigPanel.tsx
- [x] T081 [US10] Build the timeframe comparison component - dashboard/src/components/technical/TimeframeComparison.tsx
- [x] T082 [US6] Add the technical analysis query hook - dashboard/src/hooks/useTechnicalAnalysis.ts
- [x] T083 [US6] Assemble the instrument analysis page - dashboard/src/pages/InstrumentAnalysisPage.tsx
- [x] T084 [US7] Wire chart subscriptions to live tick channels - dashboard/src/lib/ws.ts

**Checkpoint**: US6-US10 are independently demoable through the technical analysis surface.

---

## Phase 5: US11-US15 - Risk Analytics

**Goal**: Deliver risk-adjusted performance, VaR, drawdowns, correlation, stress testing, and forward simulation views.

**Independent Test**: Open the risk dashboard, verify benchmark-relative metrics, run a VaR request, inspect a correlation heatmap, execute a stress scenario, and render a forward simulation.

### Tests for Risk Analytics (REQUIRED)

- [x] T085 [P] [US11] Add regression tests for portfolio ratios against approved benchmark datasets - analytics_engine/tests/test_risk_metrics.py
- [x] T086 [P] [US12] Add distribution tests for historical and parametric VaR - analytics_engine/tests/test_var_historical_parametric.py
- [x] T087 [P] [US12] Add Monte Carlo VaR convergence tests - analytics_engine/tests/test_var_montecarlo.py
- [x] T088 [P] [US13] Add correlation and covariance matrix contract tests - analytics_engine/tests/test_correlation.py
- [x] T089 [P] [US14] Add stress-scenario regression tests - analytics_engine/tests/test_stress.py
- [x] T090 [P] [US15] Add UI integration tests for the Monte Carlo fan-chart flow - dashboard/tests/risk/monte_carlo.test.tsx

### Implementation

- [x] T091 [US11] Implement Sharpe, Sortino, Calmar, Information, and Treynor calculations - analytics_engine/risk/metrics.py
- [x] T092 [US11] Implement benchmark-relative beta and alpha calculations - analytics_engine/risk/metrics.py
- [x] T093 [US11] Implement rolling volatility and rolling-ratio windows - analytics_engine/risk/metrics.py
- [x] T094 [US11] Implement drawdown depth, duration, and recovery calculations - analytics_engine/risk/metrics.py
- [x] T095 [US12] Implement historical VaR and expected shortfall - analytics_engine/risk/var.py
- [x] T096 [US12] Implement parametric VaR - analytics_engine/risk/var.py
- [x] T097 [US12] Implement Monte Carlo VaR - analytics_engine/risk/var.py
- [x] T098 [US13] Implement correlation and covariance services - analytics_engine/risk/correlation.py
- [x] T099 [US13] Implement Ledoit-Wolf shrinkage and marginal risk contribution - analytics_engine/risk/correlation.py
- [x] T100 [US14] Implement historical stress scenarios - analytics_engine/risk/stress.py
- [x] T101 [US14] Implement custom factor-shock stress scenarios - analytics_engine/risk/stress.py
- [x] T102 [US15] Implement forward portfolio simulation - analytics_engine/risk/montecarlo.py
- [x] T103 [US11] Implement risk analytics API routes - analytics_engine/api/routes/risk.py
- [x] T104 [US11] Expose the gateway proxy for risk endpoints - apps/kite_edge_web/lib/kite_edge_web/controllers/analytics/risk_controller.ex
- [x] T105 [US11] Build risk metric cards - dashboard/src/components/risk/RiskCards.tsx
- [x] T106 [US12] Build the VaR histogram and tail view - dashboard/src/components/risk/VaRHistogram.tsx
- [x] T107 [US13] Build the correlation heatmap - dashboard/src/components/risk/CorrelationHeatmap.tsx
- [x] T108 [US11] Build the drawdown chart - dashboard/src/components/risk/DrawdownChart.tsx
- [x] T109 [US15] Build the Monte Carlo fan chart - dashboard/src/components/risk/MonteCarloFan.tsx
- [x] T110 [US14] Build the stress scenario picker and impact table - dashboard/src/components/risk/StressScenarioPanel.tsx
- [x] T111 [US11] Add the risk dashboard query hook - dashboard/src/hooks/useRiskDashboard.ts
- [x] T112 [US11] Assemble the risk dashboard page - dashboard/src/pages/RiskDashboardPage.tsx

**Checkpoint**: US11-US15 are independently demoable through the risk dashboard.

---

## Phase 6: US16-US18 - Predictions & Forecasting

**Goal**: Deliver instrument forecasts, portfolio forecasts, predictive signals, model-accuracy views, and required disclaimers.

**Independent Test**: Run a forecast for one instrument, verify confidence bands and disclaimer placement, inspect active predictive signals, and review a portfolio forecast across multiple horizons.

### Tests for Predictions & Forecasting (REQUIRED)

- [x] T113 [P] [US16] Add regression tests for ARIMA forecasts - analytics_engine/tests/test_forecast_arima.py
- [x] T114 [P] [US16] Add regression tests for Prophet forecasts - analytics_engine/tests/test_forecast_prophet.py
- [x] T115 [P] [US17] Add regression tests for crossover, divergence, and squeeze signals - analytics_engine/tests/test_forecast_signals.py
- [x] T116 [P] [US18] Add portfolio forecast aggregation tests - analytics_engine/tests/test_portfolio_forecast.py
- [x] T117 [P] [US16] Add UI tests for prediction disclaimer rendering - dashboard/tests/forecast/disclaimer.test.tsx

### Implementation

- [x] T118 [US16] Implement ARIMA fitting and forecast generation - analytics_engine/forecast/arima.py
- [x] T119 [US16] Implement Prophet forecasts with trading-calendar seasonality support - analytics_engine/forecast/prophet_model.py
- [x] T120 [US16] Implement the ensemble combiner and weight adjustment logic - analytics_engine/forecast/ensemble.py
- [x] T121 [US16] Implement forecast accuracy tracking - analytics_engine/forecast/accuracy.py
- [x] T122 [US17] Implement moving-average crossover signals - analytics_engine/forecast/signals.py
- [x] T123 [US17] Implement divergence detection signals - analytics_engine/forecast/signals.py
- [x] T124 [US17] Implement Bollinger squeeze and volume-price divergence signals - analytics_engine/forecast/signals.py
- [x] T125 [US18] Implement portfolio-level forecast aggregation - analytics_engine/forecast/portfolio.py
- [x] T126 [US16] Implement forecast API routes - analytics_engine/api/routes/forecast.py
- [x] T127 [US16] Expose the gateway proxy for forecast endpoints - apps/kite_edge_web/lib/kite_edge_web/controllers/analytics/forecast_controller.ex
- [x] T128 [US16] Build the forecast chart with confidence bands - dashboard/src/components/forecast/ForecastChart.tsx
- [x] T129 [US17] Build the predictive signal feed - dashboard/src/components/forecast/SignalFeed.tsx
- [x] T130 [US16] Build the model-accuracy leaderboard - dashboard/src/components/forecast/ModelAccuracy.tsx
- [x] T131 [US16] Build the mandatory prediction disclaimer banner - dashboard/src/components/forecast/Disclaimer.tsx
- [x] T132 [US17] Implement the nightly forecast retraining scheduler - data_pipeline/consumers/forecast_scheduler.py
- [x] T133 [US16] Assemble the predictions page and supporting query hook - dashboard/src/pages/PredictionsPage.tsx

**Checkpoint**: US16-US18 are independently demoable through the predictions page.

---

## Phase 7: US19-US22 - Trade Analysis

**Goal**: Deliver trade history, FIFO trade analytics, execution quality, and rolling trade-performance views.

**Independent Test**: Open the trade journal, verify executed trades and P&L calculations, inspect slippage metrics, and review rolling equity and drawdown views.

### Tests for Trade Analysis (REQUIRED)

- [x] T134 [P] [US19] Add trade-history sync integration tests - apps/kite_edge/test/kite_edge/sync/trade_history_sync_test.exs
- [x] T135 [P] [US20] Add regression tests for trade performance metrics - analytics_engine/tests/test_trade_performance.py
- [x] T136 [P] [US21] Add regression tests for execution-quality analytics - analytics_engine/tests/test_trade_execution.py
- [x] T137 [P] [US22] Add UI integration tests for the trade dashboard flow - dashboard/tests/trades/trade_dashboard.test.tsx

### Implementation

- [x] T138 [US19] Implement complete trade-history synchronization - apps/kite_edge/lib/kite_edge/sync/trade_history_sync.ex
- [x] T139 [US19] Implement FIFO cost-basis matching - analytics_engine/trades/cost_basis.py
- [x] T140 [US19] Implement per-trade profit and loss calculations - analytics_engine/trades/performance.py
- [x] T141 [US20] Implement win rate, expectancy, and streak metrics - analytics_engine/trades/performance.py
- [x] T142 [US20] Implement holding-period and time-pattern analysis - analytics_engine/trades/performance.py
- [x] T143 [US21] Implement slippage and best-execution analysis - analytics_engine/trades/execution.py
- [x] T144 [US22] Implement rolling equity curve and trade drawdown outputs - analytics_engine/trades/performance.py
- [x] T145 [US19] Implement trade analytics API routes - analytics_engine/api/routes/trades.py
- [x] T146 [US19] Expose the gateway proxy for trade analytics - apps/kite_edge_web/lib/kite_edge_web/controllers/analytics/trades_controller.ex
- [x] T147 [US19] Build the trade history table - dashboard/src/components/trades/TradeHistory.tsx
- [x] T148 [US20] Build the trade performance dashboard - dashboard/src/components/trades/PerformanceDashboard.tsx
- [x] T149 [US22] Build the P&L calendar heatmap - dashboard/src/components/trades/PLCalendar.tsx
- [x] T150 [US22] Build the equity curve and drawdown chart - dashboard/src/components/trades/EquityCurve.tsx
- [x] T151 [US19] Assemble the trade journal page and query hook - dashboard/src/pages/TradeJournalPage.tsx

**Checkpoint**: US19-US22 are independently demoable through the trade journal.

---

## Phase 8: US23-US26 - Suggestions & Alerts

**Goal**: Deliver ranked signals, rebalancing suggestions, diversification advice, and configurable alerts.

**Independent Test**: Open the suggestions area, verify ranked signals and rebalance advice, configure one alert rule, and confirm an in-app alert can be delivered for a matching condition.

### Tests for Suggestions & Alerts (REQUIRED)

- [x] T152 [P] [US23] Add regression tests for screening and signal ranking - analytics_engine/tests/test_suggestions_signals.py
- [x] T153 [P] [US24] Add regression tests for the rebalance calculator - analytics_engine/tests/test_rebalance.py
- [x] T154 [P] [US26] Add integration tests for alert-rule evaluation and firing - data_pipeline/tests/test_alert_evaluator.py
- [x] T155 [P] [US26] Add UI flow tests for suggestions and alerts - dashboard/tests/suggestions/alerts.test.tsx

### Implementation

- [x] T156 [US23] Implement the daily screening engine - analytics_engine/api/services/signals.py
- [x] T157 [US23] Implement signal ranking and confidence scoring - analytics_engine/api/services/signals.py
- [x] T158 [US24] Implement target-allocation rebalance calculations - analytics_engine/api/services/rebalance.py
- [x] T159 [US24] Implement tax-loss harvesting detection - analytics_engine/api/services/rebalance.py
- [x] T160 [US25] Implement diversification analysis and improvement suggestions - analytics_engine/api/services/diversification.py
- [x] T161 [US26] Implement the alert-rule evaluation consumer - data_pipeline/consumers/alert_evaluator.py
- [x] T162 [US26] Implement the Kafka alert-delivery consumer - apps/notification/lib/notification/alert_consumer.ex
- [x] T163 [US26] Implement alert-history persistence and unread state handling - apps/notification/lib/notification/alert_history.ex
- [x] T164 [US23] Implement suggestion and rebalance API routes - analytics_engine/api/routes/signals.py
- [x] T165 [US23] Expose the gateway proxy for suggestion endpoints - apps/kite_edge_web/lib/kite_edge_web/controllers/analytics/suggestions_controller.ex
- [x] T166 [US23] Build actionable signal cards - dashboard/src/components/suggestions/SignalCards.tsx
- [x] T167 [US24] Build the rebalancing calculator - dashboard/src/components/suggestions/Rebalancer.tsx
- [x] T168 [US25] Build diversification radar and insights UI - dashboard/src/components/suggestions/DiversificationRadar.tsx
- [x] T169 [US26] Build alert configuration and toast delivery wiring - dashboard/src/components/suggestions/AlertConfig.tsx
- [x] T170 [US23] Assemble the suggestions page and query hook - dashboard/src/pages/SuggestionsPage.tsx

**Checkpoint**: US23-US26 are independently demoable through the suggestions and alerts surface.

---

## Phase 9: US27-US29 - Reporting & Export

**Goal**: Deliver tear sheets, export workflows, BI handoff surfaces, and scheduled reports.

**Independent Test**: Generate a tear sheet, export data in supported formats, and confirm a scheduled report can be produced for a reporting period.

### Tests for Reporting & Export (REQUIRED)

- [x] T171 [P] [US27] Add tear-sheet generation integration tests - analytics_engine/tests/test_reports_tearsheet.py
- [x] T172 [P] [US28] Add export-format contract tests - analytics_engine/tests/test_reports_export.py
- [x] T173 [P] [US29] Add scheduled-report generation tests - apps/kite_edge/test/kite_edge/reports/scheduled_report_job_test.exs

### Implementation

- [x] T174 [US27] Implement QuantStats tear-sheet generation - analytics_engine/reports/tearsheet.py
- [x] T175 [US28] Implement formatted Excel exports - analytics_engine/reports/excel.py
- [x] T176 [US28] Implement CSV exports - analytics_engine/reports/csv_export.py
- [x] T177 [US28] Implement the OData v4 feed endpoint for BI tools (see Remediation Addendum A1; Power BI push split into T177a) - apps/kite_edge_web/lib/kite_edge_web/controllers/reports/odata_controller.ex
- [x] T178 [US29] Implement the scheduled-report job - apps/kite_edge/lib/kite_edge/reports/scheduled_report_job.ex
- [x] T179 [US27] Implement report-generation API routes - analytics_engine/api/routes/reports.py
- [x] T180 [US27] Expose the gateway proxy for report endpoints - apps/kite_edge_web/lib/kite_edge_web/controllers/reports/report_controller.ex
- [x] T181 [US27] Build the tear-sheet viewer - dashboard/src/components/reports/TearSheetViewer.tsx
- [x] T182 [US28] Build the export center - dashboard/src/components/reports/ExportCenter.tsx
- [x] T183 [US28] Build the Power BI connection guide - dashboard/src/components/reports/PowerBIConnectionGuide.tsx
- [x] T184 [US27] Assemble the reports page and query hook - dashboard/src/pages/ReportsPage.tsx

**Checkpoint**: US27-US29 are independently demoable through the reports and export workflow.

---

## Phase 10: Polish & Hardening

**Purpose**: Improve performance, security, observability, documentation, and verification across the complete product.

- [x] T185 [P] Add indicator-computation benchmark coverage - analytics_engine/tests/benchmarks/test_indicator_benchmark.py
- [x] T186 [P] Add risk-analysis benchmark coverage - analytics_engine/tests/benchmarks/test_risk_benchmark.py
- [x] T187 [P] Add dashboard k6 smoke and load scripts - infra/monitoring/k6/dashboard.js
- [x] T188 [P] Add analytics API k6 load scripts - infra/monitoring/k6/analytics.js
- [x] T189 Implement per-instrument indicator parallelization - analytics_engine/technical/indicators.py
- [x] T190 Implement candle-close precomputation scheduling - data_pipeline/consumers/indicator_updater.py
- [x] T191 Implement Redis caching for hot analytics queries - analytics_engine/api/services/cache.py
- [x] T192 Implement structured-log token redaction - apps/kite_edge/lib/kite_edge/logging/redactor.ex
- [x] T193 Implement security headers and input sanitization - apps/kite_edge_web/lib/kite_edge_web/plugs/security_headers.ex
- [x] T194 Implement graceful Kite API error mapping and user-safe failures - apps/kite_edge/lib/kite_edge/kite/error_mapper.ex
- [x] T195 Implement Prometheus health and metrics exposure - apps/kite_edge_web/lib/kite_edge_web/controllers/health_metrics_controller.ex
- [x] T196 Implement Grafana dashboard provisioning - infra/monitoring/grafana/dashboards/kiteedge_overview.json
- [x] T197 Implement shared freshness badges across dashboard surfaces - dashboard/src/components/shared/FreshnessIndicator.tsx
- [x] T198 Implement mobile-responsive layout rules for core views - dashboard/src/lib/responsive.ts
- [x] T199 Publish the API and analytics methodology reference - docs/api_and_methodology.md
- [x] T200 Publish the end-user guide and disclaimer reference - docs/user_guide.md
- [x] T201 Run the quickstart validation and capture results - specs/kiteedge/verification/quickstart_results.md
- [x] T202 Perform the token-leakage audit and record findings - specs/kiteedge/verification/security_audit.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 - Setup**: No dependencies.
- **Phase 2 - Kite Integration Foundation**: Depends on Phase 1 and blocks all later phases.
- **Phase 3 - Portfolio Overview MVP**: Depends on Phase 2.
- **Phase 4 - Technical Analysis**: Depends on Phase 2 and the availability of historical candles.
- **Phase 5 - Risk Analytics**: Depends on Phase 2 and portfolio snapshots from Phase 3.
- **Phase 6 - Predictions & Forecasting**: Depends on Phase 2 and daily history prepared for Phase 4.
- **Phase 7 - Trade Analysis**: Depends on Phase 2 trade synchronization.
- **Phase 8 - Suggestions & Alerts**: Depends on outputs from Phases 4, 5, 6, and 7.
- **Phase 9 - Reporting & Export**: Depends on Phases 3 through 8.
- **Phase 10 - Polish & Hardening**: Depends on all desired product phases being complete.

### User Story Dependencies

- **US1-US5**: Can begin immediately after foundational brokerage sync is complete.
- **US6-US10**: Require instrument history, candles, and market data from Phase 2.
- **US11-US15**: Require holdings snapshots, benchmark selection, and daily return series from Phases 2 and 3.
- **US16-US18**: Require the time-series groundwork from Phase 4 and benchmarked historical data from Phase 2.
- **US19-US22**: Require complete trade and fill synchronization from Phase 2.
- **US23-US26**: Require signal, risk, forecast, and trade outputs from earlier analytics phases.
- **US27-US29**: Require stable portfolio, risk, suggestion, and trade outputs before reporting is meaningful.

### Within Each Phase

- Failing tests come before implementation tasks.
- Schemas and persistence contracts come before services that depend on them.
- Services come before controllers or API routes.
- API routes come before dashboard hooks and pages.
- Each phase should be demoable before proceeding to the next one.

## Parallel Opportunities

- Setup tasks marked `[P]` can proceed in parallel after the repo root is defined.
- Foundational test tasks T016-T019 can run in parallel.
- Within Portfolio Overview, T036-T041 can run in parallel, and UI tasks T055-T058 can proceed once the corresponding endpoints exist.
- Within Technical Analysis, the indicator test groups T059-T061 can run in parallel, and UI tasks T076-T084 can be split across frontend contributors.
- Within Risk Analytics, T085-T090 can run in parallel and chart component tasks T105-T110 can also proceed in parallel after the API shapes are stable.
- Suggestions and reporting phases each have independent frontend components that can proceed in parallel after service contracts are stable.

---

## Phase 4 Remediation Addendum

**Purpose**: Close the constitution-alignment failure (D1) and the four HIGH coverage gaps (C1-C4) plus related medium findings (I1, I2, A1) identified in [analysis-report.md](./analysis-report.md). These tasks are additive. Existing IDs T001-T202 remain stable. New IDs use a letter suffix pointing to the nearest logical anchor task in the original sequence. All remediation tasks MUST land before `/speckit.implement` begins for the phase they belong to.

### D1 - Disclaimer Propagation (CRITICAL, Constitution Principle 8)

- [x] T055a [US1] Build the shared legal disclaimer component used on login, prediction, suggestion, and report surfaces - dashboard/src/components/shared/Disclaimer.tsx
- [x] T055b [US1] Add the login-page footer disclaimer with version and risk language - dashboard/src/components/auth/LoginFooterDisclaimer.tsx
- [x] T055c [P] [US1] Add UI tests asserting disclaimer presence on the login page - dashboard/tests/auth/login_footer_disclaimer.test.tsx
- [x] T170a [US23] Build the mandatory suggestion-page disclaimer banner - dashboard/src/components/suggestions/Disclaimer.tsx
- [x] T170b [P] [US23] Add UI tests asserting disclaimer presence on the suggestions page - dashboard/tests/suggestions/disclaimer.test.tsx
- [x] T184a [US27] Build the report disclaimer banner rendered on every report surface - dashboard/src/components/reports/ReportDisclaimer.tsx
- [x] T184b [P] [US27] Add UI tests asserting disclaimer presence on tear sheets and export previews - dashboard/tests/reports/disclaimer.test.tsx
- [x] T184c [US28] Embed disclaimer text into all generated tear-sheet, Excel, CSV, and PDF exports - analytics_engine/reports/disclaimers.py

### C1 - Non-Holding Instrument Search, Quote, and OHLCV (HIGH, FR-022)

- [x] T064a [P] [US6] Add contract tests for the instrument search, quote, and OHLCV endpoints - apps/kite_edge_web/test/kite_edge_web/controllers/instruments_controller_test.exs
- [x] T074a [US6] Implement the instrument lookup, quote, and OHLCV query service - apps/kite_edge/lib/kite_edge/market/instrument_query.ex
- [x] T074b [US6] Implement the gateway instruments controller for search, quote, and OHLCV routes - apps/kite_edge_web/lib/kite_edge_web/controllers/instruments_controller.ex
- [x] T082a [US6] Add the instrument search and lookup query hook - dashboard/src/hooks/useInstrumentLookup.ts
- [x] T083a [US6] Build the instrument search combobox used by the analysis page - dashboard/src/components/technical/InstrumentSearch.tsx

### C2 - Watchlist CRUD (HIGH, FR-070)

- [x] T025a Create the watchlist, settings, and notification-preferences migration set - apps/kite_edge/priv/repo/migrations/20260416010200_create_settings_and_watchlists.exs
- [x] T155a [P] [US23] Add contract tests for watchlist CRUD and ordering endpoints - apps/kite_edge_web/test/kite_edge_web/controllers/watchlists_controller_test.exs
- [x] T163a [US23] Implement watchlist schemas and Ecto context - apps/kite_edge/lib/kite_edge/watchlists.ex
- [x] T163b [US23] Implement the watchlist CRUD controller and routes - apps/kite_edge_web/lib/kite_edge_web/controllers/watchlists_controller.ex
- [x] T169a [US23] Build the watchlist management UI - dashboard/src/components/suggestions/WatchlistManager.tsx
- [x] T169b [US23] Add the watchlists query and mutation hook - dashboard/src/hooks/useWatchlists.ts

### C3 - Optional Email Alert Delivery (HIGH, FR-071)

- [x] T154a [P] [US26] Add unit tests for the email alert-dispatch adapter - apps/notification/test/notification/email_adapter_test.exs
- [x] T154b [P] [US26] Add tests for notification-preference persistence and per-user opt-in - apps/kite_edge/test/kite_edge/settings/notification_preferences_test.exs
- [x] T163c [US26] Implement the Swoosh-based email alert adapter with token-safe templates - apps/notification/lib/notification/email_adapter.ex
- [x] T163d [US26] Implement per-user notification preferences (in-app, email, thresholds) - apps/kite_edge/lib/kite_edge/settings/notification_preferences.ex
- [x] T169c [US26] Extend the alert configuration UI with delivery channel selection - dashboard/src/components/suggestions/AlertChannelSettings.tsx

### C4 - PDF / Printable Export (HIGH, FR-074)

- [x] T172a [P] [US28] Add PDF export generation contract tests - analytics_engine/tests/test_reports_pdf.py
- [x] T176a [US28] Implement PDF tear-sheet export with embedded disclaimer footer - analytics_engine/reports/pdf_export.py
- [x] T182a [US28] Wire PDF export option into the export center UI - dashboard/src/components/reports/ExportCenter.tsx

### I1 - Persisted Indicator Profile & Settings (MEDIUM, FR-023)

- [x] T073a [P] [US9] Add contract and persistence tests for indicator profile read/update/reset - apps/kite_edge/test/kite_edge/settings/indicator_profile_test.exs
- [x] T073b [US9] Implement the indicator profile controller and routes - apps/kite_edge_web/lib/kite_edge_web/controllers/settings/indicator_profile_controller.ex
- [x] T083b [US9] Build the Settings page route and navigation entry hosting indicator, alert, and watchlist preferences - dashboard/src/pages/SettingsPage.tsx
- [x] T083c [US9] Add the settings query and mutation hook - dashboard/src/hooks/useSettings.ts

### I2 - Plan Source Structure Alignment (MEDIUM)

- [x] T170c Update [plan.md](./plan.md) source-structure section to declare `analytics_engine/api/services/` and the dashboard Settings surface - specs/kiteedge/plan.md

### A1 - Split Power BI vs OData Deliverable (MEDIUM, FR-075)

- [x] T177 (amended) [US28] Implement the OData v4 feed endpoint for BI tools - apps/kite_edge_web/lib/kite_edge_web/controllers/reports/odata_controller.ex
- [x] T177a [US28] Implement the Power BI streaming dataset push endpoint - apps/kite_edge_web/lib/kite_edge_web/controllers/reports/powerbi_controller.ex
- [x] T177b [P] [US28] Add contract tests for the OData feed and Power BI push endpoints - apps/kite_edge_web/test/kite_edge_web/controllers/reports/bi_endpoints_test.exs

### Remediation Dependencies

- Disclaimer shared component T055a must land before T055b, T170a, T184a, and T184c.
- Watchlist migration T025a must land before T163a, T163b, and T169a.
- Notification preferences T163d must land before T163c can send email and before T169c surfaces channel selection.
- PDF export T176a must reuse the disclaimer module produced by T184c (or inline equivalent text) to preserve the Principle 8 invariant on generated artifacts.
- T073b depends on the indicator_profile migration introduced in T025a.
- T177b (tests) is gated by T177 and T177a implementation.

### Updated Totals

- Total tasks after remediation: 202 base + 31 addendum = 233.
- New Phase 3 additions: T055a, T055b, T055c.
- New Phase 4 additions: T064a, T073a, T073b, T074a, T074b, T082a, T083a, T083b, T083c.
- New Phase 2 additions: T025a.
- New Phase 8 additions: T154a, T154b, T155a, T163a, T163b, T163c, T163d, T169a, T169b, T169c, T170a, T170b, T170c.
- New Phase 9 additions: T172a, T176a, T177a, T177b, T182a, T184a, T184b, T184c.
- T177 description amended in place (see section A1 above).

## Parallel Example: Portfolio Overview

```text
# Launch the Phase 3 failing tests together:
T036 [US1] Contract tests for holdings endpoint
T037 [US1] End-to-end login-to-holdings flow tests
T038 [US2] Component tests for composition widgets
T039 [US3] Regression tests for holding returns and XIRR
T040 [US4] Contract tests for summary endpoint
T041 [US5] Dividend aggregation tests

# After backend contracts stabilize, build the independent UI pieces together:
T055 [US1] Portfolio overview page
T056 [US2] Allocation chart components
T057 [US3] Holding detail drawer
T058 [US1] Portfolio overview hook and live channel wiring
```

## Parallel Example: Technical Analysis

```text
# Run indicator reference suites together:
T059 [US6] Trend indicator regression tests
T060 [US6] Momentum indicator regression tests
T061 [US6] Volatility, volume, and return indicator regression tests
T062 [US8] Technical summary property-based tests

# Build frontend technical views in parallel once the API contract is stable:
T076 [US7] Candlestick chart component
T077 [US7] Indicator overlays
T078 [US8] Summary gauge
T080 [US9] Indicator configuration panel
T081 [US10] Timeframe comparison component
```

## Implementation Strategy

### MVP First

1. Complete Phase 1.
2. Complete Phase 2.
3. Complete Phase 3.
4. Validate the login, holdings, composition, summary, and dividend flow end to end.
5. Stop for review before broadening to analytics-heavy phases.

### Incremental Delivery

1. Foundation enables real portfolio reads and live ticks.
2. Portfolio Overview establishes the first user-visible product slice.
3. Technical and Risk Analytics add the core analysis differentiators.
4. Forecasting, Trade Analysis, and Suggestions convert analysis into forward-looking decision support.
5. Reporting and Hardening finish the product for durable daily use.

## Notes

- `[P]` tasks touch independent files and can be parallelized safely.
- Story labels map implementation work back to the Phase 1 specification.
- File paths are fixed relative to the repo root so later analysis can trace coverage mechanically.
- The task list stays within the constitutional constraints: no automated trading, no persisted Kite tokens, and mandatory disclaimer propagation for prediction, suggestion, and report surfaces.