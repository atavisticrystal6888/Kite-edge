# Feature Specification: KiteEdge Portfolio Intelligence Platform

**Feature Branch**: `kiteedge`  
**Created**: 2026-04-16  
**Status**: Draft  
**Input**: User description: "Build KiteEdge, a self-hosted portfolio intelligence platform for Zerodha Kite users, and execute the specification phase as defined by the KiteEdge master prompt."

## Product Vision

KiteEdge is a self-hosted portfolio intelligence platform for Zerodha Kite users. It turns
brokerage data into actionable insights through portfolio analysis, technical signals, risk
measurement, forecasting, trade performance review, and reporting. It is intended to answer
the questions serious investors repeatedly ask but cannot answer quickly from a default
broker interface:

- What is my portfolio's true risk-adjusted return?
- Which holdings are weakening even if they still look profitable?
- What is my likely downside tomorrow under normal or stressed conditions?
- How diversified is my portfolio in practice, not just by count of holdings?
- Which sectors and market-cap buckets am I overexposed to?
- How would my portfolio behave in a repeat of a historic crash?
- Are my recent trades improving overall portfolio quality or harming it?

## Target Personas

1. **Active Retail Investor**: Maintains 15 to 50 holdings, trades regularly, and wants a
   daily decision-support workspace instead of manual spreadsheets.
2. **Swing Trader**: Holds positions for days to weeks and needs technical signals,
   chart-based context, and timing-oriented alerts.
3. **Long-Term Investor**: Holds positions for months or years and needs allocation,
   drawdown, risk, and rebalancing insight.
4. **Aspiring Quant**: Wants to understand portfolio math and predictive analysis through
   transparent outputs on real holdings.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Connect Kite Account and View Live Holdings (Priority: P1)

The user authorizes their Zerodha account and immediately sees current holdings with live
profit and loss values.

**Why this priority**: The product has no value until the user's portfolio data is visible.

**Independent Test**: Complete account authorization with a valid account and confirm that the
holdings screen populates with live prices and current profit and loss values.

**Acceptance Scenarios**:

1. **Given** a user has a valid Zerodha account, **When** they complete account
   authorization, **Then** KiteEdge displays their current holdings with live profit and loss
   values.

### User Story 2 - Review Portfolio Composition (Priority: P1)

The user views sector allocation, market-cap distribution, top holdings by weight, and
concentration risk for the current portfolio.

**Why this priority**: Users need a fast overview of concentration and diversification before
drilling into advanced analytics.

**Independent Test**: Open the portfolio overview and confirm composition charts and
concentration metrics reflect the current holdings set.

**Acceptance Scenarios**:

1. **Given** holdings have been synced, **When** the user opens the overview dashboard,
   **Then** the system shows sector allocation, market-cap split, top holdings, and
   concentration risk.

### User Story 3 - Inspect Per-Holding Performance (Priority: P1)

The user opens any holding and sees cost basis, current price, absolute and percentage profit
and loss, holding period, annualized return, and XIRR.

**Why this priority**: Users need instrument-level accountability before trusting portfolio
totals.

**Independent Test**: Select a holding with multiple transactions and verify that detailed
performance metrics are available for that single position.

**Acceptance Scenarios**:

1. **Given** a synced holding with transaction history, **When** the user opens holding
   details, **Then** the system shows cost, current value, holding period, annualized return,
   and XIRR.

### User Story 4 - Review Portfolio Summary Metrics (Priority: P1)

The user sees total invested value, current value, total profit and loss, daily profit and
loss, CAGR, and portfolio XIRR in a single summary view.

**Why this priority**: A portfolio-level summary is the daily landing view for the core user.

**Independent Test**: Open the summary view and confirm all aggregate portfolio metrics are
present and aligned with the underlying holdings.

**Acceptance Scenarios**:

1. **Given** a populated holdings set, **When** the user opens the portfolio summary,
   **Then** the system displays the total invested amount, current value, total return,
   daily return, CAGR, and portfolio XIRR.

