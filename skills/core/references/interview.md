# The `architecture` Interview: Exhaustive Question Checklist

Merged inventory of everything to settle when designing a greenfield
architecture. Phase B of the `architecture` skill walks this file top to bottom;
the interview is complete when every applicable item here AND every
required section of every applicable topic in `topics.md` is answerable
from recorded decisions.

## Conduct rules

- One question per turn; offer concrete options when enumerable.
- Quantify everything: "fast", "secure", "scalable" are banned answers:
  push for a number, a percentile, and how it would be measured. A
  quality target without a measure is recorded as a wish, not a decision.
- Classify each decision as a **one-way door** (irreversible: gets
  rigor, alternatives, and explicit confirmation) or **two-way door**
  (reversible: decide fast, record, move on).
- For the macro-structure decision, present **2-3 candidates** with
  trade-offs, never one.
- Offer defaults explicitly (boring technology, monolith-first, buy for
  generic subdomains, YAGNI) and let the user accept or override; never
  silently adopt them.
- Record non-goals and out-of-scope items as decisions too.
- Log every unverified assumption in the interview file as a risk with a
  validation idea.
- Skip whole sections that don't apply (record why); expand any answer
  that surprises you with follow-ups before moving on.
- **Push back on an answer that breaks something**, per core.md's
  Pushback rule: name the conflict, offer the alternative, at most two
  rounds, then it is the user's call and both the decision and your
  objection go into the `### Q<n>` entry.

## 0. Framing (always first)

### 0.1 Business & product
- What problem, for whom, why now; how is success measured (KPIs)?
- Business model / revenue mechanics: what must the system protect?
- Expected lifespan (18 months vs 15 years); exit scenarios (acquisition,
  white-label, on-prem sales, sunset)?
- Time-to-market vs quality: which wins when they conflict?
- Budget: build cost, run cost ceiling, team cost; acceptable unit
  economics (cost per user/request/tenant)?
- Cost of an hour of downtime; cost of a data breach?
- Which capabilities differentiate (build) vs commodity (buy/adopt)?
- MVP vs full vision; what is v1 truly minimal at?
- Non-goals: what will this system explicitly not do?

### 0.2 Users & load
- User classes/personas, count at launch / 1 year / 3 years; geographies,
  devices, network quality, assistive tech?
- Concurrency and request-rate expectations; peak-to-average ratio;
  seasonal/spiky patterns and their triggers?
- Read/write ratio; data volume and growth rate; largest single object?
- Latency users actually notice, per interaction class?
- Offline / degraded-network requirements?
- B2B or B2C; tenancy expectations; enterprise SSO demands?
- The 10x question: if load is 10× or 0.1× the estimate, what should
  survive? (Design for ~10x, not 100x.)

### 0.3 Constraints (non-negotiables)
- Regulatory regimes: GDPR/CCPA, HIPAA, PCI-DSS, SOC 2, ISO 27001,
  FedRAMP, DORA, AI Act, accessibility law (ADA/EN 301 549), sector rules?
- Data residency / sovereignty per market?
- Mandated technologies, clouds, vendors, enterprise standards, signed
  contracts?
- Real deadlines (regulatory, contractual, event-driven) vs aspirational?
- Licensing policy (copyleft tolerance, commercial budgets)?

### 0.4 Team & organization
- Team size, skills, seniority now; hiring plan; time zones?
- How many teams will own this; what can each own end-to-end (cognitive
  load budget)?
- Ops maturity: can they run Kubernetes / Kafka / multi-region, honestly?
- Who has architecture decision authority; who arbitrates conflicts?
- Existing conventions, platforms, golden paths to reuse?
- Conway check: do intended team boundaries match the intended
  decomposition? (Design both together.)

### 0.5 Operations & risk posture
- Availability target as a real number per capability tier (each nine
  costs ~10x); error-budget appetite?
