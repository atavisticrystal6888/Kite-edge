# Mega-Prompt: Build a Customer Support Ticket System with Smart Routing

## Context & Role

You are a senior full-stack architect, product engineer, and PM-minded builder tasked with building **TicketFlow** — a production-grade Customer Support Ticket System with AI-powered Smart Routing. You will follow **Spec-Driven Development (SDD)** methodology using the GitHub Spec Kit workflow. Specifications are the source of truth, code serves specifications, and every implementation decision traces back to a concrete requirement.

You are working inside a monorepo. The project will be built across **7 SDD phases**, each producing specific artifacts before moving to the next. Do NOT skip phases. Do NOT write implementation code until Phase 5.

---

## Phase 0: Constitution — Governing Principles

**Command**: `/speckit.constitution`

Create `specs/ticketflow/constitution.md` establishing the immutable architectural principles for TicketFlow. The constitution MUST include the following articles:

### Required Articles

**Article I: Event-Driven Ticket Lifecycle**
- Every ticket is an event stream — creation, assignment, escalation, response, resolution, and reopening are immutable events.
- The ticket state machine is the single source of truth: `new → triaged → assigned → in_progress → waiting_on_customer → resolved → closed → reopened`.
- No event may be deleted. State is derived by replaying the event stream. Every mutation produces a new event published to Kafka.
- SLA clocks are computed from events, not from mutable timestamp columns.

**Article II: Smart Routing as a Separable Intelligence Layer**
- The routing engine is a distinct service that can be replaced, retrained, or bypassed without affecting the core ticketing system.
- Routing decisions are logged with confidence scores, contributing factors, and the model version that produced them.
- Manual routing overrides by agents are feedback signals captured for model retraining.
- The system MUST function with a simple rule-based fallback if the ML router is unavailable (graceful degradation).

**Article III: SLA as a First-Class Domain Object**
- SLA policies are not afterthoughts — they are core domain entities with defined tiers (Critical/4hr, High/8hr, Medium/24hr, Low/72hr).
- SLA breach prediction is proactive: the system alerts BEFORE a breach, not after.
- Every SLA computation must be auditable — inputs (ticket priority, business hours calendar, pause windows) and outputs (remaining time, breach timestamp) are logged.
- SLA clocks pause when status is `waiting_on_customer` and resume on customer reply.

**Article IV: Test-First Development**
- TDD is non-negotiable. All implementation MUST follow Red → Green → Refactor.
- SLA timer logic requires property-based testing with edge cases (weekends, holidays, timezone boundaries, DST transitions).
- NLP classification models require evaluation on held-out test sets with precision/recall/F1 metrics.
- Integration tests must use real PostgreSQL and Kafka (via Docker), not mocks.
- Contract tests between services are mandatory before implementation.

**Article V: Multi-Channel Ingestion**
- Tickets arrive from multiple channels: web form, email, API, chat widget, and (future) phone transcription.
- Each channel has a normalizer that transforms channel-specific payloads into the canonical TicketCreated event schema.
- Channel source is preserved as metadata — routing models may weight channel differently.
- All channels converge onto the same Kafka topic after normalization.

**Article VI: Performance & Scalability**
- Ticket creation to routing decision: < 3 seconds end-to-end (including NLP classification).
- SLA dashboard queries: < 2 seconds on 1M+ tickets.
- Event ingestion: 5,000 events/second sustained throughput via Kafka.
- NLP classification: < 500ms p99 latency per ticket (batch inference for backfill: 1,000 tickets/minute).
- System must handle 10,000 concurrent agents and 100,000 open tickets without degradation.

**Article VII: Simplicity & YAGNI**
- Start with the simplest implementation that satisfies requirements.
- No speculative features ("might need later"). Voice/phone channel is explicitly out of scope for v1.
- Maximum 6 services for v1. Additional services require documented justification.
- Use framework features directly — no unnecessary abstraction layers.
- Start with rule-based routing + TF-IDF/lightweight NLP before introducing deep learning.

**Article VIII: Multi-Tenancy from Day One**
- All data is tenant-scoped. No query may return cross-tenant data.
- Tenant isolation at the database level (row-level security with `tenant_id` on every table).
- Each tenant has its own SLA policies, categories, routing rules, and agent teams.
- API authentication is per-tenant with API keys (ingestion) and JWT (dashboard).

**Article IX: Observability & Agent Experience**
- Structured logging (JSON) on every service with correlation IDs per ticket.
- Health check endpoints on every service.
- Agent-facing metrics: average response time, tickets resolved today, CSAT score.
- System metrics: routing accuracy, SLA compliance rate, queue depth per category, escalation rate.
- Every routing decision includes an explainability payload ("routed to Billing team because: 85% confidence on 'billing' category, agent Jane has lowest queue depth in Billing").

**Article X: Data-Driven PM Artifacts**
- The system must natively produce data for PM deliverables:
  - **Ticket category taxonomy**: auto-discovered from NLP clusters, curated by PM, enforced by routing.
  - **SLA tier compliance dashboards**: exportable to Power BI and Excel.
  - **Escalation rule effectiveness**: which rules fire, how often, and their impact on resolution time.
  - **CSAT survey integration**: post-resolution survey triggers, score aggregation per agent/team/category.
  - **Routing accuracy OKRs**: % of tickets correctly routed on first assignment (target: >85%).

### Governance
- Constitution supersedes all other documents and development practices.
- Amendments require: written rationale, impact analysis, and explicit approval.
- All PRs must include a constitution compliance checklist.

---

## Phase 1: Specification — What & Why (Not How)

**Command**: `/speckit.specify`