### User Story 5 - Track Dividend Income (Priority: P1)

The user reviews dividend income, dividend yield, and dividend contribution by holding.

**Why this priority**: Long-term investors need total-return context, not only price return.

**Independent Test**: Open dividend tracking and verify dividend totals and yields are
available wherever source data supports them.

**Acceptance Scenarios**:

1. **Given** the portfolio includes dividend-paying holdings, **When** the user opens the
   dividend view, **Then** the system shows dividend income and yield by holding and in total.

### User Story 6 - View Comprehensive Technical Analysis (Priority: P2)

The user selects any supported instrument and sees a technical analysis dashboard covering
trend, momentum, volatility, and volume indicators.

**Why this priority**: Technical analysis is a core reason swing traders and active investors
would use KiteEdge beyond a holdings dashboard.

**Independent Test**: Analyze one supported instrument and confirm that the dashboard shows
all indicator categories with current values and interpretations.

**Acceptance Scenarios**:

1. **Given** an instrument with sufficient price history, **When** the user opens the
   technical dashboard, **Then** the system displays the full indicator set grouped by
   category.

### User Story 7 - Analyze Charts with Overlays (Priority: P2)

The user studies an interactive candlestick chart with indicator overlays, support and
resistance context, and user drawing tools.

**Why this priority**: Signals are more useful when the user can see them in price context.

**Independent Test**: Open an instrument chart, enable overlays, and verify the user can
inspect price action alongside the derived signals.

**Acceptance Scenarios**:

1. **Given** an instrument chart is open, **When** the user enables overlays and analysis
   aids, **Then** the chart reflects indicators, support or resistance context, and drawing
   interactions.

### User Story 8 - Use a Technical Summary Score (Priority: P2)

The user sees a single summary rating that combines the broader technical picture into a
strong buy to strong sell recommendation band.

**Why this priority**: A condensed score helps users triage where to investigate first.

**Independent Test**: Compare multiple instruments and verify each one exposes a summary score
with an explanation of the signal direction.

**Acceptance Scenarios**:

1. **Given** technical analysis is available for an instrument, **When** the user opens the
   summary panel, **Then** the system shows a consolidated technical score with its banded
   recommendation.

### User Story 9 - Customize Indicator Parameters (Priority: P2)

The user changes indicator inputs, such as lookback periods, and sees the analysis refresh
for that configuration.

**Why this priority**: Active users need the ability to adapt analysis to their own trading
style.

**Independent Test**: Change one default indicator parameter and verify the resulting
technical values update for the selected instrument.

**Acceptance Scenarios**:

1. **Given** a user is reviewing technical analysis, **When** they change an indicator
   parameter, **Then** the system recalculates and presents the analysis for that selection.

### User Story 10 - Compare Multiple Timeframes (Priority: P2)

The user compares daily, weekly, and monthly technical conditions for the same instrument.

**Why this priority**: Multi-timeframe confirmation is a common decision pattern for traders.

**Independent Test**: Open one instrument and verify that daily, weekly, and monthly views can
be compared side by side.

**Acceptance Scenarios**:

1. **Given** an instrument has sufficient data history, **When** the user requests a
   multi-timeframe view, **Then** the system shows technical analysis for each selected
   timeframe in a comparable layout.

### User Story 11 - Review Portfolio Risk Dashboard (Priority: P3)

The user opens a risk dashboard showing risk-adjusted returns, volatility, benchmark-relative
metrics, and drawdown statistics.

**Why this priority**: Portfolio health is incomplete without risk context.

**Independent Test**: Open the risk dashboard and confirm that the portfolio's core risk and
performance ratios are displayed together.

**Acceptance Scenarios**:

1. **Given** the portfolio has enough return history, **When** the user opens the risk
   dashboard, **Then** the system shows risk-adjusted return metrics, volatility, beta,
   alpha, and drawdown measures.

### User Story 12 - Measure Value at Risk (Priority: P3)

The user sees expected downside at multiple confidence levels through historical, parametric,
and simulation-based views.