- RTO/RPO per data class: minutes, not adjectives?
- Who operates it: dedicated ops, you-build-it-you-run-it, nobody?
- On-call expectations, support hours, SLAs promised to customers?
- Maintenance windows acceptable or zero-downtime mandated?
- Threat profile: who attacks this and why; what must never happen?

## 1. Shape decisions (the one-way doors)

- **Macro-structure** (2-3 candidates): monolith / modular monolith /
  service-based / microservices / serverless / event-driven / plugin.
  Default bias: modular monolith with enforced boundaries unless a hard
  driver (independent scaling, team autonomy at scale, fault isolation,
  regulatory separation) demands distribution.
- **Internal structure**: layered, hexagonal/ports-and-adapters,
  clean/onion, vertical slice; transaction script vs rich domain model.
- **Decomposition axis**: bounded contexts / capabilities; subdomain
  triage (core = build well, supporting = adequate, generic = buy).
- **Data ownership**: system-of-record per entity; one DB vs
  per-service/context; no-shared-database rule?
- **Sync vs async default posture** between components; orchestration vs
  choreography for workflows; workflow engine or not.
- **Hosting**: cloud (which provider) / on-prem / hybrid / edge;
  single vs multi-region; multi-cloud only with a priced reason.
- **Compute model**: PaaS / containers / Kubernetes / serverless; buy
  the lowest-ops option the requirements allow.
- **Primary language(s) + framework(s)**: team fit, hiring pool, boring
  bias; polyglot policy.
- **Tenancy model** (if multi-tenant): pooled / siloed / bridge; isolation
  guarantee level.
- **Build vs buy per capability**: auth/IdP (build: never), payments,
  email/SMS, search, analytics, admin; enumerate and decide each.
- **Repo topology**: monorepo vs polyrepo; build tooling.
- For every one-way door: record the rejected alternatives and why.

## 2. Topic-mapped checklists

### → architecture.md
- Layers and their allowed dependency directions; enforcement mechanism
  (imports linting, module system, none)?
- Module boundaries: public surfaces, who may import what?
- Entry points: processes, CLIs, workers planned?
- Communication: protocols per edge (REST/GraphQL/gRPC/WebSocket/SSE/
  webhooks); API style rules (pagination, errors (RFC 9457?), versioning,
  deprecation policy); messaging (queue vs stream, broker, delivery
  semantics, ordering, DLQs); API gateway/BFF?
- Composition: how dependencies are wired (DI style, composition roots).
- Frontend (products with a UI): the §4 Frontend/clients module fills
  this chapter's Frontend section; walk it before closing this
  checklist.

### → models.md
- Core entities and their relationships; aggregate/invariant boundaries.
- Storage paradigm per workload (relational, document, KV, graph,
  time-series, vector, search, blob, ledger).
- Consistency needs per operation: strong vs eventual, where staleness is
  acceptable; transaction strategy (ACID scope, sagas, outbox).
- ID strategy (UUIDv4/v7, ULID, sequences, natural keys).
- Schema evolution plan (expand-contract, zero-downtime rules).
- Validation: where enforced (edge, domain, DB constraints), library.
- Time handling (UTC storage, timezone display, bitemporal needs); money
  and quantities as typed values, never floats.
- Soft vs hard delete; audit/history requirements.
- Data lifecycle: retention, archival, purge, legal hold, erasure
  mechanics; PII classification and mapping.
- Analytics path: OLTP/OLAP split, warehouse, CDC; or explicitly none.
- Search: DB-native vs dedicated engine.
- Caching layers and invalidation strategy.
- Backup strategy incl. restore-testing cadence.

### → conventions.md
- Paradigm: OO / functional / procedural mix; where each.
- Typing level: strictness config, escape-hatch policy, structural
  (protocols/interfaces) vs nominal; enums over strings?
- Error handling: exceptions vs result types; error taxonomy; user-facing
  error contract; retryability signaling.
- DI mechanism; globals policy.
- Idempotency as a system-wide convention?
- Logging/telemetry conventions (structured, correlation IDs).
- Code standards: linting, formatting, review rules.