Create `specs/ticketflow/spec.md` — a comprehensive Product Requirements Document. Focus exclusively on WHAT users need and WHY. Do NOT include technology choices, API designs, or code structure.

### Product Vision

TicketFlow is a self-hosted customer support ticket system with AI-powered smart routing that eliminates manual triage, reduces SLA breaches, and improves customer satisfaction. It replaces manual ticket assignment with intelligent, explainable routing while giving PMs full visibility into support operations through built-in analytics.

### Target Personas

1. **Support Agent (Primary)** — Receives assigned tickets, responds to customers, escalates when needed, resolves and closes tickets.
2. **Team Lead / Supervisor** — Monitors team queue, reassigns tickets, manages agent workload, reviews escalations, tracks SLA compliance.
3. **Product Manager** — Defines ticket categories, SLA tiers, routing rules; reviews CSAT trends, escalation patterns, and category distribution to inform product decisions.
4. **Customer** — Submits tickets via web form/email/chat, receives updates, responds to agent questions, completes CSAT surveys.
5. **Platform Admin** — Manages tenants, agent accounts, channel configurations, system health, and integrations.
6. **Data Analyst** — Reviews routing accuracy metrics, creates Power BI reports, exports data to Excel, monitors OKR dashboards.

### User Stories — Prioritized & Independently Testable

Write detailed user stories for each of the following, with Given/When/Then acceptance scenarios:

**P1 — Core Ticketing Loop (MVP)**
- US1: Customer submits a support ticket via web form with subject, description, and optional attachments.
- US2: System automatically classifies the ticket into a category (Billing, Technical, Account, Feature Request, Bug Report, General) using NLP.
- US3: System routes the ticket to the best available agent based on category, agent skills, current workload, and SLA urgency.
- US4: Agent views their assigned ticket queue sorted by SLA urgency, responds to the customer, and resolves the ticket.
- US5: System tracks SLA timers per ticket (first response time, resolution time) with automatic pause/resume on customer wait states.
- US6: Customer receives email notifications on ticket updates and can reply via email to add comments.

**P2 — Smart Routing & Intelligence**
- US7: System provides routing explainability — agent sees WHY a ticket was routed to them (category confidence, skill match, workload score).
- US8: Supervisor manually reassigns a ticket; the system captures this as a routing feedback signal and includes it in model retraining data.
- US9: System detects high-priority tickets using sentiment analysis and urgency keywords, auto-escalating to senior agents.
- US10: Agent marks a ticket as "needs escalation" with reason; system routes to the escalation team following configured escalation rules.
- US11: System learns from historical tickets — routing accuracy improves over time as manual corrections accumulate.

**P3 — SLA Management & Compliance**
- US12: PM configures SLA policies per ticket priority tier (Critical: 4hr first response / 24hr resolution, High: 8hr / 48hr, Medium: 24hr / 72hr, Low: 72hr / 168hr).
- US13: System sends proactive SLA breach warnings to supervisors 30 minutes before a breach.
- US14: Dashboard shows real-time SLA compliance: % of tickets within SLA by category, team, priority, and time period.
- US15: SLA clocks correctly account for business hours (configurable per tenant: M-F 9am-6pm, timezone-aware) and pause during `waiting_on_customer` status.

**P4 — Customer Experience & CSAT**
- US16: After ticket resolution, customer receives a CSAT survey (1-5 rating + optional comment).
- US17: PM views CSAT dashboards: average score by agent, team, category, and trend over time.
- US18: System flags agents with CSAT scores below threshold for supervisor review.
- US19: Customer views a self-service portal showing their open and historical tickets with full conversation threads.

**P5 — Analytics, Reporting & PM Artifacts**
- US20: PM views operational dashboard: ticket volume by channel, category distribution, average resolution time, first contact resolution rate.
- US21: Analyst exports ticket data, SLA compliance reports, and CSAT data to Power BI via REST API or to Excel via CSV/XLSX download.
- US22: PM manages the ticket category taxonomy: add, rename, merge, or retire categories with automatic reclassification of incoming tickets.
- US23: Dashboard shows routing accuracy OKR: % of tickets correctly routed on first assignment (measured by tickets NOT manually reassigned within 1 hour).
- US24: PM configures and reviews escalation rules effectiveness: which rules triggered, average time-to-resolution for escalated vs non-escalated tickets.

**P6 — Multi-Channel & Administration**
- US25: Tickets arrive via email (parsed from incoming email webhook), web form, REST API (third-party integrations), and embeddable chat widget.
- US26: Admin creates and manages agent accounts with skill tags (billing, technical-L1, technical-L2, account-management).
- US27: Admin configures teams, business hours calendars, holiday schedules, and auto-response templates.
- US28: Admin views system health: Kafka lag, classification queue depth, service status, error rates.

### Edge Cases (must be addressed in spec)
- What happens when no agents with matching skills are available? (Overflow routing to next-best team vs queue with alert)
- What happens when a ticket is submitted in a language the NLP model doesn't support?
- How are spam/duplicate tickets detected and handled?
- What happens when a customer replies to a closed ticket? (Auto-reopen with new SLA?)
- How are tickets handled when SLA breaches during off-hours (ticket submitted Friday 5pm)?
- What happens when the NLP classification confidence is below threshold? (Route to triage queue for manual classification?)
- How does the system handle ticket merging when a customer submits duplicates?
- What if an agent is deactivated/goes on leave while having open tickets?