**Why this priority**: Downside framing is one of the most actionable portfolio questions.

**Independent Test**: Run value-at-risk analysis and verify the output includes confidence
levels, multiple calculation views, and a plain-language downside statement.

**Acceptance Scenarios**:

1. **Given** a portfolio has sufficient historical data, **When** the user requests value at
   risk analysis, **Then** the system shows downside estimates for configured confidence
   levels and explains the result in plain language.

### User Story 13 - Inspect Correlation and Diversification (Priority: P3)

The user views a correlation heatmap that reveals which holdings move together and which ones
provide diversification.

**Why this priority**: Concentration by correlation is often invisible in simple allocation
views.

**Independent Test**: Open the correlation view and verify pairwise relationships across the
current holdings set.

**Acceptance Scenarios**:

1. **Given** a portfolio contains multiple holdings, **When** the user opens the correlation
   view, **Then** the system displays a heatmap that highlights highly correlated and weakly
   correlated pairs.

### User Story 14 - Run Stress Tests (Priority: P3)

The user models the portfolio under historic crash scenarios and custom market shocks.

**Why this priority**: Users need to understand downside behavior outside normal ranges.

**Independent Test**: Apply one historic scenario and one custom shock and verify the system
shows expected portfolio impact and per-holding contribution.

**Acceptance Scenarios**:

1. **Given** a portfolio is available for analysis, **When** the user runs a stress test,
   **Then** the system reports projected portfolio impact and holding-level effects.

### User Story 15 - Simulate Future Portfolio Paths (Priority: P3)

The user explores simulated future paths for the portfolio and the probability of meeting or
missing return targets.

**Why this priority**: Simulation translates abstract risk into forward-looking decision
support.

**Independent Test**: Run a simulation for at least one horizon and confirm the system shows
path ranges and target-hit probabilities.

**Acceptance Scenarios**:

1. **Given** historical return data is available, **When** the user runs a forward
   simulation, **Then** the system shows a range of future portfolio paths and associated
   outcome probabilities.

### User Story 16 - View Instrument Price Forecasts (Priority: P4)

The user sees short-term price forecasts with confidence intervals for a selected instrument.

**Why this priority**: Forecasting is a differentiating capability that extends the platform
from analysis into forward-looking insight.

**Independent Test**: Open a forecast for one instrument and confirm forecast ranges and the
required disclaimer are displayed.

**Acceptance Scenarios**:

1. **Given** a supported instrument has adequate history, **When** the user requests a price
   forecast, **Then** the system shows forecast ranges for the selected horizons together with
   the required legal disclaimer.

### User Story 17 - Review Trend Prediction Signals (Priority: P4)

The user sees predictive signals such as crossovers, divergences, and volatility squeeze
setups.

**Why this priority**: Many users need interpretable signals rather than raw forecasts alone.

**Independent Test**: Open the prediction signals view and verify that active signals are
shown with their supporting rationale.

**Acceptance Scenarios**:

1. **Given** predictive analysis has been run, **When** the user opens the signal feed,
   **Then** the system lists current predictive signals with plain-language rationale.

### User Story 18 - Forecast Portfolio Returns (Priority: P4)

The user views expected portfolio return ranges and probability distributions across multiple
future horizons.

**Why this priority**: Users need to understand forecast implications at the portfolio level,
not just per instrument.

**Independent Test**: Run a portfolio forecast and confirm the system returns expected ranges,
distribution insight, and horizon options.

**Acceptance Scenarios**:

1. **Given** the portfolio has historical return data, **When** the user requests a
   portfolio forecast, **Then** the system shows expected return ranges and probability
   distributions for selected horizons.

### User Story 19 - Review Trade History (Priority: P5)

The user views a complete history of executed trades with time, price, quantity, side, and
trade-level profit and loss context.

**Why this priority**: Trade review is the foundation for all execution and performance
analysis.

**Independent Test**: Open the trade history page and verify that executed trades are listed
with enough detail for review.

**Acceptance Scenarios**:

1. **Given** the brokerage account contains completed trades, **When** the user opens trade
   history, **Then** the system displays the full executed trade ledger with essential trade
   details.

### User Story 20 - Measure Trading Performance (Priority: P5)

The user evaluates win rate, average gain and loss, expectancy, streaks, and time-based trade
patterns.

**Why this priority**: Users need performance feedback on trading behavior, not just portfolio
mark-to-market returns.

**Independent Test**: Open the trade performance view and verify that summary metrics and
pattern breakdowns are available.

**Acceptance Scenarios**:

1. **Given** trade history exists, **When** the user opens trade performance analytics,
   **Then** the system shows aggregate and pattern-based trading metrics.

### User Story 21 - Assess Execution Quality (Priority: P5)

The user measures slippage, execution quality, and whether trades could have been filled more
efficiently.

**Why this priority**: Poor execution can erase good decision-making, so users need feedback
on trade quality.

**Independent Test**: Open execution quality analysis and verify that slippage and fill
quality measures are shown for completed trades.

**Acceptance Scenarios**:

1. **Given** trade fills are available, **When** the user reviews execution quality,
   **Then** the system displays slippage and best-execution analysis for relevant trades.

### User Story 22 - View Rolling Trade Performance (Priority: P5)

The user reviews equity curve progression, rolling returns, and drawdown across time.

**Why this priority**: Rolling analysis helps users connect isolated trades to broader trading
discipline.

**Independent Test**: Open the rolling performance view and confirm that cumulative and
rolling performance visuals are available.

**Acceptance Scenarios**:

1. **Given** trade performance has been calculated, **When** the user opens rolling
   performance, **Then** the system shows cumulative returns, drawdown, and rolling quality
   metrics over time.

### User Story 23 - Review Daily Screening Signals (Priority: P6)

The user receives daily signal cards across holdings and watchlist instruments.

**Why this priority**: Signals convert analysis into a daily decision-support workflow.

**Independent Test**: Open the screening view and confirm that current opportunities and risk
signals are ranked and explained.

**Acceptance Scenarios**:

1. **Given** holdings or watchlist instruments are available, **When** the daily screening
   process runs, **Then** the system produces signal cards with rationale and direction.

### User Story 24 - Get Rebalancing Suggestions (Priority: P6)

The user compares current allocation with a target allocation and sees the trades needed to
rebalance.

**Why this priority**: Rebalancing suggestions turn portfolio insight into specific next
actions.

**Independent Test**: Open the rebalancing view and verify that current allocation,
target allocation, and required trade suggestions are shown together.

**Acceptance Scenarios**:

1. **Given** a target allocation exists, **When** the user runs rebalancing analysis,
   **Then** the system shows allocation gaps and the trades needed to close them.

### User Story 25 - Improve Diversification (Priority: P6)

The user sees suggestions for reducing sector, correlation, and market-cap concentration.

**Why this priority**: Diversification advice is one of the clearest high-value outputs for a
portfolio intelligence product.

**Independent Test**: Open diversification suggestions and verify that the system identifies
concentration issues and proposes improvement directions.

**Acceptance Scenarios**:

1. **Given** the portfolio exhibits concentration, **When** the user opens diversification
   analysis, **Then** the system highlights the risk and suggests how to improve balance.

### User Story 26 - Receive Alerts (Priority: P6)

The user receives technical, portfolio, and risk alerts in-app and optionally by email.

**Why this priority**: Alerts keep the product useful between active review sessions.

**Independent Test**: Configure one alert and verify that the user receives the alert through
the selected channel when the trigger condition occurs.

**Acceptance Scenarios**:

1. **Given** an alert rule has been configured, **When** the rule condition is met,
   **Then** the system delivers an alert to the user in the configured channel.

### User Story 27 - Generate a Portfolio Tear Sheet (Priority: P7)

The user generates a report that summarizes portfolio performance, risk, drawdowns, and
monthly return patterns in a presentation-ready format.

**Why this priority**: Reporting extends the platform from analysis to record keeping and
periodic review.

