# Specification Analysis Report

**Last updated**: Phase 4 Remediation pass applied. See the "Remediation Addendum" in [tasks.md](./tasks.md) and the per-artifact edits below. Original findings retained for audit.

## Remediation Status (Post-Edit)

| ID | Original Severity | Status | Evidence |
|----|-------------------|--------|----------|
| D1 | CRITICAL | RESOLVED | Added T055a (shared Disclaimer component), T055b-c (login footer + test), T170a-b (suggestion banner + test), T184a-c (report banner, test, export-embedded disclaimer). Covers Constitution Principle 8 on login, prediction (pre-existing T117/T131), suggestion, and report surfaces. |
| C1 | HIGH | RESOLVED | Added T064a (contract tests), T074a-b (query service + controller), T082a (hook), T083a (search UI) for FR-022 non-holding instrument search, quote, and OHLCV. |
| C2 | HIGH | RESOLVED | Added T025a (migration), T155a (tests), T163a-b (context + controller), T169a-b (UI + hook) for FR-070 watchlist CRUD. |
| C3 | HIGH | RESOLVED | Added T154a-b (tests), T163c (Swoosh adapter), T163d (notification preferences), T169c (channel UI) for FR-071 optional email delivery. |
| C4 | HIGH | RESOLVED | Added T172a (tests), T176a (PDF export with disclaimer footer), T182a (export center wiring) for FR-074 printable export. |
| I1 | MEDIUM | RESOLVED | Added `indicator_profiles` and `notification_preferences` tables to [data-model.md](./data-model.md); added T073a-b (tests + controller), T083b-c (Settings page + hook), T025a (migration). |
| I2 | MEDIUM | RESOLVED | Added "Source Structure Addenda" section to [plan.md](./plan.md) declaring `analytics_engine/api/services/`, `dashboard/src/pages/SettingsPage.tsx`, `apps/kite_edge/lib/kite_edge/settings/`, and `apps/notification/lib/notification/email_adapter.ex`. T170c tracks the plan edit explicitly. |
| A1 | MEDIUM | RESOLVED | Amended T177 description in place to OData v4 only; added T177a (Power BI push) and T177b (contract tests). |
| I3 | LOW | RESOLVED | [spec.md](./spec.md) header normalized from `kiteedge-phase-1` to `kiteedge`. |

**Updated metrics:**

- Total requirements: 82
- Total tasks: 202 base + 31 addendum = 233
- Coverage % (requirements with >=1 task): 100% (82 / 82)
- Critical issues open: 0
- High issues open: 0
- Medium issues open: 0
- Ambiguity count: 0
- Duplication count: 0

**Remaining verification before `/speckit.implement`:**

1. Re-run `check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` to confirm the expanded task set still resolves cleanly.
2. Cross-check the disclaimer copy in T055a against the constitution wording before front-end work begins so every surface renders the same legal text.
3. Confirm Swoosh is listed as an optional dependency in `apps/notification/mix.exs` during Phase 1 scaffolding so T163c can compile when email is enabled.

---