### Functional Requirements (FR-001 through FR-060+)
Write at least 60 functional requirements covering:
- Ticket lifecycle management (CRUD, state machine with all transitions and guards)
- Multi-channel ingestion (web form, email parsing, API, chat widget — canonical event normalization)
- NLP classification (category prediction, sentiment analysis, urgency detection, confidence scoring)
- Smart routing algorithm (skill matching, workload balancing, SLA-aware prioritization, round-robin fallback)
- Routing explainability (contributing factors, confidence scores, alternative agents considered)
- SLA engine (timer creation, pause/resume, business hours calculation, timezone handling, breach prediction)
- Escalation engine (rule-based triggers: SLA proximity, sentiment score, VIP customer flag, manual escalation)
- Agent workspace (queue management, ticket detail view, response composer, internal notes, canned responses)
- Customer portal (ticket submission, conversation view, self-service ticket history, CSAT survey)
- CSAT survey system (trigger rules, collection, aggregation, alerting on low scores)
- Notification system (email notifications for customers, in-app notifications for agents, SLA breach alerts for supervisors)
- Ticket category taxonomy management (CRUD, merge, retire, auto-reclassification)
- Reporting & export (dashboard queries, Power BI REST endpoint, Excel/CSV export, scheduled reports)
- Multi-tenancy (tenant isolation, per-tenant configuration, API key management, RBAC)
- Agent management (skills, availability, shift schedules, workload caps)
- Audit trail (every ticket mutation logged with who/when/what)
- Rate limiting and spam prevention
- Attachment handling (upload, virus scan placeholder, size limits, CDN storage)

### Non-Functional Requirements
- NFR-001: Ticket creation to routing: < 3s end-to-end
- NFR-002: NLP classification latency: < 500ms p99
- NFR-003: SLA dashboard load time: < 2 seconds on 1M tickets
- NFR-004: Event ingestion: 5,000 events/second sustained
- NFR-005: System availability: > 99.9% (ticket submission endpoint)
- NFR-006: Support 10,000 concurrent agents, 100,000 open tickets
- NFR-007: Data retention: raw events 1 year, aggregated analytics permanent
- NFR-008: GDPR-compliant: customer data anonymization and deletion on request
- NFR-009: NLP routing accuracy: > 85% first-assignment correctness (OKR target)
- NFR-010: CSAT survey response rate: system design should enable > 30% response rate

### Key Entities (no implementation details)
- Ticket, TicketEvent, TicketComment, Attachment
- Category, CategoryTaxonomy, RoutingRule, EscalationRule
- Agent, AgentSkill, Team, Shift, AvailabilitySchedule
- SLAPolicy, SLATimer, SLABreachAlert, BusinessHoursCalendar, Holiday
- Customer, CustomerProfile, CSATSurvey, CSATResponse
- RoutingDecision, ClassificationResult, RoutingFeedback
- Tenant, User, APIKey, Permission, AuditLog
- Channel, ChannelConfig, NotificationTemplate, CannedResponse
- Report, ExportJob, Dashboard, OKRMetric

### Success Criteria
- SC-001: Ticket submitted to agent assignment in < 3 seconds via any channel.
- SC-002: Routing accuracy > 85% (tickets not reassigned within 1 hour of initial assignment).
- SC-003: SLA breach rate < 5% (across all priority tiers).
- SC-004: CSAT survey completion rate > 30%.
- SC-005: Agent can handle full ticket lifecycle (view, respond, escalate, resolve) without leaving the dashboard.
- SC-006: PM can generate a full operational report for executive review within 2 clicks.
- SC-007: New tenant fully configured (teams, agents, SLA, categories, channels) within 30 minutes.
- SC-008: Power BI dashboard connected and showing live data within 15 minutes of setup.

---

## Phase 2: Implementation Plan — Technical Architecture

**Command**: `/speckit.plan`

Create `specs/ticketflow/plan.md` and supporting documents. NOW you define the how.

### Technical Context (Mandatory)

```
Language/Versions:
  - Backend API / Real-time: Elixir 1.16+ / Erlang/OTP 26+ / Phoenix 1.7+
  - NLP & ML Services: Python 3.12+
  - Dashboard Frontend: React.js 18+ with TypeScript
  - Data Pipeline Workers: Python 3.12+

Primary Dependencies:
  - Elixir/Phoenix: Phoenix LiveView, Ecto, Broadway (Kafka consumer), Jason, Oban (background jobs)
  - Python: FastAPI (NLP service API), scikit-learn (TF-IDF + LogisticRegression for v1),
    spaCy (tokenization, NER), transformers (sentiment analysis - distilBERT),
    kafka-python, pandas, openpyxl (Excel export)
  - React: React Router, TanStack Query, Recharts, shadcn/ui, TipTap (rich text editor)
  - Infrastructure: Apache Kafka 3.7+, PostgreSQL 16+, Redis 7+ (caching, rate limiting)

Storage:
  - PostgreSQL 16: Primary datastore (tickets, configs, agents, SLA, CSAT, audit logs)
  - Apache Kafka: Event streaming (ticket events, routing events, notification triggers)
  - Redis 7: Agent session cache, queue depth cache, rate limiting, real-time presence
  - S3-compatible (AWS S3 or MinIO): Ticket attachments

Testing:
  - Elixir: ExUnit, Mox, Wallaby (E2E)
  - Python: pytest, hypothesis (property-based for SLA logic), pytest-asyncio, sklearn metrics
  - React: Vitest, React Testing Library, Playwright (E2E)
  - Integration: Docker Compose test environment with real Kafka + PostgreSQL + Redis
  - ML: Evaluation scripts with precision/recall/F1 on labeled test datasets

Deployment:
  - Docker Compose for local development and single-server deployment
  - Docker images published to container registry
  - AWS deployment: ECS (Fargate) + RDS (PostgreSQL) + MSK (Kafka) + ElastiCache (Redis) + S3
  - GitHub Actions CI/CD pipeline

Performance Goals:
  - Ticket creation → routing: < 3s e2e
  - NLP classification: < 500ms p99
  - SLA dashboard: < 2s on 1M tickets
  - Event throughput: 5K events/sec sustained

Scale:
  - v1 target: 100K open tickets, 10K concurrent agents, 50K tickets/day, 5 tenants
  - Design for 10x growth without architectural changes
```