**Independent Test**: Generate a tear sheet and confirm that the resulting report includes the
expected portfolio sections and is exportable.

**Acceptance Scenarios**:

1. **Given** portfolio analytics are available, **When** the user generates a tear sheet,
   **Then** the system produces a report covering performance, risk, drawdowns, and monthly
   return context.

### User Story 28 - Export Analysis Outputs (Priority: P7)

The user exports analysis views to spreadsheet, flat-file, and printable report formats.

**Why this priority**: Users need to move their analysis into external review, archives, and
other decision tools.

**Independent Test**: Export at least one dashboard view into each supported format and verify
that the resulting files are usable.

**Acceptance Scenarios**:

1. **Given** an analysis view is available, **When** the user requests an export,
   **Then** the system generates the selected output format for download or handoff.

### User Story 29 - Receive Scheduled Performance Reports (Priority: P7)

The user reviews automatically generated monthly or quarterly performance reports.

**Why this priority**: Scheduled summaries reinforce continuous portfolio review without
manual effort.

**Independent Test**: Trigger scheduled reporting and verify that the user can access the
periodic performance report with benchmark and attribution context.

**Acceptance Scenarios**:

1. **Given** scheduled reporting is enabled, **When** a reporting period closes,
   **Then** the system generates a performance report for that period and makes it available
   to the user.

### Edge Cases

- What happens when a stock in holdings is delisted, suspended, merged, or renamed?
- How are stock splits, bonus issues, rights issues, and other corporate actions reflected in
  return calculations and historical comparisons?
- How is XIRR computed when a holding has multiple buys, partial sells, and dividend cash
  flows?
- What does the user see during market holidays, auctions, and after-hours periods?
- How are the same companies handled across multiple exchanges, including NSE and BSE symbols?
- What happens if the user's brokerage session expires during an active session?
- How are mutual fund holdings surfaced when they are present through the linked brokerage
  ecosystem?
- How are closed intraday positions distinguished from delivery holdings and ongoing positions?
- How does the product behave when insufficient historical data exists for a requested
  analysis?
- How is stale cached data flagged during temporary upstream outages?
- What happens when a user-defined watchlist instrument no longer trades or becomes
  unsupported?
- How are prediction and suggestion views constrained so that out-of-scope F&O instruments do
  not appear in v1 workflows?

## Requirements *(mandatory)*

### Functional Requirements

#### Kite Integration

- **FR-001**: The system MUST allow a user to authorize a Zerodha Kite account and establish a
  valid signed-in session.
- **FR-002**: The system MUST retrieve the user's current holdings after authorization.
- **FR-003**: The system MUST retrieve the user's open and day positions after authorization.
- **FR-004**: The system MUST retrieve the user's executed orders and trade history required
  for trade analysis.
- **FR-005**: The system MUST retrieve and retain sufficient historical market data for
  holdings and watchlist instruments to support all analytics in scope.
- **FR-006**: The system MUST present live quote updates for holdings and watchlist
  instruments during market hours.
- **FR-007**: The system MUST notify the user when brokerage authorization expires or becomes
  invalid and require re-authentication before further protected actions.
- **FR-008**: The system MUST protect the user experience from upstream request throttling by
  managing request pacing, retries, and graceful degradation.
- **FR-009**: The system MUST keep the supported instrument universe current for the exchanges
  and instruments in scope.
- **FR-010**: The system MUST recognize trading calendars, market holidays, and closed-market
  states when presenting live or stale data.

#### Technical Analysis

- **FR-011**: The system MUST compute and present at least 43 technical indicators spanning
  trend, momentum, volatility, volume, and return categories.
- **FR-012**: The system MUST present current indicator values together with plain-language
  interpretation where applicable.
- **FR-013**: The system MUST allow a user to change supported indicator parameters.
- **FR-014**: The system MUST support analysis across intraday, daily, weekly, and monthly
  timeframes.
- **FR-015**: The system MUST produce a technical summary score for each analyzed instrument.
- **FR-016**: The system MUST explain the contributing factors behind the technical summary
  score.