## Original Findings (Pre-Remediation, Audit Trail)

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| D1 | Constitution Alignment | CRITICAL | [constitution.md](./constitution.md#L135), [plan.md](./plan.md#L48), [tasks.md](./tasks.md#L211), [tasks.md](./tasks.md#L228) | The constitution requires disclaimers on every prediction page, every suggestion page, every report, and the login page footer, and the plan marks this gate as PASS. The task set only creates explicit prediction disclaimer tests and UI work. There are no explicit implementation tasks for suggestion-page disclaimers, report disclaimers, or the login footer disclaimer. | Add dedicated tasks and validation steps for suggestion surfaces, report outputs, and the login footer before Phase 5 begins. Re-run constitution alignment after the task set is updated. |
| C1 | Coverage Gap | HIGH | [spec.md](./spec.md#L563), [contracts/gateway-api.md](./contracts/gateway-api.md#L99), [contracts/gateway-api.md](./contracts/gateway-api.md#L121), [tasks.md](./tasks.md) | FR-022 requires analysis of supported instruments outside current holdings, and the gateway contract defines search, quote, and OHLCV endpoints. The task set does not create gateway controllers, services, hooks, or UI work for instrument search, quote retrieval, or historical candle retrieval for that non-holding flow. | Add backend and dashboard tasks for instrument search, quote, and OHLCV retrieval so US6 can support non-holding instruments as specified. |
| C2 | Coverage Gap | HIGH | [spec.md](./spec.md#L656), [data-model.md](./data-model.md#L303), [plan.md](./plan.md#L188), [tasks.md](./tasks.md) | FR-070 requires custom watchlist management, the data model includes watchlist tables, and the plan names a settings surface. The task set references watchlists only as consumers of signals and subscriptions; it does not create watchlist CRUD services, controllers, hooks, or UI flows. | Add tasks for watchlist creation, editing, deletion, ordering, and integration into the dashboard settings or suggestions flow. |
| C3 | Coverage Gap | HIGH | [spec.md](./spec.md#L658), [plan.md](./plan.md#L194), [plan.md](./plan.md#L198), [tasks.md](./tasks.md) | FR-071 and the notification plan both include optional email alert delivery. The task set implements in-app alert consumption and toast wiring but has no explicit email delivery task, adapter, or test coverage. | Add email-channel tasks for alert dispatch, configuration, and verification, or explicitly de-scope email from the plan and spec. |
| C4 | Coverage Gap | HIGH | [spec.md](./spec.md#L662), [tasks.md](./tasks.md#L174), [tasks.md](./tasks.md#L176), [tasks.md](./tasks.md#L177) | FR-074 requires flat-file and printable report export. The task set covers CSV, XLSX, and OData, but it contains no explicit PDF or printable-report generation task. | Add PDF export generation and validation tasks, or tighten FR-074 if printable export is intentionally deferred. |
| I1 | Inconsistency | MEDIUM | [spec.md](./spec.md#L565), [tasks.md](./tasks.md#L138), [data-model.md](./data-model.md) | FR-023 requires user-selected technical settings to persist across sessions, and T073 introduces an `indicator_profile` implementation path. The data model contains no persisted settings or indicator-profile entity, so storage semantics for that requirement are undefined. | Add a settings or indicator-profile entity to the data model and align related task paths and contracts. |
| I2 | Inconsistency | MEDIUM | [plan.md](./plan.md#L188), [tasks.md](./tasks.md#L285), [tasks.md](./tasks.md#L289) | The plan's declared source structure does not define `analytics_engine/api/services/`, yet Phase 8 tasks place suggestion, rebalance, and diversification logic there. The same plan also calls out a dashboard settings section, but there is no corresponding settings page or route task. | Either extend the plan structure to include that service directory and settings surface, or move those tasks into a planned package structure and add the missing settings delivery tasks. |
| A1 | Ambiguity | MEDIUM | [tasks.md](./tasks.md#L322) | T177 uses `Power BI or OData` in a single executable task, leaving the Phase 9 interface contract unresolved even though task format requires exact implementable work. | Split this into two explicit tasks or choose one concrete integration path and reserve the other as a later enhancement. |
| I3 | Inconsistency | LOW | [spec.md](./spec.md#L3), [plan.md](./plan.md#L3) | The specification header uses `kiteedge-phase-1` as the feature branch while the plan uses the fixed project identifier `kiteedge`. This does not break artifact resolution today, but it increases the chance of later script or metadata drift. | Normalize the top-level metadata to the fixed `kiteedge` feature identifier across all phase artifacts. |

**Coverage Summary Table:**

| Requirement Key | Has Task? | Task IDs | Notes |
|-----------------|-----------|----------|-------|
| FR-022 | No | None | Non-holding instrument search, quote, and OHLCV flow is specified and contracted but not tasked. |
| FR-023 | Partial | T073, T080 | Persistence is implied in tasks but not modeled in the data model. |
| FR-070 | No | None | Watchlist management tables exist in the data model, but no CRUD/UI tasks implement the feature. |
| FR-071 | No | None | In-app alerts are tasked; optional email delivery is not. |
| FR-074 | No | None | CSV and XLSX exist; printable/PDF export does not. |
| FR-075 | Yes | T177, T183 | BI integration is present but task wording is ambiguous. |
| SC-005 | Yes | T171, T174, T179, T181 | Tear-sheet generation is covered, but no explicit timing benchmark task exists yet. |
| SC-006 | Yes | T034, T044, T058, T197 | Live P&L delivery exists functionally, though explicit latency verification is deferred. |

**Constitution Alignment Issues:**

- D1 is a constitution-level defect. The constitution and plan both require disclaimer placement on prediction, suggestion, report, and login surfaces, but the task set only materializes prediction disclaimer work.
- No other direct constitution MUST violations were found in the current artifact set.

**Unmapped Tasks:**

- T156-T160 reference `analytics_engine/api/services/*`, a path not declared in the current plan structure.
- T177 is mapped to FR-075, but its deliverable remains ambiguous because it conflates two interface choices.

**Metrics:**

- Total Requirements: 82
- Total Tasks: 202
- Coverage % (requirements with >=1 task): 95.1% (78 / 82)
- Ambiguity Count: 1
- Duplication Count: 0
- Critical Issues Count: 1

## Next Actions

- Resolve D1 before `/speckit.implement`; it is a constitution-alignment failure, not just a coverage gap.
- Address C1 through C4 before implementation planning is treated as execution-ready. These gaps affect contracted endpoints and explicitly specified user-visible features.
- Tighten I1, I2, and A1 so later task execution does not drift between undocumented paths or unresolved interface choices.
- Suggested command path after remediation: update the phase artifacts directly, then rerun the Phase 4 analysis against the revised `specs/kiteedge` set.

**Remediation applied on this pass.** See the "Remediation Status" table at the top of this file. All CRITICAL and HIGH findings are resolved; the gate for `/speckit.implement` is now open pending verification steps listed above.