# Topic Files: Applicability, Templates, Checklists

Topics are written as numbered chapters in this reading order:
`01-architecture.md`, `02-models.md`, `03-conventions.md`,
`04-data-flow.md`, `05-dependencies.md`, `06-testing.md`,
`07-operations.md`, `08-glossary.md`. The headings below use the
logical topic names; the chapter number is a filename prefix only.

Every topic file uses the frontmatter defined in SKILL.md Phase 3 and the
exact headings shown here. A deep-dive (inline or subagent) must return
content for every required section; write "None found" plus where you
looked rather than omitting a section.

## architecture.md

**Applicable:** always.

Required sections:

- `## Layers` — the layers/tiers that exist, each with its directories and
  dependency direction (what imports what).
- `## Module boundaries` — per module: public surface; what it may not
  import and what may not import it, as enforced or as observed.
- `## Entry points` — every process entry (CLI, server, workers) with
  `file:line`.
- `## Communication` — how parts talk: HTTP routes, websocket commands,
  events, queues; where each is registered and dispatched.
- `## Composition` — where objects are wired together (DI container,
  factories, `main()`).
- `## Frontend` — for products with a human-facing UI: rendering model
  (SPA/MPA/SSR/SSG/islands) per page class, routing, client entry
  points and bundles, design system / component library, and the
  API-client seam to the backend. A project with no human-facing UI
  records exactly that, in one line; a recorded decision to defer or
  skip the frontend satisfies the section too, cited
  ("deferred per architecture-interview.md §Qn").

Checklist: dependency direction verified by reading imports, not assumed
from directory names; registries and dispatch tables enumerated in full,
not sampled; the rendering model read from the client build config and
entry files, not assumed from the framework's name.

## models.md

**Applicable:** the codebase defines domain or data types (entities,
schemas, DTOs). Inapplicable only for pure-script repos.

Required sections:

- `## Entities` — table: name, definition site, storage (DB table /
  in-memory / file), one-line purpose.
- `## Fields and types` — per entity: fields with types, optionality,
  defaults.
- `## Relationships` — how entities reference each other (foreign keys,
  composition, ID references).
- `## Boundaries` — which representations exist across DB schema ↔ domain
  ↔ API/DTO, and where each conversion happens.
- `## Validation` — where and how data is validated (library, custom, or
  recorded as absent).
- `## Schema` — per-table DDL as the migrations define it: columns with
  types and defaults, indexes, constraints; note tables with no
  corresponding code model.

Checklist: every entity appears in the table, not just the central ones;
each serialization/conversion site is cited; schema transcribed from the
migration files, not inferred from models.

## conventions.md

**Applicable:** always.

Required sections:

- `## Paradigm` — the OOP/functional/procedural mix, and which parts use
  which.
- `## Typing` — the level actually in force: strictness config quoted;
  Protocol/interface usage; enum usage; escape hatches present (`Any`,
  `as`, ignore comments) with counts and locations.
- `## Error handling` — exceptions vs result types; where errors cross
  boundaries; logging pattern.
- `## Dependency injection` — how dependencies reach code: constructor,
  parameters, globals, container.

Checklist: report what IS, including violations of the project's own
configs; counts come from grep, not impressions.

## data-flow.md

**Applicable:** the project has runtime request/command/event flows
(servers, UIs, pipelines). Not applicable to pure utility libraries.

Required sections:

- `## Lifecycles` — each major flow (request, command, job) traced end to
  end with `file:line` at each hop.
- `## State` — where state lives (stores, caches, DB sessions, client
  state) and who mutates it; for UI products, the client split:
  server-state vs UI state and the owning store/library per side.
- `## Side-effect boundaries` — where IO happens (DB, network, disk) and
  how it is isolated, or that it is not.
- `## Failure paths` — what happens on exception, disconnect, or timeout
  at each boundary of the traced flows; consequences of partial failure
  between non-atomic steps (state saved but events dropped, etc.).

Checklist: at least the top three flows traced hop by hop; state ownership
named per store; every catch/teardown site on the traced flows located,
and uncaught propagation stated as such.

## dependencies.md

**Applicable:** the project declares external dependencies.

Required sections:

- `## Runtime dependencies` — table: package, version constraint, what it
  is used for, where it is integrated.
- `## Dev and tooling` — table: package, role.
- `## External services` — databases, APIs, brokers: connection setup
  sites and config sources.

Checklist: derived from manifests cross-checked against imports; declared
but unimported packages recorded as facts.

## operations.md

**Applicable:** the project has runnable processes or deployment
configuration.

Required sections:

- `## Processes` — every runnable process: exact local command, container
  command, and what it depends on.
- `## Configuration` — the environment variable inventory: name, default,
  consuming code, documented where.
- `## Infrastructure` — containers/services with images, ports,
  healthchecks, compose profiles, volumes.
- `## Developer workflow` — exact commands for tests, type check,
  lint/format, and migrations.

Checklist: commands verified against compose files/scripts/README, not
guessed; every compose service listed with its profile.

## glossary.md

**Applicable:** the codebase has domain concepts whose meaning is not
inferable from code structure alone.

Required sections:

- `## Concepts` — term → what it means in this system → where implemented
  (`file:line`).

Checklist: covers every mechanism whose name alone does not explain it
(invented nouns, domain jargon, lifecycle states); entries explain intent,
not just location.

## testing.md

**Applicable:** a test suite exists. If absent, the DESIGN.md index
records: "testing — absent (no test suite found under <paths checked>)".

Required sections:

- `## Layout` — where tests live, how they map to source, and the exact
  command that runs them.
- `## Doubles` — how the suite fakes collaborators (structural fakes,
  mocks, fixtures) with cited examples.
- `## Coverage shape` — which areas are heavily tested and which have no
  tests, by module, from file inspection (a coverage tool only if the
  project already configures one).

Checklist: the run command verified against project scripts/config, not
guessed; every test directory listed, including any not wired into the
runner.
