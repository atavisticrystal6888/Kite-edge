# KiteEdge Quickstart

## Preconditions

- The local environment has the Gateway API, Market Data service, Analytics Engine, Data
  Pipeline, Dashboard, PostgreSQL, Kafka, and Redis available.
- A valid Zerodha Kite account is available for sign-in.
- Historical data backfill and instrument sync have completed for the sample holdings set.

## 1. Sign in and verify live holdings

1. Open the login page.
2. Complete Kite authorization.
3. Confirm that holdings appear with live profit and loss values.

Expected result:
- Holdings populate within 5 seconds.
- If market data is live, current prices and day profit and loss update automatically.
- If live access is unavailable, the UI shows cached data with a freshness indicator.

## 2. View technical analysis for RELIANCE

1. Search for `RELIANCE`.
2. Open the technical analysis dashboard.
3. Verify that RSI, MACD, and Bollinger Bands are visible on the chart.
4. Confirm the technical summary score and the explanation of contributing factors.

Expected result:
- Indicator values are grouped by category.
- Chart overlays line up with the visible price series.

## 3. View portfolio risk outputs

1. Open the risk dashboard.
2. Review Sharpe ratio, value at risk, and the correlation matrix.
3. Confirm that downside analysis includes a plain-language interpretation.

Expected result:
- Portfolio-level ratios, volatility, and correlation views render without missing fields.
- The risk summary matches the latest synced holdings state.

## 4. Run Monte Carlo simulation

1. Select a 1-month, 3-month, or 1-year horizon.
2. Run the portfolio simulation.
3. Review percentile bands and terminal value distribution.

Expected result:
- The simulation completes within the expected performance range.
- Probability of target-hit and drawdown breach is visible.

## 5. Review daily signals

1. Open the suggestions or signals view.
2. Confirm that at least one active signal is shown with direction, confidence, and rationale.
3. Verify that the page displays the legal disclaimer text.

Expected result:
- Signals are ranked by importance.
- Suggestion outputs do not imply automated order execution.

## 6. Generate a portfolio tear sheet

1. Open the reports section.
2. Request a portfolio tear sheet.
3. Export the report to HTML.

Expected result:
- The report contains performance, drawdown, allocation, and periodic return sections.
- Required legal disclaimer text appears in the report output.

## 7. Verify analytics parity

1. Select a reference portfolio snapshot.
2. Compare Sharpe ratio and related metrics against the approved reference workflow.

Expected result:
- Risk outputs align with the approved reference implementation within the accepted tolerance.
- Any mismatch is surfaced as a verification failure rather than silently accepted.