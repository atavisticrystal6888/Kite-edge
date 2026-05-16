<!--
Sync Impact Report
Version change: none -> 1.0.0
Modified principles:
- Initial adoption from template placeholders to eight project-specific articles
Added sections:
- Additional Constraints
- Development Workflow
Removed sections:
- None
Templates requiring updates:
- ✅ .specify/templates/tasks-template.md
- ✅ .agent/commands/speckit.tasks.md
- ✅ .agent/commands/speckit.constitution.md
- ✅ .specify/templates/plan-template.md (reviewed; no text change required)
- ✅ .specify/templates/spec-template.md (reviewed; no text change required)
Follow-up TODOs:
- None
-->

# KiteEdge Constitution

## Core Principles

### I. Kite API as the Single Source of Truth
- All portfolio data, including holdings, positions, orders, margins, and trades, MUST be
  fetched from Zerodha Kite Connect API v3.
- Historical OHLCV data MUST be fetched through Kite historical endpoints and cached locally
  in PostgreSQL.
- Kite API keys and secrets MUST live only in environment variables. Session tokens MUST
  remain ephemeral and MUST NOT be persisted to source control, database tables, or logs.
- Every Kite API call MUST respect the 3 requests/second limit, use exponential backoff on
  retry, and redact credentials in logs.
- When Kite is unavailable, the platform MUST operate in offline mode using cached data with
  a visible freshness indicator.

Rationale: portfolio truth originates at the broker, and the platform must remain accurate,
auditable, and safe under API failure modes.

### II. Mathematical Rigor & Reproducibility
- Every computation, including indicators, risk metrics, forecasts, and trade analytics, MUST
  be reproducible given identical inputs.
- Statistical methods MUST declare their assumptions, and prediction outputs MUST include
  confidence intervals rather than only point estimates.
- Financial formulas MUST follow their reference definitions from academic or accepted
  practitioner sources.
- Randomized methods, including Monte Carlo workflows, MUST accept a seed parameter.
- Results MUST be validated against approved reference implementations such as scipy,
  QuantStats, and ta within 0.01% deviation unless an explicitly justified exception is
  documented.

Rationale: financial outputs are only useful when they can be reproduced, verified, and
explained under scrutiny.

### III. Test-First Development
- Every implementation task MUST follow Red, Green, Refactor.
- Financial computations MUST include known-answer tests and property-based coverage where
  appropriate.
- Technical indicators MUST be tested against the ta library reference implementation.
- Integration tests that exercise persistence MUST use real PostgreSQL in Docker rather than
  mocks that hide storage behavior.
- Forecasting work MUST include walk-forward validation or equivalent historical backtesting.

Rationale: correctness matters more than throughput for a financial analytics platform, and
TDD is the project control mechanism that keeps changes trustworthy.

### IV. Real-Time & Historical Duality
- The platform MUST support historical batch analysis from stored data and real-time analysis
  from KiteTicker simultaneously.
- Historical and real-time computations MUST yield identical results for the same data window.
- Live dashboard updates MUST use Phoenix Channels or equivalent server push rather than
  polling.
- Tick ingestion, candle aggregation, and quote freshness handling MUST preserve traceability
  from source tick to displayed metric.

Rationale: the user must be able to trust that live views and historical analysis are two
representations of the same underlying math.

### V. Performance & Scalability
- Technical indicator computation MUST finish in under 500 ms per instrument for five years of
  daily data.
- Portfolio risk analysis for a 50-holding portfolio MUST finish in under 10 seconds.
- Dashboard page loads MUST complete in under 2 seconds when pre-computed analytics are
  available.
- Initial backfill of five years of daily data for 500 instruments MUST complete in under
  30 minutes.
- Real-time processing MUST handle 100 instruments at full tick rate without dropping data.

Rationale: the platform is only useful if it can provide mathematically correct results at a
speed that supports daily use and intraday monitoring.

### VI. Simplicity & YAGNI
- v1 MUST prefer rule-based and statistical methods before introducing unnecessary ML
  complexity.
- The platform MUST remain analytics-only and MUST NOT place, modify, or cancel trades
  programmatically.
