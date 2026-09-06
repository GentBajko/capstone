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

The machine-readable form of everything below lives in
`schema.txt` beside this file: one record per output type, with the
frontmatter keys it owes, its `## ` headings in order, and the columns
its tables carry. `scripts/map-check.sh` reads that file and no copy of
it, and `lint-sync` checks 15 and 20 fail when the two stop agreeing, so
a heading renamed here without being renamed there turns the lint red.

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
  events, queues, streams; where each is registered and dispatched,
  **and the payload each carries in both directions**: the named
  entity or DTO from `02-models.md` where one exists, the fields
  inline (name, type, optionality) where none does - an ad-hoc dict
  pushed to a broker is a contract even though no class declares it.
  Cite the send and receive sites `file:line`. A channel that
  `09-interfaces.md` lists under Produces or Consumes cites its
  payload section there (`09-interfaces.md § GET /records`) instead of
  repeating the field table: the chapter holds the one copy
  `quarry check` compares, and internal channels keep their fields
  inline here.
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
not sampled; every Communication row names its payload in both
directions, inline or by citing its `09-interfaces.md` section, read
from the call site rather than the route name - a
bare route list fails the section; the rendering model read from the
client build config and
entry files, not assumed from the framework's name.

## models.md

**Applicable:** the codebase defines domain or data types (entities,
schemas, DTOs). Inapplicable only for pure-script repos.

Required sections:

- `## Entities`: table: name, definition site, storage (DB table /
  in-memory / file), one-line purpose.
- `## Fields and types`: one `### <Entity>` section per entity,
  heading text equal to the type's name as the code spells it
  (`### Record`, `### RecordSummary`), written once and never with
  backticks: the heading is the join key a `schema` reference in
  `09-interfaces.md` resolves through, and `quarry check` compares
  the table under it against the consumer's. Each section holds a
  table whose header carries at least `Field`, `Type`, `Required`;
  `Default` and `Notes` are optional columns. One row per field,
  `Required` as `yes` or `no`, `Type` as the code names it. An enum
  field lists its accepted values in `Notes` as `accepted: a, b`. A
  field whose type is another entity writes that entity's name in
  `Type`, and a list of them `<Entity>[]`.
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
every entity in the table has its `### <Entity>` section under Fields
and types, so a `schema` reference in `09-interfaces.md` always
resolves; each serialization/conversion site is cited; schema
transcribed from the migration files, not inferred from models.

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
  consuming code, documented where. A name matching a config `redact`
  pattern (default `["*_SECRET", "*_TOKEN", "*_PASSWORD", "*_KEY"]`; `*`
  matches any prefix or suffix, case-insensitive) gets `<redacted>` in the
  Default column, and its value appears nowhere in the reference: not in
  this chapter, not in an Infrastructure excerpt, not beside a `file:line`
  pointer. Redact by name, whatever the value looks like; a placeholder
  such as `changeme` is redacted too.
- `## Infrastructure`: containers/services with images, ports,
  healthchecks, compose profiles, volumes.
- `## Developer workflow`: exact commands for tests, type check,
  lint/format, and migrations.

Checklist: commands verified against compose files/scripts/README, not
guessed; every compose service listed with its profile; no value of a
`redact`-matched variable quoted anywhere in the chapter.

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

The chapter carries both directions of the repo's cross-repo edges.
The frontmatter `edges:` block is the canonical form: it is what
`map` writes and what quarry reads. The Produces and Consumes tables
under it render the same rows for human readers and for a plain
markdown viewer, and are rewritten from the block on every run.