### → data-flow.md
- The 2-3 critical lifecycles, hop by hop, at design level (request,
  command, job, event).
- State: what lives where; who mutates it; session externalization
  (stateless compute?).
- Side-effect boundaries: where IO happens and how it's isolated.
- Failure paths: timeout/retry(jitter)/circuit-breaker/bulkhead policy;
  backpressure and load shedding; graceful-degradation tiers and kill
  switches; partial-failure consequences between non-atomic steps.
- Real-time delivery (push, SSE, WebSocket) and fan-out strategy, if any.
- Background jobs: queue, scheduling, retry, poison-message handling.

### → dependencies.md
- Full stack picks with version floors; per pick: maturity, license,
  hiring pool, exit cost.
- External services (DB, cache, broker, IdP, payments, email, storage,
  monitoring): provider each, and the outage behavior per dependency.
- Vendor lock-in posture: priced exit path per critical dependency (lock-in
  is a trade-off, not a sin; the failure is not pricing it).
- Dependency governance: update cadence, scanning, SBOM?

### → testing.md
- Strategy shape: pyramid/trophy; unit/integration/contract/e2e split.
- Doubles policy: structural fakes vs mocks; test data management (never
  prod PII).
- Contract testing at boundaries?
- Non-functional suites: load, chaos, security, accessibility: which,
  when?
- Testability requirements: deterministic time/IDs/randomness seams.
- Coverage/flake/runtime policies.

### → operations.md
- Environments: dev/staging/prod parity, preview envs, local dev story
  (one-command setup, seeds).
- CI/CD: stages, gates, artifact strategy; trunk-based?
- Release strategy: rolling/blue-green/canary/flags; rollback mechanics
  as a hard requirement (incl. data-compatible rollbacks).
- IaC tool; config vs secrets separation; secrets manager; rotation.
- Observability: logs/metrics/traces standard (OpenTelemetry?),
  correlation IDs, SLIs/SLOs per journey, symptom-based alerting,
  dashboards, runbooks.
- Incident process: severities, on-call, postmortems.
- DR: strategy (backup-restore / pilot light / warm standby /
  active-active), drill cadence.
- Cost: tagging from day one, budget alerts, unit-cost tracking; the
  usual surprises (egress, cross-AZ, logging, NAT) acknowledged.
- Migrations: how schema changes deploy relative to code.

### → glossary.md
- Elicit the domain's own vocabulary: ask the user to define every term
  of art, lifecycle state, and invented noun; one meaning per term per
  context. Capture disagreements: they usually mark context boundaries.

## 3. Quality attributes (numbers or it didn't happen)

Specify each relevant attribute as a scenario: stimulus → environment →
response → **response measure**. Walk the catalog; ask only what's
relevant, but record "not a driver" for the rest:

- Performance (p50/p95/p99 latency per endpoint class; throughput)
- Scalability & elasticity (10x behavior; time-to-absorb a stated burst)
- Availability (SLO % per tier + error budget policy)
- Recoverability (RTO/RPO per data class) & durability (data-loss bound)
- Consistency/integrity (staleness bounds, invariants)
- Security (threat-model coverage, patch SLA, ASVS level) & privacy
  (DSAR/erasure turnaround)