### Architecture — Service Breakdown

Document these services with responsibilities, tech stack, and contracts:

**1. Ticket Management API (Elixir/Phoenix)**
- Ticket CRUD, state machine transitions, comment threading, attachment management
- Agent workspace API: queue queries, ticket assignment, response submission
- Customer portal API: ticket submission, conversation view, CSAT submission
- SLA policy configuration, business hours management
- Tenant management, RBAC, API key management
- REST API + Phoenix LiveView for admin panels
- Publishes all ticket events to Kafka
- WebSocket via Phoenix Channels for real-time agent dashboard updates

**2. NLP Classification Engine (Python/FastAPI)**
- **Category Classifier**: TF-IDF + Logistic Regression for v1 (upgradeable to fine-tuned transformer)
  - Trained on historical tickets per tenant
  - Returns top-3 categories with confidence scores
  - Retrainable via API endpoint or scheduled job
- **Sentiment Analyzer**: DistilBERT-based sentiment scoring (-1 to +1)
- **Urgency Detector**: Keyword rules + sentiment composite score → urgency flag
- **Language Detector**: langdetect for unsupported language flagging
- Exposes REST API consumed by the routing engine
- Model artifacts versioned and stored (S3 or filesystem)

**3. Smart Routing Engine (Elixir/GenServer)**
- Consumes classification results + agent state + SLA urgency → produces routing decisions
- **Routing algorithm** (priority-ordered):
  1. Match ticket category to agent skills
  2. Filter by agent availability (online, shift active, workload < cap)
  3. Score by: SLA urgency weight (40%) + agent skill match (30%) + current workload inverse (20%) + round-robin tiebreaker (10%)
  4. Select highest-scoring agent
  5. If no match: queue in category pool, alert supervisor
- Publishes RoutingDecision events to Kafka with full explainability payload
- Captures manual reassignments as RoutingFeedback for ML retraining
- Falls back to round-robin within category if ML service is unavailable

**4. SLA Engine (Elixir/GenServer + Oban scheduled jobs)**
- Creates SLA timers on ticket creation based on priority → SLA policy mapping
- Computes remaining time factoring: business hours calendar, timezone, holidays, pause windows
- Runs breach prediction every 5 minutes: identifies tickets approaching breach within 30 minutes
- Publishes SLA breach warning events to Kafka → triggers supervisor notifications
- Exposes SLA status for every ticket via API (remaining time, breach timestamp, % elapsed)

**5. Notification Service (Elixir/Broadway consumer)**
- Consumes events from Kafka: ticket created, assigned, updated, resolved, SLA warning, CSAT trigger
- Renders notification templates per event type and channel (email, in-app, webhook)
- Email delivery via configurable SMTP or AWS SES
- In-app notifications via Phoenix PubSub → Channels → agent dashboard
- Respects customer notification preferences (email frequency, unsubscribe)

**6. Data Pipeline & Analytics (Python workers)**
- Consumes ticket events from Kafka → aggregates into analytics tables in PostgreSQL
- Computes: tickets by category, SLA compliance rates, CSAT averages, routing accuracy, resolution times
- Produces materialized views / rollup tables for fast dashboard queries
- Scheduled aggregation: every 5 minutes for operational dashboards, daily for trend reports
- Generates Excel/CSV exports via Oban-triggered Python jobs
- Exposes OData-compatible REST endpoint for Power BI direct connection

**7. Dashboard Frontend (React.js)**
- **Agent Workspace**: Ticket queue (sorted by SLA urgency), ticket detail with conversation thread, rich text response editor (TipTap), internal notes, canned response picker, ticket actions (assign, escalate, resolve, close)
- **Supervisor Dashboard**: Team overview, queue depth per category, SLA compliance heatmap, agent workload bars, reassignment interface, escalation queue
- **PM Analytics Dashboard**: Ticket volume trends, category distribution pie/bar charts, SLA compliance over time, CSAT trends, routing accuracy OKR tracker, escalation rule effectiveness
- **Customer Portal**: Ticket submission form, ticket list with status, conversation thread view, CSAT survey modal
- **Admin Panel**: Tenant config, agent/team management, SLA policy editor, business hours calendar, category taxonomy manager, channel config, canned response library
- **Export Center**: Download Excel/CSV reports, connect Power BI (endpoint URL + instructions), schedule recurring reports
- Connects via REST to Ticket Management API, receives live updates via Phoenix Channels WebSocket

### Supporting Documents to Generate

**`data-model.md`** — Complete entity-relationship model:
- All tables: tickets, ticket_events, comments, attachments, categories, category_taxonomy, routing_rules, escalation_rules, agents, agent_skills, teams, shifts, sla_policies, sla_timers, business_hours, holidays, customers, csat_surveys, csat_responses, routing_decisions, classification_results, routing_feedback, tenants, users, api_keys, permissions, audit_logs, channels, notification_templates, canned_responses, export_jobs
- PostgreSQL-specific: RLS policies, partitioning on ticket_events by month, GIN indexes on ticket search fields
- Kafka topic schemas: `ticket.events`, `routing.decisions`, `routing.feedback`, `sla.alerts`, `notifications`, `classification.requests`, `classification.results`
- Redis key patterns: `agent:{id}:presence`, `agent:{id}:queue_depth`, `tenant:{id}:rate_limit`, `ticket:{id}:sla_cache`