- **FR-017**: The system MUST identify support and resistance levels for analyzed instruments.
- **FR-018**: The system MUST identify major candlestick patterns relevant to user decisions.
- **FR-019**: The system MUST provide an interactive price chart with selectable overlays and
  studies.
- **FR-020**: The system MUST support chart annotations such as trend lines, channels, and
  retracement guides.
- **FR-021**: The system MUST allow side-by-side comparison of multiple timeframes for the same
  instrument.
- **FR-022**: The system MUST allow users to analyze supported instruments that are not already
  in the current holdings set.
- **FR-023**: The system MUST preserve user-selected technical analysis settings across
  sessions.
- **FR-024**: The system MUST organize technical outputs by indicator category so users can
  scan them quickly.
- **FR-025**: The system MUST clearly indicate when an instrument lacks enough data for a
  specific technical output.

#### Risk Analytics

- **FR-026**: The system MUST calculate and present the portfolio's Sharpe ratio.
- **FR-027**: The system MUST calculate and present the portfolio's Sortino ratio.
- **FR-028**: The system MUST calculate and present the portfolio's Calmar ratio.
- **FR-029**: The system MUST calculate and present the portfolio's Information ratio against a
  selected benchmark.
- **FR-030**: The system MUST calculate and present benchmark-relative beta and alpha.
- **FR-031**: The system MUST calculate and present the portfolio's Treynor ratio.
- **FR-032**: The system MUST calculate and present rolling volatility across multiple lookback
  windows.
- **FR-033**: The system MUST calculate and present maximum drawdown depth, duration, and
  recovery context.
- **FR-034**: The system MUST calculate and present historical value at risk at supported
  confidence levels.
- **FR-035**: The system MUST calculate and present parametric value at risk at supported
  confidence levels.
- **FR-036**: The system MUST calculate and present conditional value at risk or expected
  shortfall.
- **FR-037**: The system MUST calculate and present simulation-based value at risk.
- **FR-038**: The system MUST express downside analysis in plain language that states the
  probability of exceeding a specified loss threshold.
- **FR-039**: The system MUST calculate and present portfolio correlation views, including
  static and time-varying relationships.
- **FR-040**: The system MUST calculate and present covariance and holding-level marginal risk
  contribution.
- **FR-041**: The system MUST support both historic and custom scenario-based stress tests.
- **FR-042**: The system MUST simulate forward portfolio paths over supported future horizons
  and report outcome probabilities.

#### Predictions & Forecasting

- **FR-043**: The system MUST generate short-term price forecasts using at least one
  autoregressive time-series method.
- **FR-044**: The system MUST generate short-term price forecasts using at least one
  seasonality-aware forecasting method.
- **FR-045**: The system MUST present a combined forecast view that reflects multiple forecast
  methods together.
- **FR-046**: The system MUST present confidence intervals for forecast outputs.
- **FR-047**: The system MUST track and present forecast accuracy over time.
- **FR-048**: The system MUST detect and present moving-average crossover signals.
- **FR-049**: The system MUST detect and present price-versus-indicator divergence signals.
- **FR-050**: The system MUST detect and present volatility squeeze and breakout-setup signals.
- **FR-051**: The system MUST detect and present volume-price divergence signals.
- **FR-052**: The system MUST generate portfolio-level forward return forecasts across
  supported time horizons.

#### Trade Analysis & Performance

- **FR-053**: The system MUST present the complete in-scope executed trade history for the
  connected account.
- **FR-054**: The system MUST calculate per-trade profit and loss using a documented cost-basis
  method.
- **FR-055**: The system MUST calculate and present win rate, average gain, average loss, and
  expectancy.
- **FR-056**: The system MUST calculate and present consecutive win and loss streak metrics.
- **FR-057**: The system MUST analyze and present holding-period differences between profitable
  and unprofitable trades.
- **FR-058**: The system MUST analyze and present trade outcomes by time period, including day,
  week, month, and time-of-day views where data is available.
- **FR-059**: The system MUST calculate and present slippage for trades with sufficient price
  context.