- Auditability & compliance (what's reconstructable, evidence needs)
- Usability, accessibility (WCAG target), i18n/l10n (locales, RTL)
- Maintainability/modifiability (named change classes with cost bounds)
- Testability, deployability (DORA targets), observability (MTTD,
  trace coverage)
- Portability, interoperability (standards), compatibility (support
  windows for clients/APIs)
- Capacity (headroom policy), cost efficiency (unit-cost ceiling),
  sustainability (if in scope), safety (if humans/hardware at risk)

Settle the classic trade-off pairs explicitly where they bite:
consistency vs availability, latency vs durability, security vs
usability, flexibility vs simplicity, cost vs redundancy, velocity vs
reliability, autonomy vs standardization.

## 4. Conditional modules (ask only if applicable)

- **Frontend/clients**: applicable whenever the mockup has screens or
  the product has any human-facing UI, which is nearly always; the
  mockup answers UX, not this (screens don't decide a rendering
  model), and skipping this module is a recorded decision, never a
  default: rendering model (SPA/MPA/SSR/SSG/islands) per page class;
  client-side routing; client entry points and bundles; state
  management split (server-state vs UI state); design system; the
  API-client seam to the backend (hand-rolled fetch layer, generated
  client, BFF); mobile approach; offline/conflict strategy;
  bundle/Web-Vitals budgets; client versioning and forced-upgrade
  policy. These answers fill architecture.md's Frontend section and
  data-flow's client state.
- **Multi-tenant SaaS**: tenant lifecycle (onboard/migrate/offboard/
  export); noisy-neighbor controls and per-tenant quotas; entitlements
  and plan-gated flags; usage metering and billing integration;
  white-labeling/custom domains.
- **AI/ML**: hosted API vs self-hosted; model selection + fallback chain;
  RAG design (chunking, embeddings, vector store, retrieval eval); prompt
  versioning and evals as regression tests; guardrails (injection, PII);
  cost/latency budgets per inference; non-determinism in tests; data
  rights for training.
- **Compliance-heavy**: control-to-requirement traceability; evidence
  automation; audit-trail architecture; data-processing agreements.
- **Legacy/migration** (rarely absent even in "greenfield"): coexistence
  (strangler fig, parallel run); data migration (big-bang vs trickle,
  validation, fallback); anti-corruption layer; cutover + rollback +
  decommission plan.
- **Real-time/offline-first**: push architecture, presence, CRDTs vs
  last-write-wins, sync engine.
- **Public API as product**: docs, SDKs, sandbox, versioned stability
  guarantees, rate-limit tiers.

## 5. Wrap-up sweep (before the formalization gate)

- What is the riskiest assumption, and what is the cheapest spike that
  would test it? Record spikes as pre-build work.
- Pre-mortem: "it's 18 months later and this failed: why?" Record the
  answers as risks.
- Agree the **walking-skeleton slice**: the thinnest end-to-end path
  (UI → API → data → deploy → observe) to build first; it becomes part of
  the formalization summary.
- Confirm the deferred-decisions list: every two-way door left open, each
  with the trigger that will force it.
- Run the red-flag screen below; surface any hits to the user as
  questions, not verdicts.

## 6. Red-flag screen

Check the recorded decisions against the classic failure modes; each hit
becomes one final question ("you chose X with Y: accepted trade-off or
revisit?"):

- Distribution before boundaries: microservices chosen while domain
  boundaries or team count don't demand them.
- Fantasy scale: designing for 100x. Or its inverse: guaranteed 10x
  growth with no plan.
- Stack beyond the team: tech the current team can't build or operate at
  3 a.m.; innovation tokens overspent on multiple layers at once.
- Shared database across service boundaries; dual writes without an
  outbox; distributed transactions where boundaries should move.
- Sync call chains across contexts (availability = 0.99^n) without
  timeouts/retries/idempotency decided.
- One availability number for everything; NFRs still adjectives; no
  latency budget decomposition.
- Security, tenancy isolation, audit, or accessibility deferred to
  "later": the retrofits that cost 10x.
- No rollback path; migrations that make deploys one-way.
- Backups without restore drills; DR targets without a drill plan.
- Observability absent from v1 scope; no cost model or unit-economics
  target ("the first invoice is the capacity plan").
- Conway mismatch: decomposition granularity exceeds team count or
  cognitive-load budget.
- Vendor lock-in unpriced; no exit note on any critical dependency.
- Everything-flexible: extension points and abstractions for futures
  nobody ordered (speculative generality).
- No walking skeleton in the plan: integration risk saved for the end.
- Frontend undesigned: a mockup full of screens while every recorded
  decision is server-side; rendering model, state management, and
  design system never chosen.