**`contracts/ticket-api.md`** — OpenAPI 3.1 spec:
- Tickets: CRUD, transition (assign, escalate, resolve, close, reopen), add comment, add attachment
- Agents: CRUD, set skills, set availability, get queue
- Customers: create, get tickets, submit CSAT
- Categories: CRUD, merge, retire
- SLA Policies: CRUD, get ticket SLA status
- Teams: CRUD, assign agents
- Search: full-text ticket search with filters (status, category, agent, priority, date range, SLA status)

**`contracts/classification-api.md`** — OpenAPI 3.1 spec:
- `POST /v1/classify` — Classify ticket text → {categories: [{name, confidence}], sentiment: float, urgency: bool, language: string}
- `POST /v1/retrain` — Trigger model retraining for tenant
- `GET /v1/model/status` — Model version, training date, accuracy metrics

**`contracts/analytics-api.md`** — OpenAPI 3.1 spec:
- `GET /v1/analytics/tickets` — Volume, category distribution, resolution times (filterable by date range, category, team)
- `GET /v1/analytics/sla` — SLA compliance rates by tier, category, team, time period
- `GET /v1/analytics/csat` — CSAT averages by agent, team, category, trend
- `GET /v1/analytics/routing` — Routing accuracy, reassignment rate, avg time-to-correct-assignment
- `GET /v1/analytics/escalations` — Escalation rule trigger counts, effectiveness metrics
- `GET /v1/exports/{format}` — Generate Excel/CSV export (returns job ID, poll for completion)
- OData endpoint for Power BI: `/odata/v1/tickets`, `/odata/v1/sla_compliance`, `/odata/v1/csat_scores`

**`research.md`** — Technical research:
- TF-IDF + Logistic Regression vs fine-tuned DistilBERT for ticket classification (accuracy, latency, training cost tradeoffs)
- Sentiment analysis model comparison (VADER vs DistilBERT vs custom — accuracy on support-domain text)
- SLA timer implementation patterns (event-sourced vs scheduled polling vs hybrid)
- Agent workload scoring algorithms (queue-depth vs weighted-complexity vs hybrid)
- Kafka partitioning strategy for ticket events (by tenant_id vs by category vs by ticket_id)
- Business hours calculation libraries and timezone edge cases (DST, half-day holidays)
- Power BI OData connector requirements and limitations
- Email parsing libraries for inbound email-to-ticket conversion

**`quickstart.md`** — Key validation scenarios:
1. Submit ticket via web form → NLP classifies as "Billing" → routes to billing agent Jane → Jane responds → customer sees response (happy path end-to-end)
2. Submit high-urgency ticket → system detects negative sentiment + urgency keywords → auto-escalates to senior agent
3. Ticket SLA approaching breach → supervisor receives warning 30 minutes before → reassigns to available agent
4. Agent manually reassigns ticket → system captures routing feedback → verify feedback stored for retraining
5. Customer completes CSAT survey → PM dashboard shows updated CSAT average
6. Export SLA compliance report to Excel → verify data matches dashboard
7. Connect Power BI to OData endpoint → verify live dashboard with drill-down
8. Multi-tenant isolation: Tenant A agent cannot see Tenant B tickets

---

## Phase 3: Task Breakdown — Executable Work Items

**Command**: `/speckit.tasks`

Create `specs/ticketflow/tasks.md` organizing work into phases with parallelization markers.

### Required Task Phases

**Phase 1: Project Setup & Infrastructure (14-18 tasks)**
- Initialize monorepo: Elixir umbrella app, Python packages, React app
- Docker Compose: PostgreSQL 16, Kafka (KRaft), Redis 7, MinIO (S3-compatible)
- Ecto migration framework setup
- Kafka topic creation scripts (all topics from data-model.md)
- CI/CD pipeline (GitHub Actions): lint, test, build, Docker push
- Environment config (dev, test, staging, prod) with secrets management
- Shared JSON schema definitions for Kafka event contracts
- Seed data scripts (sample tenant, agents, categories, SLA policies)

**Phase 2: Foundational Infrastructure (18-24 tasks)**
- PostgreSQL schema: tenants, users, api_keys, permissions + RLS policies
- Authentication middleware: API key validation (ingestion), JWT (dashboard), session (customer portal)
- Tenant context propagation (all Ecto queries scoped)
- Kafka producer/consumer base (Broadway setup)
- Redis connection pool, cache helpers, rate limiting middleware
- Structured JSON logging with correlation IDs (per-ticket tracing)
- Health check endpoints for all services
- Error handling: typed errors, meaningful HTTP responses, graceful degradation
- File upload infrastructure (S3/MinIO presigned URLs, size/type validation)

**Phase 3: US1-US6 — Core Ticketing Loop (MVP) (30-38 tasks)**
- Ticket Ecto schema, state machine (with guards for valid transitions)
- Ticket CRUD API (Phoenix controllers)
- Ticket event sourcing: every mutation → TicketEvent → Kafka
- Comment threading (public customer responses + internal agent notes)
- Attachment upload (presigned URL generation, metadata storage)
- Customer ticket submission endpoint (web form API)
- Email ingestion: inbound webhook → parse → TicketCreated event
- NLP Classification service: TF-IDF + LogisticRegression pipeline (Python)
  - Training script on sample/synthetic data
  - Classification API endpoint (FastAPI)
  - Confidence thresholding (< 60% → manual triage queue)
- Smart Routing engine (Elixir GenServer):
  - Skill matching, workload scoring, SLA-urgency weighting
  - Round-robin fallback
  - Explainability payload generation
  - RoutingDecision event → Kafka