- **FR-060**: The system MUST evaluate whether completed trades could have achieved better fill
  outcomes within the same decision window.
- **FR-061**: The system MUST present cumulative trade performance, equity-curve progression,
  and trade-specific drawdown context.
- **FR-062**: The system MUST compare trading outcomes with a relevant buy-and-hold benchmark.

#### Suggestions, Alerts, and Reporting

- **FR-063**: The system MUST scan holdings and watchlist instruments for actionable technical
  or risk conditions.
- **FR-064**: The system MUST present suggestion outputs with direction, confidence, and plain-
  language rationale.
- **FR-065**: The system MUST rank or prioritize suggestions so users can review the most
  important opportunities first.
- **FR-066**: The system MUST compare current allocation with a selected target allocation and
  present rebalancing suggestions.
- **FR-067**: The system MUST identify holdings that may qualify as tax-loss harvesting
  opportunities.
- **FR-068**: The system MUST analyze diversification gaps across sector, correlation, and
  market-cap dimensions and present improvement suggestions.
- **FR-069**: The system MUST allow a user to define alert conditions for price, technical,
  and risk events.
- **FR-070**: The system MUST allow users to manage custom watchlists for screening and alert
  workflows.
- **FR-071**: The system MUST deliver alerts in-app and optionally through email.
- **FR-072**: The system MUST generate a portfolio tear sheet that summarizes performance,
  risk, drawdowns, and periodic return patterns.
- **FR-073**: The system MUST export supported analyses to spreadsheet format.
- **FR-074**: The system MUST export supported analyses to flat-file and printable report
  formats.
- **FR-075**: The system MUST provide reporting outputs suitable for external business
  intelligence consumption.
- **FR-076**: The system MUST generate monthly or quarterly performance reports without manual
  reconstruction of the portfolio narrative.

### Non-Functional Requirements

- **NFR-001**: Technical analysis for a single instrument over five years of daily data MUST be
  available in under 500 milliseconds for standard requests.
- **NFR-002**: Full portfolio risk analysis for a 50-holding portfolio MUST be available in
  under 10 seconds.
- **NFR-003**: A 10,000-path portfolio simulation for a 50-asset portfolio MUST complete in
  under 30 seconds.
- **NFR-004**: Primary dashboard views MUST load in under 2 seconds when previously prepared
  portfolio analytics are available.
- **NFR-005**: Initial historical backfill for 500 instruments across five years of daily data
  MUST complete within 30 minutes.
- **NFR-006**: Live market processing MUST support 100 actively tracked instruments without
  data loss.
- **NFR-007**: Live quotes displayed to the user MUST refresh within 2 seconds of upstream
  market movement under normal connectivity.
- **NFR-008**: The product MUST remain usable in offline mode with clearly marked stale data
  whenever live brokerage access is unavailable.
- **NFR-009**: Supported calculations MUST produce reproducible outputs when run on identical
  inputs and seeds.
- **NFR-010**: XIRR and related holding-return calculations MUST match accepted financial
  reference results within 0.01%.

### Key Entities *(include if feature involves data)*

- **Instrument**: A tradable security that can appear in holdings, watchlists, charts, or
  reports.
- **Instrument Master**: The canonical catalog of supported tradable instruments, exchanges,
  and symbol mappings.
- **Exchange**: A market venue such as NSE or BSE used to distinguish instruments and market
  schedules.
- **Trading Calendar**: A market schedule that defines trading sessions, holidays, and closed
  states.
- **Holding**: A long-term portfolio position with quantity, average cost, current value, and
  return context.
- **Position**: A current tradable position that may be intraday or carry-forward and may not
  match holding behavior.
- **Order**: A brokerage instruction record associated with submitted or executed activity.
- **Trade**: A completed execution event used for performance and execution analysis.
- **Fill**: A granular execution component of a trade needed to understand actual execution
  quality.
- **OHLCV Candle**: A time-bucketed price record used for charting and analytics.
- **Tick Data**: A live market update record used for real-time prices and intraday
  aggregation.
