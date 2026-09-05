# Topic Files: Applicability, Templates, Checklists

Topics are written as numbered chapters in this reading order:
`01-architecture.md`, `02-models.md`, `03-conventions.md`,
`04-data-flow.md`, `05-dependencies.md`, `06-testing.md`,
`07-operations.md`, `08-glossary.md`, `09-interfaces.md`. The headings below use the
logical topic names; the chapter number is a filename prefix only.
`logic/`'s per-scenario files join the same topic index (core.md's
Index maintenance rule) under the `logic` topic name, one row per
scenario file; their required sections live in `protocols/logic.md`
(Phase B), not here, since they're generated scenario-by-scenario
rather than by a single deep-dive per chapter.

Every topic file uses the frontmatter defined in SKILL.md Phase 3 and the
exact headings shown here. A deep-dive (inline or subagent) must return
content for every required section; write "None found" plus where you
looked rather than omitting a section.

## architecture.md

**Applicable:** always.

Required sections:

- `## Layers`: the layers/tiers that exist, each with its directories and
  dependency direction (what imports what).
- `## Module boundaries`: per module: public surface; what it may not
  import and what may not import it, as enforced or as observed.
- `## Entry points`: every process entry (CLI, server, workers) with
  `file:line`.
- `## Communication`: how parts talk: HTTP routes, websocket commands,
  events, queues; where each is registered and dispatched.
- `## Composition`: where objects are wired together (DI container,
  factories, `main()`).
- `## Frontend`: for products with a human-facing UI: rendering model
  (SPA/MPA/SSR/SSG/islands) per page class, routing, client entry
  points and bundles, design system / component library, and the
  API-client seam to the backend. A project with no human-facing UI
  records exactly that, in one line; a recorded decision to defer or
  skip the frontend satisfies the section too, with the decision and
  rationale written inline.

Checklist: dependency direction verified by reading imports, not assumed
from directory names; registries and dispatch tables enumerated in full,
not sampled; the rendering model read from the client build config and
entry files, not assumed from the framework's name.

## models.md

**Applicable:** the codebase defines domain or data types (entities,
schemas, DTOs). Inapplicable only for pure-script repos.

Required sections:

- `## Entities`: table: name, definition site, storage (DB table /
  in-memory / file), one-line purpose.
- `## Fields and types`: per entity: fields with types, optionality,
  defaults.
- `## Relationships`: how entities reference each other (foreign keys,
  composition, ID references).
- `## Boundaries`: which representations exist across DB schema ↔ domain
  ↔ API/DTO, and where each conversion happens.
- `## Validation`: where and how data is validated (library, custom, or
  recorded as absent).
- `## Schema`: per-table DDL as the migrations define it: columns with
  types and defaults, indexes, constraints; note tables with no
  corresponding code model.

Checklist: every entity appears in the table, not just the central ones;
each serialization/conversion site is cited; schema transcribed from the
migration files, not inferred from models.

## conventions.md

**Applicable:** always.

Required sections:

- `## Paradigm`: the OOP/functional/procedural mix, and which parts use
  which.
- `## Typing`: the level actually in force: strictness config quoted;
  Protocol/interface usage; enum usage; escape hatches present (`Any`,
  `as`, ignore comments) with counts and locations.
- `## Error handling`: exceptions vs result types; where errors cross
  boundaries; logging pattern.
- `## Dependency injection`: how dependencies reach code: constructor,
  parameters, globals, container.

Checklist: report what IS, including violations of the project's own
configs; counts come from grep, not impressions.

## data-flow.md

**Applicable:** the project has runtime request/command/event flows
(servers, UIs, pipelines). Not applicable to pure utility libraries.

Required sections:

- `## Lifecycles`: each major flow (request, command, job) traced end to
  end with `file:line` at each hop.
- `## State`: where state lives (stores, caches, DB sessions, client
  state) and who mutates it; for UI products, the client split:
  server-state vs UI state and the owning store/library per side.
- `## Side-effect boundaries`: where IO happens (DB, network, disk) and
  how it is isolated, or that it is not.
- `## Failure paths`: what happens on exception, disconnect, or timeout
  at each boundary of the traced flows; consequences of partial failure
  between non-atomic steps (state saved but events dropped, etc.).

Checklist: at least the top three flows traced hop by hop; state ownership
named per store; every catch/teardown site on the traced flows located,
and uncaught propagation stated as such.

## dependencies.md

**Applicable:** the project declares external dependencies.

Required sections:

- `## Dev and tooling`: table: package, role.
- `## External services`: databases, APIs, brokers: connection setup
  sites and config sources.

Checklist: dev/tooling packages derived from manifests; every external
service's connection setup site cited `file:line`.