- SLA Engine:
  - Timer creation on ticket creation
  - Business hours calculator (timezone-aware, holiday-aware)
  - Pause/resume on waiting_on_customer transitions
  - Breach prediction scheduler (Oban job every 5 min)
  - SLA breach warning events → Kafka
- Agent workspace API: get queue, get ticket detail, submit response, change status
- Customer notification: email on ticket created/updated/resolved
- Agent notification: in-app via Phoenix Channels on ticket assigned
- React: Agent queue view, ticket detail, response editor, status actions
- React: Customer submission form, ticket list, conversation view
- Contract tests for all service-to-service APIs
- Integration test: full ticket lifecycle (submit → classify → route → respond → resolve)

**Phase 4: US7-US11 — Smart Routing & Intelligence (20-26 tasks)**
- Routing explainability UI (agent sees contributing factors with confidence bars)
- Manual reassignment capture → RoutingFeedback event → Kafka
- Sentiment analysis integration (DistilBERT FastAPI endpoint)
- Urgency detection (keyword rules + sentiment composite)
- Auto-escalation triggers (sentiment < -0.5 AND urgency keywords detected)
- Escalation rule engine (configurable rules: SLA proximity, VIP flag, sentiment threshold)
- Escalation workflow: ticket moves to escalation team, supervisor notified
- Model retraining pipeline: collect routing feedback → augment training data → retrain classifier → deploy
- Model versioning (store accuracy metrics per version)
- React: Routing explainability panel, escalation interface, supervisor reassignment UI

**Phase 5: US12-US15 — SLA Management & Compliance (16-20 tasks)**
- SLA policy CRUD API (per priority tier)
- Business hours calendar CRUD (per tenant, with holidays)
- SLA timer computation with business hours + timezone + DST handling
- SLA pause/resume event handling (waiting_on_customer ↔ in_progress)
- Proactive breach warnings: 30-min pre-breach alert to supervisor
- SLA compliance aggregation pipeline (data_pipeline worker)
- React: SLA dashboard (compliance %, by category/team/priority, trend over time)
- React: SLA policy editor, business hours calendar editor
- React: Breach alert banner in supervisor dashboard
- Property-based tests: SLA timer correctness across timezone/DST/holiday edge cases

**Phase 6: US16-US19 — Customer Experience & CSAT (14-18 tasks)**
- CSAT survey model (1-5 rating + optional comment)
- Survey trigger: auto-send 1 hour after ticket resolved (Oban scheduled job)
- CSAT submission API (customer-facing)
- CSAT aggregation pipeline (per agent, team, category, time period)
- Low-score alerting: supervisor notified when agent CSAT drops below threshold
- Customer self-service portal: ticket history, conversation threads, CSAT survey modal
- React: CSAT dashboard for PM (averages, trends, breakdown charts)
- React: Customer portal (submission form, ticket list, conversation, survey)

**Phase 7: US20-US24 — Analytics, Reporting & PM Artifacts (18-22 tasks)**
- Analytics aggregation pipeline (ticket volume, category distribution, resolution times, first-contact resolution)
- Routing accuracy computation: % tickets not reassigned within 1 hour
- Escalation effectiveness: avg resolution time for escalated vs non-escalated
- Analytics REST API (filterable by date range, category, team, priority)
- OData endpoint for Power BI (tickets, SLA compliance, CSAT scores)
- Excel/CSV export job (Oban → Python worker → S3 → download link)
- Scheduled report generation (daily/weekly email digest to PM)
- Category taxonomy manager API (add, rename, merge, retire — with auto-reclassification trigger)
- React: PM operational dashboard (volume trends, category distribution, resolution metrics)
- React: Routing accuracy OKR tracker
- React: Escalation rule effectiveness dashboard
- React: Category taxonomy editor (with merge/retire workflows)
- React: Export center (download reports, Power BI connection instructions)

**Phase 8: US25-US28 — Multi-Channel & Administration (14-18 tasks)**
- Channel normalizer framework (abstract base → web form, email, API, chat widget implementations)
- Email channel: inbound webhook parser (extract subject, body, attachments, threading via In-Reply-To header)
- Chat widget: embeddable JavaScript snippet + WebSocket endpoint
- REST API channel: API key authenticated, documented Swagger endpoint for third-party integrations
- Admin: agent management UI (CRUD, skill tags, team assignment, shift schedules)
- Admin: team management UI, business hours/holiday config
- Admin: channel configuration (enable/disable, SMTP settings, webhook URLs)
- Admin: notification template editor, canned response library
- Admin: system health dashboard (Kafka lag, service status, classification queue depth, error rates)
- React: All admin panels

**Phase 9: Polish & Hardening (18-22 tasks)**
- Performance: PostgreSQL query optimization, index tuning, connection pooling
- Performance: Kafka consumer tuning, batch sizes, partition count optimization
- Security: rate limiting (per API key + per IP), input sanitization, CORS, CSP headers, SQL injection prevention
- Security: attachment virus scan placeholder (ClamAV integration point), file type whitelist
- Spam detection: duplicate ticket detection (fuzzy hash on subject+body within 5 min window)
- Documentation: API docs (Swagger UI), agent user guide, PM analytics guide, admin setup guide, architecture decision records
- Monitoring: Prometheus metrics endpoints per service, Grafana dashboards (system health, SLA, routing accuracy)
- Load testing: k6 scripts for ticket submission, agent queue fetch, SLA dashboard, classification endpoint
- GDPR: customer data anonymization endpoint, right-to-deletion workflow
- Accessibility: WCAG 2.1 AA compliance for agent dashboard and customer portal
- Agent experience polish: keyboard shortcuts, bulk actions, ticket snooze, personal canned responses