- Options and F&O analytics are out of scope for v1.
- v1 MUST stay within six services unless written justification is approved.
- Established libraries such as ta, QuantStats, scipy, statsmodels, and prophet MUST be used
  where they satisfy the requirement.

Rationale: limiting scope keeps the system understandable, supportable, and aligned with the
actual personal-tool use case.

### VII. Security & Compliance
- Kite secrets and access tokens MUST NEVER appear in logs, API responses, or persisted
  database rows.
- All communication with Kite MUST use HTTPS.
- Portfolio data MUST stay within the self-hosted environment, and third-party analytics
  services MUST NOT receive it.
- The system MUST handle daily Kite session expiry with an explicit re-authentication flow.
- Sensitive data handling changes MUST include impact analysis before they are merged.

Rationale: a personal finance platform fails its purpose if it leaks credentials or portfolio
information while providing analytics.

### VIII. Observability
- Every service MUST emit structured JSON logs.
- Every service MUST expose health check endpoints.
- The platform MUST capture Kite API metrics, including success rate, latency, and rate-limit
  headroom.
- The platform MUST capture computation metrics, including indicator latency, analysis time,
  and cache hit rates.
- Every dashboard component that displays market or analytics data MUST surface freshness
  information.

Rationale: observability is required to diagnose data drift, API failures, stale caches, and
performance regressions before they become user-visible defects.

## Additional Constraints

- KiteEdge is a self-hosted, single-user portfolio intelligence platform. Multi-tenant
  behavior is out of scope for v1.
- The system is analytics-only. It MUST NOT place, modify, or cancel trades programmatically.
- The following legal disclaimers MUST appear on every prediction page, every suggestion page,
  every report, and the login page footer:
  - "This tool is for informational purposes only. It does not constitute investment advice."
  - "Past performance does not guarantee future results."
  - "Predictions are statistical projections with inherent uncertainty."
  - "Always consult a qualified financial advisor before making investment decisions."
- Offline mode MUST expose data staleness clearly rather than implying live market freshness.
- The following are out of scope for v1: options and F&O analytics, intraday tick-by-tick
  backtesting, portfolio optimization solvers, social features, mobile apps, multi-broker
  support, news sentiment analysis, and cloud-hosted portfolio analytics.

## Development Workflow

- Work MUST proceed through seven sequential SDD phases: Constitution, Specification,
  Implementation Plan, Tasks, Analyze, Implement, and Verify.
- Each phase MUST produce its complete artifact set before the next phase begins.
- After every phase, the executor MUST stop and request approval with the exact gate:
  "Phase N complete. Ready for Phase N+1. Proceed? [Y/N]"
- Specification artifacts MUST lead implementation. Code MUST NOT begin before analysis is
  complete and approved.
- Every implementation task MUST start with a failing test, proceed to a passing change, and
  end with refactoring where appropriate.
- Financial calculations, forecasts, and risk metrics MUST be cross-checked against approved
  reference implementations before they are treated as complete.
- Constitution compliance MUST be checked in planning, analysis, implementation, and
  verification outputs.

## Governance

- This constitution supersedes conflicting guidance in prompts, plans, tasks, and
  implementation details. Conflicts MUST be resolved in favor of the constitution or by a
  formal amendment.
- Until the toolchain converges on a single location, the authoritative constitution text MUST
  remain identical in `.specify/memory/constitution.md` and `specs/kiteedge/constitution.md`.
- Amendments MUST include written rationale, affected artifact paths, impact analysis, and a
  Sync Impact Report.
- Versioning follows semantic versioning:
  - MAJOR for removing or redefining a principle or governance rule.
  - MINOR for adding a principle, section, or materially expanding mandatory guidance.
  - PATCH for clarifications, wording cleanups, or typo fixes that do not change governance.
- Compliance review is mandatory for every phase artifact and change set. Reviews MUST confirm
  TDD evidence, token-handling compliance, disclaimer placement, observability coverage, and
  reference-validation coverage where applicable.

**Version**: 1.0.0 | **Ratified**: 2026-04-16 | **Last Amended**: 2026-04-16