## operations.md

**Applicable:** the project has runnable processes or deployment
configuration.

Required sections:

- `## Processes`: every runnable process: exact local command, container
  command, and what it depends on.
- `## Configuration`: the environment variable inventory: name, default,
  consuming code, documented where.
- `## Infrastructure`: containers/services with images, ports,
  healthchecks, compose profiles, volumes.
- `## Developer workflow`: exact commands for tests, type check,
  lint/format, and migrations.

Checklist: commands verified against compose files/scripts/README, not
guessed; every compose service listed with its profile.

## glossary.md

**Applicable:** the codebase has domain concepts whose meaning is not
inferable from code structure alone.

Required sections:

- `## Concepts`: term → what it means in this system → where implemented
  (`file:line`).

Checklist: covers every mechanism whose name alone does not explain it
(invented nouns, domain jargon, lifecycle states); entries explain intent,
not just location.

## interfaces.md

**Applicable:** config `interfaces` is `auto` (the default) AND the
codebase talks to another repository (in `architecture`'s
prescriptive mode: the design declares that it will; `Site` cells
then hold planned paths): it publishes something others
consume (an HTTP API, queue messages, events, a shared schema) or
consumes another repo's (an API client, a queue subscriber, a
webhook handler for someone else's events). "Another repository"
means a sibling codebase in the same organization or ecosystem - one
with its own origin URL that could carry its own docs - never a
third-party service: Stripe, S3, and their kind belong in
`05-dependencies.md`'s External services, and a repo whose only
outside talk is to vendors gets no chapter. Most single-repo
projects therefore never see this chapter, which is the intended
default. `interfaces: "off"` skips the pass entirely.

The chapter carries both directions of the repo's cross-repo edges,
as tables. Cross-repo tooling (quarry) indexes exactly these tables,
and a plain markdown viewer gets a navigable graph from the links,
so there is one form and no mirror to drift.

Required sections:

- `## Produces`: table with columns `Kind`, `Name`, `To`, `Site` -
  one row per thing this repo publishes for another repo: kind is
  free-form lowercase (`http`, `sqs`, `event`, `schema`, ...), name
  identifies the contract (`GET /customers/{id}`, `file-ingest`),
  `To` names the consuming repo: as a relative link to that repo's
  own chapter, `[data-collection](../data-collection/09-interfaces.md)`,
  when the docs are gathered side by side (a quarry docs repo), or as
  the plain repo name when they are not - readers strip link syntax
  before matching, so both forms index identically, and a dead link
  helps nobody. `Site` is the backticked `` `path:line` `` of the
  publish site.
- `## Consumes`: same table shape with `From` in place of `To`, one
  row per contract this repo reads from another repo, `Site` the
  client/subscriber site. Inline the contract fields this repo
  actually reads (a short list under the table or a `Fields` column)
  rather than pointing at a schema file in the other repo: a pointer
  means the reader clones the consumer anyway.

Format rules the index depends on: columns are matched by header
name, not position; cells are read after stripping backticks and
link syntax; tables count only on a page named `09-interfaces.md`
and never inside a fenced code block, so a chapter documenting the
format declares nothing. `kind`, `name`, and `to`/`from` are
required per row; a repo name is the last path segment of that
repo's origin URL. Either side of an edge may declare it; when both
do and disagree, the disagreement stays visible in each repo's own
chapter rather than being merged away.

When config `interfaces_frontmatter` is `true`, mirror the tables
into frontmatter lists too (same required fields, lowercase `kind`):

```yaml
produces:
  - kind: sqs
    name: file-ingest
    to: data-collection
    site: src/publish/sqs.py:57
consumes:
  - kind: http
    name: GET /customers/{id}
    from: customers-service
    site: src/clients/customers.py:12
```

Checklist: every publish and client site found by reading the code
(route registrations, queue publishers/subscribers, generated
clients, webhook senders), not guessed from config names; every row's
`Site` verified `file:line`; internal calls between this repo's own
modules excluded - the chapter is cross-repo edges only; kinds
lowercase; no row missing `kind`, `name`, or `to`/`from`.

## testing.md

**Applicable:** a test suite exists. If absent, the index
records: "testing: absent (no test suite found under <paths checked>)".

Required sections:

- `## Layout`: where tests live, how they map to source, and the exact
  command that runs them.
- `## Doubles`: how the suite fakes collaborators (structural fakes,
  mocks, fixtures) with cited examples.
- `## Coverage shape`: which areas are heavily tested and which have no
  tests, by module, from file inspection (a coverage tool only if the
  project already configures one).

Checklist: the run command verified against project scripts/config, not
guessed; every test directory listed, including any not wired into the
runner.