### Task Format

Every task MUST follow:
```
- [ ] T{NNN} [P?] [US{N}] {Description} — {exact file path}
```

### Dependency Rules
- Phase 1 → Phase 2 → Phase 3 (MVP) → Phase 4+ (can parallelize some)
- Within each phase: contract tests → models → services → APIs → UI
- Cross-service contracts defined before implementation
- NLP model training data must exist (seed/synthetic) before classification service is testable

---

## Phase 4: Pre-Implementation Analysis

**Command**: `/speckit.analyze`

Perform cross-artifact consistency analysis:

1. **Spec ↔ Plan traceability**: Every FR maps to a component in plan.md
2. **Plan ↔ Tasks traceability**: Every service in plan.md has tasks in tasks.md
3. **Contract consistency**: APIs in `contracts/` match data-model.md entities
4. **User story coverage**: Every US has acceptance scenarios AND tasks
5. **SLA logic completeness**: All SLA edge cases (business hours, holidays, DST, pause/resume) have tests
6. **NLP pipeline coverage**: Training → classification → routing → feedback → retraining loop fully specified
7. **PM artifact coverage**: Every PM deliverable (taxonomy, SLA dashboards, CSAT, routing OKR, escalation rules) has a corresponding analytics endpoint and dashboard component
8. **Multi-tenant isolation**: Every query, every Kafka consumer, every API endpoint is tenant-scoped
9. **Constitution compliance**: All 10 articles satisfied
10. **Dependency validation**: No circular dependencies in task execution

Output a consistency report identifying gaps, conflicts, and recommendations.

---

## Phase 5: Implementation

**Command**: `/speckit.implement`

Execute tasks per tasks.md. For each task:
1. Write failing tests FIRST (Red)
2. Implement minimum code to pass (Green)
3. Refactor for clarity (Refactor)
4. Verify constitution compliance
5. Update checkpoint

### Implementation Structure

**Elixir Umbrella App**
```
apps/
  ticket_flow/             # Core domain: Ecto schemas, state machine, business logic
  ticket_flow_web/         # Phoenix: REST controllers, LiveView, Channels, auth
  event_collector/         # Broadway: Kafka consumers for ticket events
  routing_engine/          # GenServer: smart routing, skill matching, workload scoring
  sla_engine/              # GenServer + Oban: SLA timers, breach prediction, business hours
  notification_service/    # Broadway: Kafka consumer → email/in-app notifications
```

**Python Packages**
```
nlp_engine/
  api/                     # FastAPI app
  classifiers/
    category.py            # TF-IDF + LogisticRegression pipeline
    sentiment.py           # DistilBERT sentiment
    urgency.py             # Keyword + sentiment composite
    language.py            # Language detection
  training/
    train_category.py      # Training script
    evaluate.py            # Precision/recall/F1 evaluation
  models/                  # Pydantic request/response models
  tests/

data_pipeline/
  consumers/               # Kafka → PostgreSQL aggregation
  aggregators/
    ticket_metrics.py      # Volume, resolution time, first contact resolution
    sla_compliance.py      # SLA breach rates, compliance %
    csat_metrics.py        # CSAT averages, trends
    routing_accuracy.py    # Reassignment rate, OKR computation
  exporters/
    excel.py               # openpyxl Excel generation
    csv_export.py          # CSV generation
    odata.py               # OData endpoint for Power BI
  tests/
```

**React Dashboard**
```
dashboard/
  src/
    components/
      agent/               # Queue, TicketDetail, ResponseEditor, InternalNotes
      supervisor/          # TeamOverview, SLAHeatmap, ReassignPanel, EscalationQueue
      pm/                  # AnalyticsDashboard, CSATDashboard, RoutingOKR, CategoryManager
      customer/            # SubmitTicket, TicketList, Conversation, CSATSurvey
      admin/               # AgentManager, TeamManager, SLAEditor, ChannelConfig, SystemHealth
      shared/              # SLABadge, PriorityTag, StatusBadge, ConfidenceBar, Charts
    hooks/                 # TanStack Query hooks for all APIs
    contexts/              # Auth, Tenant, WebSocket, Notifications
    pages/                 # Route-level components
    lib/
      api.ts               # Typed API client
      ws.ts                # Phoenix Channels client
      sla.ts               # Client-side SLA countdown formatting
      export.ts            # Export trigger + download helpers
  tests/
    e2e/                   # Playwright
    unit/                  # Vitest
```