- **Real-Time Quote**: The current user-facing market snapshot for an instrument.
- **Technical Indicator Result**: A computed indicator value and interpretation for a specific
  instrument, timeframe, and parameter set.
- **Technical Summary Score**: A condensed rating representing the overall technical posture of
  an instrument.
- **Candlestick Pattern**: A detected chart pattern that may contribute to analysis or signals.
- **Portfolio Snapshot**: A time-specific view of holdings, exposures, and aggregated value.
- **Portfolio Metric**: A summarized portfolio-level statistic such as total return, CAGR, or
  concentration risk.
- **Risk Metric**: A computed measure of downside, volatility, relative performance, or risk
  contribution.
- **Correlation Matrix**: A pairwise relationship view across holdings or watchlist instruments.
- **Stress Test Scenario**: A defined market shock or historic event used for scenario analysis.
- **Stress Test Result**: The projected portfolio and holding-level impact of a selected
  scenario.
- **Monte Carlo Simulation**: A forward-looking simulated distribution of potential portfolio
  paths.
- **Forecast Model**: A forecast method used to generate a time-based market expectation.
- **Forecast Result**: A predicted range, point estimate, and uncertainty band for an
  instrument or portfolio.
- **Forecast Accuracy Metric**: A measure that tracks how well forecast outputs matched later
  observed outcomes.
- **Trade Performance Metric**: A summary statistic describing trading effectiveness over time.
- **Execution Quality Metric**: A measure of slippage, timing quality, or fill efficiency.
- **Signal**: A generated analytical condition intended to support a user decision.
- **Alert Rule**: A user-defined condition that determines when an alert should fire.
- **Alert**: A delivered notification that a configured or system-generated condition has been
  met.
- **Watchlist**: A user-curated list of instruments for analysis, screening, and alerts.
- **Rebalance Suggestion**: A recommended allocation adjustment from current to target state.
- **Diversification Analysis**: A structured view of concentration gaps and improvement
  opportunities.
- **Report**: A generated output that packages portfolio analysis for review or sharing.
- **Export Job**: A requested analysis output in a portable file or external-consumption
  format.
- **Tear Sheet**: A report-focused artifact summarizing portfolio performance and risk.
- **User Session**: The authenticated access context for the single-user system.
- **Kite Token**: An ephemeral brokerage session credential that must never be persisted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can complete account authorization and see holdings within 5 seconds of
  successful sign-in.
- **SC-002**: Approved benchmark datasets produce technical outputs that match trusted
  reference calculations within 0.1% or the documented tolerance for that metric.
- **SC-003**: Portfolio risk outputs for Sharpe ratio, Sortino ratio, value at risk, and
  drawdown match trusted reference calculations within 0.1% on benchmark datasets.
- **SC-004**: Thirty-day price forecasts achieve mean absolute percentage error below 5% for a
  defined benchmark basket during backtested evaluation.
- **SC-005**: A user can generate a portfolio tear sheet in under 5 seconds after selecting
  the report action.
- **SC-006**: Live profit and loss views reflect new market movement within 2 seconds during
  normal market-hour connectivity.
- **SC-007**: In first-use testing, users identify at least 3 actionable insights within
  5 minutes of completing their first successful login.

## Assumptions

- KiteEdge is a single-user, self-hosted product for one portfolio owner and does not require
  multi-tenant behavior in v1.
- The user has an active Zerodha Kite account with sufficient permissions to access holdings,
  orders, trades, and market data used by the product.
- Direct equity is the primary focus of v1, while options and F&O analytics remain out of
  scope.
- The default portfolio benchmark is NIFTY 50 unless the user selects another supported
  benchmark where available.
- Brokerage and market data sources provide enough information to support corporate-action-
  adjusted performance where required.
- Mutual fund data is included only where it is exposed consistently enough to support the
  relevant analysis view.
- The product remains analytics-only and does not perform automated trading or order
  execution.
- Prediction and suggestion views always carry the required legal disclaimers defined by the
  constitution.