**Who owns which cell.** `map` writes `kind`, `name`, `site` and
`schema` per row, read from the code. **It never writes `to` or
`from`.** No repository holds the other repository's name: a
publisher holds a topic name, a route holds a path, a client holds a
base URL and a path, so the far end of an edge cannot be derived by
reading one repo. Quarry derives it instead, by joining two repos'
declarations on `(kind, name)`, and a person answers only where that
join is ambiguous or empty (core.md's Edge confirmation). A `to` or
`from` already in the block came from a person or from that ask, and
no run edits it.

```yaml
known_as: [ingest.internal]
edges:
  produces:
    - { kind: sqs,  name: file-ingest, site: src/publish.rs, schema: FileIngestMessage }
  consumes:
    - { kind: http, name: "GET /users/{id}", site: src/auth.rs, schema: UserRef, from: identity-api }
```

- `kind` and `name` are required. `kind` is lowercase and free-form
  (`http`, `sqs`, `event`, `schema`, ...). `name` identifies the
  contract as the code spells it (`GET /customers/{id}`,
  `file-ingest`), verbatim.
- `site` is a repo-relative **path with no line number**. The chapter
  is normative and a line number drifts on every edit; quarry strips
  a trailing `:<line>` where it finds one, so a page an older
  capstone wrote still resolves.
- `schema` names a `### <Entity>` section in this repo's
  `02-models.md`, `<Entity>[]` for a list of them. Absent means the
  row's payload is written inline instead, as a field table in its
  `### <Name>` section - the right form for an ad-hoc payload no type
  declares.
- `to` is a string, a list of strings, or absent; `from` is a string
  or absent. Absent means quarry decides. `unknown` means the
  question is settled and no sibling repo sits on the other side:
  quarry keeps the row as a searchable publication, never joins it,
  and never re-asks.

**Merging a run's rows into the block.** Every `map` run that writes
this chapter - build, refresh, `rebuild`, a `map interfaces` topic
run alike - reads the existing block first and merges by
`(direction, kind, name)`:

1. A row the block already carries keeps its `to`/`from` byte for
   byte; its `site` and `schema` are refreshed from this run's read.
2. A row the code has and the block lacks is added with no `to` and
   no `from`.
3. A row the block has and the code no longer does is dropped, and
   the run report names it
   (`dropped: sqs old-topic (was to record-store)`), so a lost edge
   is visible rather than silent.

Then the tables are rendered from the merged block, and the Edge
confirmation ask (core.md) runs over whatever quarry reports as
ambiguous.

Required sections:

- `## Produces`: table with columns `Kind`, `Name`, `To`, `Site`, one
  row per `edges.produces` entry, in block order. `Kind`, `Name` and
  `Site` render those fields; `Site` is backticked. `To` renders
  `to`: the consuming repo's name, several names separated by `, `,
  `unknown`, or `-` where the block carries none and the join has not
  settled it. A name may be written as a relative link to that repo's
  own chapter,
  `[data-collection](../data-collection/09-interfaces.md)`, when the
  docs sit side by side in a quarry docs repo; readers strip link
  syntax before matching, so both forms index identically, and a dead
  link helps nobody. A person who knows this repo publishes something
  no sibling repo consumes - a broadcast event, a public topic, an
  endpoint with no client anywhere - can write `unknown` in `To`, and
  the row stays a publication with no edge. `map` writes neither an
  invented repo name, which becomes a missing edge nobody can trace
  back, nor a guessed `unknown`, which hides a real consumer.
  Below the table, one `### <Name>` section per row, heading text
  equal to the row's `Name` cell verbatim
  (`### GET /records`, `### file-ingest`), holding the payload this
  repo emits on that contract in one of two forms. Either one line,
  `Model: <Entity>` (`Model: <Entity>[]` for a list), which renders
  the row's `schema` and names a `### <Entity>` section under this
  docs area's `02-models.md` Fields and types; or a table with
  columns `Field`, `Type`, `Required` (a `Notes` column is optional):
  one row per field, `Required` as `yes` or `no`, `Type` as the code
  names it. Write `Model:` whenever the payload is a named entity or
  DTO that `01-architecture.md`'s Communication section identifies,
  and inline the table only for an ad-hoc payload no type declares: a
  hand-written table that copies a model is free to drift from it.
  Read either from the serializer or response type at the row's
  `Site`, never from a consumer's docs. Two rows that share a `Name`
  (one contract, two consumers) share one section.
- `## Consumes`: same table shape with `From` in place of `To`, one
  row per `edges.consumes` entry, `Site` the client/subscriber site.
  Below the table, one `### <Name>` section per row, in the same two
  forms: `Model: <Entity>` where the client deserializes into a type
  this repo's `02-models.md` declares, and otherwise the field table,
  listing only the fields this repo actually reads (the ones
  dereferenced at the row's `Site`) with the type and optionality the
  client code assumes. Prefer the table where the client reads a
  subset: it is what `quarry check` compares against the producer,
  and a model names fields this repo may never touch. A version
  suffix in parentheses is allowed on the heading
  (`### file-ingest (v2)`) when the code pins one. Never point at a
  schema file in the other repo: a pointer means the reader clones
  the consumer anyway, and the contract check compares fields, not
  pointers.

The chapter's frontmatter carries one key beyond the stamps and
the edges block, `known_as`: a YAML list of every name other
systems reach this repo by, read from the same sources the
operations chapter's Infrastructure and Configuration sections
cite - compose service names, ingress and gateway hosts,
Kubernetes Service and Deployment names, service-discovery
registrations, the hostname a client's env var would hold. Each
entry verbatim as the deploy config spells it, deduplicated, the
repo's own name left out; `known_as: []` when the sources name
nothing, so an empty list is a recorded observation rather than an
omission. Quarry resolves a `to`/`from` value against every
registered repo's `known_as` before marking the edge missing,
which is what lets a consumer that knows this repo as
`records.internal` land on the same edge.

```yaml
known_as: [records.internal, records-service, records-svc]
```

Format rules the index depends on: quarry reads the `edges:` block
first, then a page written by an older capstone that carries
top-level `produces:`/`consumes:` lists, then the tables, and stops
at the first form it finds; columns are matched by header
name, not position; cells are read after stripping backticks and
link syntax; tables count only on a page named `09-interfaces.md`
and never inside a fenced code block, so a chapter documenting the
format declares nothing. `kind` and `name` are required per row and
`to`/`from` is not; a repo name is the last path segment of that
repo's origin URL, or one of the names that repo lists under
`known_as`, or, in a monorepo with `workspaces` configured, the
workspace name (which is also the quarry target name; see
`core.md`). Either side of an edge may name the other; when both do
and disagree, the disagreement stays visible in each repo's own
chapter rather than being merged away.

**Payload sections.** `quarry check`, run in the producer's CI, pairs
each Produces section here with the Consumes section of the same
`Name` in every consumer's chapter and compares field by field: a
field a consumer lists that the producer's table no longer has is a
break, a type change is a break, a `Required` flip is a warning.
Matching is exact on the heading first, then `<Name> (` as a prefix,
case-insensitive; columns are matched by header name, not position;
`Required` accepts `yes|no|true|false`; types are compared after
trimming, case-folding and collapsing whitespace. Write the heading
text exactly as the `Name` cell reads, without backticks. A heading is
not a table cell, so a `Name` that escapes a pipe (`GET /b \| GET /c`)
drops the escape there: `### GET /b | GET /c`.

A section holding `Model: <Entity>` and no table resolves through
`02-models.md`'s `### <Entity>` section in the same docs area (exact
heading first, then `<Entity> (` as a prefix, case-insensitive), and
that table is compared under the same column rules with `Default` and
`Notes` ignored; the `[]` on a list changes nothing about the fields.
A model this docs area does not hold is the warning
`model <Entity> not in 02-models.md; nothing to compare`, never a
break, and `map check`'s schema pass reports the same dangling
reference as a finding. A section holding both a `Model:` line and a
table is read from the table, with a warning; a section holding
neither is a finding.

When config `interfaces_frontmatter` is `true`, the chapter also
carries the legacy top-level `produces:`/`consumes:` lists beside the
`edges:` block, for a machine consumer pinned to the 6.2 shape:

```yaml
known_as: [records.internal]
produces:
  - kind: sqs
    name: file-ingest
    to: data-collection
    site: src/publish/sqs.py
consumes:
  - kind: http
    name: GET /customers/{id}
    from: customers-service
    site: src/clients/customers.py
```

Leave it off unless something needs it: quarry reads the `edges:`
block, and a second copy of the same rows is one more thing to drift.
`known_as` and `edges:` are written whether or not it is on.

Checklist: every publish and client site found by reading the code
(route registrations, queue publishers/subscribers, generated
clients, webhook senders), not guessed from config names; every row's
`site` a path with no line number, tracked in git (`map check` and
`quarry update --strict` both reject a path the tree does not hold; a
prescriptive chapter's planned paths are the one exception);
internal calls between this repo's own modules excluded - the chapter
is cross-repo edges only; kinds lowercase; no row missing `kind`,
`name` or `site`; every Produces and Consumes row has its
`### <Name>` payload section, read from the code at the row's `site`,
naming a `### <Entity>` this docs area's `02-models.md` holds or
carrying its own `Field`, `Type`, `Required` table; the tables
rendered from the block, row for row; `known_as` copied
from the deploy config, never invented; every `to` and `from` the
block already carried still reading exactly as it did before the run.

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