### Docker Compose

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ticketflow_dev
      POSTGRES_USER: ticketflow
      POSTGRES_PASSWORD: ticketflow_dev
    ports: ["5432:5432"]
    volumes: [pg_data:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ticketflow"]

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
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ticketflow
      MINIO_ROOT_PASSWORD: ticketflow_dev
    ports: ["9000:9000", "9001:9001"]
    volumes: [minio_data:/data]

  ticket_api:
    build: { context: ., dockerfile: apps/ticket_flow_web/Dockerfile }
    depends_on: [postgres, kafka, redis]
    ports: ["4000:4000"]
    environment:
      DATABASE_URL: ecto://ticketflow:ticketflow_dev@postgres/ticketflow_dev
      KAFKA_BROKERS: kafka:9092
      REDIS_URL: redis://redis:6379
      S3_ENDPOINT: http://minio:9000

  nlp_engine:
    build: { context: ., dockerfile: nlp_engine/Dockerfile }
    depends_on: [postgres]
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://ticketflow:ticketflow_dev@postgres/ticketflow_dev
      MODEL_PATH: /models

  data_pipeline:
    build: { context: ., dockerfile: data_pipeline/Dockerfile }
    depends_on: [postgres, kafka]
    environment:
      DATABASE_URL: postgresql://ticketflow:ticketflow_dev@postgres/ticketflow_dev
      KAFKA_BROKERS: kafka:9092
      S3_ENDPOINT: http://minio:9000

  dashboard:
    build: { context: ., dockerfile: dashboard/Dockerfile }
    depends_on: [ticket_api]
    ports: ["3000:3000"]

volumes:
  pg_data:
  minio_data:
```

---

## Phase 6: Verification & Quality Gates

**Command**: `/speckit.verify`

### Automated Verification

1. **Unit test pass rate**: 100% across all services
2. **Integration test**: Full lifecycle — submit ticket → classify → route → agent respond → resolve → CSAT survey → analytics updated
3. **Contract tests**: All service-to-service contracts validated
4. **SLA correctness** (property-based): Timer accuracy across 1,000 randomized scenarios (business hours, holidays, timezones, DST, pause/resume)
5. **NLP accuracy**: Category classifier F1 > 0.80 on held-out test set; sentiment accuracy > 0.75
6. **Routing accuracy**: On synthetic dataset of 10,000 tickets with known correct assignments, first-assignment accuracy > 85%
7. **Performance benchmarks** (k6):
   - Ticket submission: 1K rps, < 500ms p99
   - Classification: 100 rps, < 500ms p99
   - Agent queue fetch: 500 rps, < 200ms p99
   - SLA dashboard: < 2s on 1M tickets
8. **Security**: No SQL injection, XSS, CSRF, broken auth (OWASP Top 10)
9. **Multi-tenant isolation**: Tenant A operations never return Tenant B data (automated fuzzing)
10. **Export validation**: Power BI OData endpoint returns well-formed responses; Excel export opens correctly with data integrity

### Manual Verification (Quickstart Walkthrough)

1. Create tenant "Acme Corp" with 2 teams (Billing, Technical), 4 agents, SLA policies, business hours
2. Submit ticket: "I was charged twice for my subscription" via web form
3. Verify: NLP classifies as "Billing" (view confidence score), routes to billing agent, explainability shown
4. Agent responds, changes status to waiting_on_customer
5. Verify: SLA clock pauses
6. Customer replies via email
7. Verify: SLA clock resumes, comment appears in thread
8. Agent resolves ticket
9. Verify: CSAT survey sent after 1 hour, customer submits 4/5 rating
10. PM views dashboard: verify ticket appears in analytics, CSAT updated, routing marked as correct (no reassignment)
11. Export SLA compliance report to Excel, verify correctness
12. Connect Power BI to OData endpoint, verify drill-down by category/team/priority

### PM Artifact Verification

| PM Artifact | Verified By |
|---|---|
| Ticket category taxonomy | Category manager UI allows CRUD/merge/retire; NLP respects taxonomy |
| SLA tier compliance | Dashboard shows compliance % by tier/category/team; matches Excel export |
| Escalation rule effectiveness | Dashboard shows rule trigger counts, avg resolution time delta |
| CSAT survey design | Survey triggers correctly, scores aggregate in dashboard |
| Routing accuracy OKR | OKR tracker shows % first-assignment correctness, trending over time |

---

## Global Constraints

### Artifact Summary

| Phase | Artifacts | Location |
|-------|-----------|----------|
| 0. Constitution | `constitution.md` | `specs/ticketflow/` |
| 1. Specification | `spec.md` | `specs/ticketflow/` |
| 2. Plan | `plan.md`, `data-model.md`, `research.md`, `quickstart.md`, `contracts/*.md` | `specs/ticketflow/` |
| 3. Tasks | `tasks.md` | `specs/ticketflow/` |
| 4. Analysis | `analysis-report.md` | `specs/ticketflow/` |
| 5. Implementation | Source code, tests, Docker configs, CI/CD | Repository root |
| 6. Verification | Test results, benchmarks, PM artifact validation | `specs/ticketflow/verification/` |

### Technology Versions

```
Elixir: 1.16.x (OTP 26)          Python: 3.12.x
Node.js: 20 LTS                  PostgreSQL: 16.x
Kafka: 3.7.x (KRaft)             Redis: 7.x
React: 18.x                      TypeScript: 5.3+
Docker Compose: 3.8+              scikit-learn: 1.4+
spaCy: 3.7+                      transformers: 4.36+
```

### Out of Scope for v1

- Phone/voice channel (transcription, IVR)
- AI-generated response suggestions (auto-reply drafts)
- Deep learning classification (transformer fine-tuning — TF-IDF + LogReg is v1)
- Mobile app for agents
- Real-time chat between agent and customer (async ticket-based only)
- Knowledge base / FAQ self-service
- Multi-language NLP models (English only for v1)
- SSO / SAML integration (JWT + API keys only)

---

## Execution Instructions

**Execute phases sequentially. Each phase MUST produce complete artifacts before the next begins.**

1. Phase 0 (Constitution) → establish principles
2. Phase 1 (Specify) → full PRD, no tech decisions
3. Phase 2 (Plan) → architecture + all supporting docs
4. Phase 3 (Tasks) → granular, parallelizable, dependency-ordered
5. Phase 4 (Analyze) → cross-artifact consistency check
6. Phase 5 (Implement) → TDD, service by service
7. Phase 6 (Verify) → automated tests, load tests, PM artifact validation

**After each phase, summarize outputs and state readiness for next phase.**

If ambiguities or conflicts arise between phases, STOP and resolve before proceeding. Update earlier artifacts as needed.

**Begin with Phase 0: Constitution.**
