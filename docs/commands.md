# Capstone command reference

Every command, its arguments, what it reads, what it writes, and what
must exist first. For installation and updating see the
[README](../README.md); for contributing see
[CONTRIBUTING](../CONTRIBUTING.md).

Every command also has a page of its own under `docs/commands/`, linked
from its section below. Those pages answer the questions this file
does not: which command to reach for, what the sibling command next to
it is for, and how to tell a run worked. This file stays the
argument-by-argument reference.

**Jump to:**

1. [Invocation](#invocation)
2. [Three entry points](#three-entry-points)
3. [Reference commands](#reference-commands) — [`map`](#map) · [`edges`](#edges) · [`doctor`](#doctor) · [`review`](#review) · [`review retro`](#review-retro)
4. [The greenfield pipeline](#the-greenfield-pipeline) — [`start`](#start)
5. [The feature chain](#the-feature-chain) — [`feature`](#feature-description)
6. [`help`](#help) and [`core`](#core)
7. [What lands where](#what-lands-where)
8. [Shared mechanics](#shared-mechanics)
9. [CI](#ci)

## Invocation

Commands are namespaced: `/capstone:map`, `/capstone:review`. On
harnesses with a single context file (Gemini CLI), the dispatcher at
`skills/core/references/dispatcher.md` routes the first argument to
the same protocols.

A bare `capstone` with no argument runs `start`. To get a bare
`/capstone` in Claude Code, see the README's "Installing on other
agents" section.

Arguments are positional words, not flags: `map check`,
`review backend`, `start stack refresh`, `groom add CSV export`.

There are ten commands: `map`, `edges`, `doctor`, `review`, `groom`,
`plan`, `implement`, `feature`, `start`, `help`. The pipeline stages are not
among them - each is `start <stage>` - because a stage run outside its
chain is the exception, and a flat list of eighteen hides which five
you actually reach for.

## Three entry points

Diagrammed end to end in [flows.md](flows.md): what each one does, in
what order, where it stops for you, and what it leaves on disk.


Everything else is a stage one of these runs, reached as that
command's second word when you want to enter mid-chain: `start uiux`,
`start stack refresh`. There are ten commands and no more.

| Situation | Command |
| --- | --- |
| A repo that already has code | `map` |
| A product that doesn't exist yet | `start` |
| One change to a mapped project | `feature <description>` |

---

## Reference commands

### `map`

[Page: when to reach for it, and how to tell it worked](commands/map.md)

Builds the factual reference, and keeps it true. **One verb because
the branch is readable off disk:** no index means build, an index
means refresh only what drifted.

| Argument | Behavior |
| --- | --- |
| *(none)* | No index → full build. An index → refresh what drifted. With `workspaces` set, each workspace on its own. |
| `check` | Read-only trust report. Writes nothing, not even a ledger entry. |
| `rebuild` | Force a full rewrite of a reference that looks current. |
| `<topic>` | Rebuild one chapter: `architecture`, `models`, `conventions`, `data-flow`, `dependencies`, `testing`, `operations`, `glossary`, `interfaces`. |
| `<workspace>` | With `workspaces` set, map that one workspace: refresh it, or build it when it has no index. |

**Writes** `docs/capstone/00-index.md`, the numbered chapters
(`09-interfaces.md`, the cross-repo produces/consumes tables with one
`### <Name>` payload section per row, appears when the repo talks to
another repo; the `interfaces` config key can turn it off), `logic/`
(business-logic scenarios) and `uiux/` (surface chapters); the
`extract` config key can skip either extraction pass.
Every chapter, and every `logic/` and `uiux/` file extraction wrote,
carries `generated_at_commit`, `generated_date`, `capstone_version`
(when the installation's identity is readable),
`content_hash` and `paths_covered` in frontmatter; the index carries
no stamps. Those globs are what a later refresh diffs against (a
repo-wide list also excludes the docs area, so writing the reference
never marks it stale), and
the content hash is the stamp that survives squash and rebase merges,
so an unreachable commit degrades to a per-file check instead of a
full rebuild.

`09-interfaces.md`'s frontmatter carries the canonical `edges:` block:
one row per cross-repo edge with its `kind`, `name`, `site` (a path,
no line number) and `schema`, and the Produces and Consumes tables
below it are rendered from those rows. `map` writes exactly those four
fields and never a `to` or a `from`, because no repo holds another
repo's name; quarry supplies them by joining every registered repo's
rows on `(kind, name)`. The frontmatter also records what other
systems call this repo: a
`known_as` list, read from the deploy config the
operations chapter cites (compose service names, ingress hosts,
Kubernetes manifests), so quarry can resolve a consumer's
`from: records.internal` to this repo's folder. Where the join finds
several candidates on one contract, and `cross_repo: "auto"` has
quarry on PATH, the interfaces pass reads
`quarry docs index --json`'s `ambiguous` rows and asks you, once, in
one digest; the answer is written into that row and no run edits it
afterwards. `unknown` is a legal answer and means no sibling repo sits
on the other side: quarry keeps the row as a publication and lists
possible consumers by name.

**A refresh also fills gaps**, not just staleness: entry points no
`logic/` scenario claims and surfaces no `uiux/screens/` chapter
claims get extracted. Interview-derived files in either folder are
never overwritten by extraction.

`map check` reports eight things in two halves. The script half,
`skills/core/scripts/map-check.sh [docs_dir ...]` (bash; no model, no
API key; default `docs/capstone`, several arguments for a monorepo's
workspaces), does staleness (part 1), unfolded `changelog.d/`
fragments (part 7, informational only; fragments never flip the
verdict) and the mechanical schema pass (part 8: required frontmatter
keys, `09-interfaces.md`'s `known_as` among them, which is a finding
when the key is absent and when its value is a scalar instead of a
list; required headings, in order, per the record for that kind of
file; table columns matched by header name; and, read off `09-interfaces.md`'s
frontmatter `edges:` block, four edge findings - a row with no `site`,
a `site` whose path fails `git ls-files --error-unmatch` or names
something other than one tracked file so a directory and a wildcard
both count, a row with no `### <Name>` payload section or one holding
neither a field table nor a `Model:` line, and a `schema` or `Model:`
naming an entity `02-models.md` has no `### <Entity>` section for;
plus secret-shaped strings reported by pattern name), then ends with a
machine-parseable verdict:

```text
MAP CHECK: current
MAP CHECK: stale (<N> findings)
```

What the pass checks each file against is one record in
`skills/core/references/schema.txt`: the frontmatter keys that kind of
file owes, its `## ` headings in order, and its table columns. The
script reads that file at runtime, so `logic/` scenarios, `mockup/`
screens and `uiux/` chapters are held to their section lists the way a
chapter is, and `lint-sync.sh` keeps the records equal to the prose in
`topics.md` and in the protocols. A schema file that cannot be read
costs the headings and the tables alone; the run says so and finishes
with the same verdict and exit code.

Exit 0 on current, 1 on stale, 2 on a usage error. `--headings` prints
the required-headings list from the schema (`lint-sync.sh` keeps it
equal to `topics.md`); `--schema` prints the resolved schema path and
its record count; `--patterns` prints the secret patterns by name:
`aws-access-key`, `github-token`, `slack-token`, `stripe-key`,
`google-api-key`, `private-key`. Findings name the file and the
pattern, never the matched text.

The model half - pointer drift (a fixed sample: the first five
`file:line` pointers in the files part 1 reported stale, in index
order), absorption drift, dependency re-vetting, logic coverage,
design coverage - runs the script first, quotes its output, and ends
with its own line, which only the review workflow reads:

```text
MAP REVIEW: clean
MAP REVIEW: <N> findings
```

**Ledger key** `map/<topic|all>@<stamp>`.

### `edges`

[Page: when to reach for it, and how to tell it worked](commands/edges.md)

Fills the consumer side of cross-repo edges. Run from a folder that
holds several mapped repos, it reads each one's `09-interfaces.md`
and, for every consumes row with no `from`, the code at the row's
`site` and the config that feeds it, then writes the name of the repo
that answers. It asks nothing.

| Argument | Behavior |
| --- | --- |
| *(none)* | The current folder: every immediate subfolder that is a git work tree. A single repo with `workspaces` configured is read as its workspaces. |
| `<folder>` | That folder instead. |

**What decides a row**: the address the code calls, followed through
env vars and deploy config across the clones and matched against each
repo's name and `known_as`; failing an address, the only repo in the
folder that produces the contract. Exactly one candidate is written;
several or none leave the cell empty and the row in the report. A
clone that was never mapped counts as a candidate when its files name
the contract, so an unseen producer keeps the row open.

**What it never does**: write a producer's `to` (quarry builds a
producer's edges from the consumers that name it, and a written `to`
would hide every consumer the folder does not hold), write `unknown`,
change a `from` that is already there, touch a stamp, run `map` in an
unmapped clone, or commit. A filled `from` the evidence disagrees
with is reported.

**The report** lists the rows written with their evidence, the rows
left open and why, the answered rows that disagree, calls no row
covers (`run map interfaces there`), the clones skipped, and the
files changed.

**Ledger key** `edges/09-interfaces.md@<rev>` in each repo written,
where `<rev>` is the moment the run began, so a later run that fills
more rows records itself under a key of its own.

### `doctor`

[Page: when to reach for it, and how to tell it worked](commands/doctor.md)

Diagnoses and repairs the docs area's own consistency. Read-only
first, then offers repairs; every repair is a rule some protocol
already defines.

| Argument | Behavior |
| --- | --- |
| *(none)* | Report findings, ask before applying anything. |
| `fix` | Applies first the repairs that only restore a state a crash rule defines (catch-up ledger entry, stale approval keys removed, torn wrap's delete finished, initializer run, fragments folded); anything else still asks. |

**Checks**: torn writes (a done marker with no ledger entry, or a
ledger key whose outputs are missing), approval integrity (voided plan
approvals, truncated plans), torn wraps (a feature folder left behind
after its entry landed while deletion is enabled), index ↔ disk drift,
housekeeping (a missing `.gitignore` or a stale rule in it, an
untracked ledger), absorption drift, logic coverage, ledger size, schema
(`map-check.sh`'s part 8: missing frontmatter keys, `known_as`
included, or required headings, a Produces or Consumes row on
`09-interfaces.md` with no `### <Name>` payload section, untracked
`Site` paths, secret-shaped strings), and unfolded
`changelog.d/` fragments.

**Ledger key** `doctor/<scope>@<stamp>` - only when something was
actually repaired.

### `review`

[Page: when to reach for it, and how to tell it worked](commands/review.md)

The one command allowed opinions, and only when you ask for them.

| Argument | Behavior |
| --- | --- |
| *(none)* | Both sides, backend first. |
| `backend`, `be` | Architecture and backend judgment only. |
| `frontend`, `fe` | UI judged against the project's own design docs. |

**Writes** `docs/capstone/review.md` - one file, one section per side,
each with its own stamp. A one-sided run rewrites only its own
section. **Gitignored by default:** it is judgment, not reference.
Screenshots from a live-browser run go to `docs/capstone/review/`,
gitignored too.

**Ledger key** `review/<side>@<stamp>`, `<stamp>` being the commit
in the side's stamp line.

### `review retro`

[Page: when to reach for it, and how to tell it worked](commands/review.md#review-retro)

`review`'s third judgment axis, and the only one that is **not a
side**: it reads a finished session rather than the code, writes
`standards.md` rather than `review.md`, and touches neither side's
stamp. It sits under `review` because a session ends under every
command - a project that was mapped rather than designed never runs
the pipeline, and retro is exactly as useful there. Nothing runs it on
your behalf; `start`, `feature` and `implement` name it when they
finish.

Reads a finished session for evidence, then proposes edits to the
files the agent works from. `review` judges the code; `retro` judges
the instructions, the checks and the docs the agent had while writing
it.

| Argument | Behavior |
| --- | --- |
| *(none)* | Read the session in progress. |
| `<session>` | Read the session the harness resolves that name to. A harness that cannot open a past session says so and runs on the current one. |

**Reads** the index, `standards.md`, `03-conventions.md`, the project's
`AGENTS.md` and `CLAUDE.md` where either exists, the ledger, and the
session.

**Candidates**, seven of them, each needing evidence from the session:
navigation (a fact the reference held and the run reached late),
automated checks (a defect a lint, type rule or test could have caught
instead of a human), standards rules (a rule to add, remove or
sharpen, named to its `standards-inventory.md` domain), steering-file
bloat (a line in `AGENTS.md` that belongs in `standards.md` or in a
check), tool economy (repeated or expensive calls a recorded command
would replace), no-ops (a steering rule that changed no behavior),
and information access (what the agent needed and could not reach). A
candidate with no evidence behind it is reported clear, never filled
in.

**Writes** one findings table - candidate, category, evidence,
proposed edit, owning file - ordered by severity, answered row by row
in one reply; an amended row is shown again and written only once
approved as shown. Approved rules land in
`docs/capstone/standards.md` under the domain that owns them; retro
never creates that file, and without it names
`/capstone:start standards` instead. A fix to a generated chapter is
named as the `/capstone:map <topic>` run that regenerates it.
Everything else comes back as text to place by hand:
`AGENTS.md`, linter configs, workflows and test files sit outside the
docs area, and no capstone command writes there.

Where a rule could live on either side, the protocol places it with
the reviewer rather than the implementer, and says so: the
implementing agent holds the plan, the diff and the standards at once,
while the reviewer starts fresh on a diff.

**Ledger key** `retro/all@<stamp>` - whenever the table proposed
anything, approved or not; it lists the declined rows, which the next
retro does not raise again without new evidence. A run whose
candidates all came back clear writes nothing.

---

## The greenfield pipeline

### `start`

[Page: when to reach for it, and how to tell it worked](commands/start.md)

Runs the seven stages in order, detecting what is finished and
resuming at the first incomplete one, then reconciles every final
stage output before `build`. Also what a bare `capstone`
triggers. On a repo that already has code it asks once whether you
want the pipeline or `map`, and records the answer.

Every new or resumed `start` run first asks **inline or subagents**
and waits for an explicit answer, with no default. Inline avoids
extra agent usage; subagents use fresh contexts and can consume your
allowance faster. The answer governs every stage, research, readback,
build, review and reference refresh; handoffs keep it, later runs ask
again.

```text
mockup → logic → uiux → architecture → standards → stack → build
```

Each stage below is reachable on its own as `start <stage>`, which
runs exactly what the pipeline would have run there and then stops.
Every one is a resumable interview: answers are written to disk before the next question, so a
dead session preserves recorded design answers. The execution choice
is asked again when starting a new run to resume the pipeline.

| Stage | Produces | State file |
| --- | --- | --- |
| `mockup` | `mockup/` - one file per screen: wireframe, elements, and a state inventory; `README.md` indexes the screens, the journeys, and the scenario list `logic` works from | `mockup-interview.md` |
| `logic` | `logic/` - one file per scenario: triggers, exact rules, branches, unhappy paths, invariants, and the dimensions ruled out | `logic-interview.md` |
| `uiux` | `uiux/01-direction.md`, `02-system.md` (tokens, the `## Assets` manifest), `03-experience.md`, `screens/`, approved brand SVGs in `uiux/assets/`, review artifacts in `uiux/assets/references/`, and `preview.html` | `uiux-interview.md` |
| `architecture` | The numbered chapters, marked `mode: prescriptive` (`09-interfaces.md` too when the design declares cross-repo edges) | `architecture-interview.md` |
| `standards` | `standards.md` | `standards-interview.md` |
| `stack` | `05-dependencies.md` | `stack-interview.md` |
| `build` | `implementation.md`, then source code | `build-interview.md` |

**Stage notes**

- **`mockup`** depicts, it does not decide: when a question's answer
  would be a rule - a threshold, a formula, what happens on failure -
  it names the behavior, logs the question `for: logic`, and moves on,
  rather than inventing a number that outranks nothing and contradicts
  everything later. Its README hands `logic` a scenario list written at
  `logic`'s unit, and every state whose rule is unsettled is marked
  `rule: logic` rather than filled in. It takes an optional artifact
  argument (a PRD, screenshots) and pre-fills whatever it answers. A project with no visual UI
  records its surfaces (api, cli) and `uiux` skips itself.
- **`logic`** sweeps every scenario against `logic-craft.md`'s sixteen
  rule dimensions - authority, money, concurrency, time, failure,
  what is deliberately hidden, what is deliberately silent, and the
  rest - and a scenario is finished when each one is answered, cited
  to an earlier scenario, or recorded inapplicable with its reason.
  The dimensions generate the questions rather than being asked as
  questions: what does not apply is confirmed in one batch, not
  sixteen turns. Without the sweep, a rule nobody thought to ask about
  reads exactly like a rule that does not exist. It requires a
  formalized `mockup`. Ledger keys `logic/<NN>-<scenario>@Q<n>`, one
  per scenario, and `logic/all@Q<n>` once every scenario is written or
  dropped; that wrap also replaces each `rule: logic` marker it
  settled in the mockup's screen files with the rule and a pointer.
- **`uiux`** requires a formalized `mockup`. It sweeps the product
  against `uiux-inventory.md`'s twenty-seven system items and every
  screen against its eleven screen items, and finishes when each one
  is answered, cited to an earlier answer, or recorded inapplicable in
  the owning file's `## Not in play` section - the same completion test
  `logic` gets from its dimensions. Before the gate it writes
  `uiux/preview.html`, one self-contained page rendering the committed
  tokens as a style tile, and asks the user to review the logo (the
  supplied SVG, or a first-pass one when the asset question asked for
  it) and a pure HTML page mockup from
  `uiux/assets/references/` before continuing to `architecture`. Claude
  Code uses artifacts, GPT uses Sites, and other harnesses use the local
  HTML file. Requested changes are recorded and regenerated until the
  user explicitly approves. The accepted brand files go in
  `uiux/assets/` and are listed row by row in `02-system.md`'s
  `## Assets` table, with the SVGs committed and the review/raster
  exports ignored. With no mockup but existing frontend code it runs
  in **extraction mode** instead: it documents the design that exists
  rather than interviewing for one. Where `map` already extracted
  `uiux/` drafts, it confirms them through the interview instead of
  extracting again.
- **`standards`** sweeps the seventeen domains in
  `standards-inventory.md`: the nine it always walked plus security,
  logging and privacy, API conventions, accessibility, performance
  budgets, documentation, versioning and release, and CI gates. Each
  domain holds items carrying the probe that turns them into a question
  and the `code-craft.md` rule they default to, so most are settled by
  an earlier answer or by the craft file and never asked. It finishes
  when every item is answered, cited to `code-craft.md` as accepted
  unchanged, or recorded in `standards.md`'s closing `## Not in play`
  with its reason or as awaiting a questionnaire answer.
- **`stack`** derives the capability list from your own documents
  rather than from a stock list: every External services row, every
  Communication channel, every store and queue in the data-flow
  chapter, every process and environment variable in the operations
  chapter, every logic scenario reaching outside the process, and the
  `uiux/02-system.md` commitments. Each row is shown with the source
  that produced it, and you add or strike. Every capability then
  reaches you as two to four researched options with licenses and
  pricing, plus one more in every list: write it ourselves, priced in
  code and in what the project then maintains. The `code-craft.md`
  ladder recommends and names its rung; you pick. `stack refresh`
  re-vets recorded picks later. Ledger keys `stack/all@Q<n>` and
  `stack/refresh@<stamp>`.
- **Between `stack` and `build`** the pipeline reads all six stages'
  final outputs in three halves. First it **names what nobody asked**:
  every item of a stage's own inventory - `logic`'s dimensions, the
  uiux and standards inventories, the architecture question list,
  `stack`'s derived capability list - that no final output decides or
  rules out, as one numbered digest you answer, skip, or strike, and
  as one line saying so when nothing is uncovered. Then it **re-files
  what landed in the wrong stage** against core.md's Stage ownership
  table - a business rule in an architecture chapter belongs in
  `logic`, while a library in `standards.md` belongs in
  `05-dependencies.md` - as one digest you
  confirm, since nothing is being re-decided. Last it **raises what one
  final output says that contradicts another**. Same terms as any
  interview's pushback: evidence and final-file citations, two rounds
  at most, then your answer stands. The affected final outputs, index,
  stamps, and changelog entries are updated directly. Completed
  interview bodies are not read or amended. Ledger key
  `readback/all@<stamp>`; unchanged outputs produce the same stable
  stamp and skip.
- **`build`** follows a formalized `stack` with a complete capability
  matrix and a readback of the current outputs: `start build` entered
  directly runs `stack` first when it is not formalized, and the
  readback first when no `readback/all@<stamp>` matches. It writes an
  implementation plan, **stops for your approval**, then writes code -
  in the execution mode chosen for this run. `start build` entered directly
  asks inline or subagents before research or prerequisites, including
  resumes; entry through the pipeline inherits its answer. Each
  build-order step is a checkbox checked when its verification passes.
  Ledger keys `build/plan@<stamp>` and `build/code@<stamp>`, the latter
  once every step is checked: that is when `build` is done, and the
  walking skeleton running is a milestone.

`build` and `implement` are the **only two commands allowed to write
source code**, and only after their plan gates.

---

## The feature chain

### `feature <description>`

[Page: when to reach for it, and how to tell it worked](commands/feature.md)

Takes one feature from idea to shipped code, chaining the three
stages and resuming at the first unfinished one. Accepts a
description for a new feature or a slug for an existing one; with no
argument it lists features in flight and asks.

Every new or resumed `feature` run first asks **inline or subagents**
and waits for an explicit answer, with no default. Inline avoids extra
agent usage throughout grooming, prerequisite mapping, planning,
implementation, review and refresh. Subagents use fresh contexts and
can consume your allowance faster. Stages inherit the current run's
answer; a saved choice does not authorize a later run.

```text
groom → plan → implement
```

| Stage | Produces | Gate |
| --- | --- | --- |
| [`groom <feature>`](commands/groom.md) | `features/<date>-<slug>/spec.md` | Spec approval |
| [`plan <feature>`](commands/plan.md) | `features/<date>-<slug>/plan.md` | **Plan approval, before any code** |
| [`implement <feature>`](commands/implement.md) | Source code, then reference updates | - |

**`groom`** requires an index; without one it builds the
reference first rather than refusing. It interviews a spec out of you
*against* the existing docs, so every requirement traces to a
recorded decision.

**`plan`** turns the spec into task-by-task TDD steps an engineer with
zero context could execute. Approval is recorded with a checksum of
the spec; editing the spec afterwards voids it.

**`implement`** inherits the current `feature` run's execution choice;
a standalone invocation asks again before prerequisite work or
execution, including review-only and wrap-only resumes. It executes
tasks in dependency order, one commit each,
then **reviews the diff recursively until two consecutive rounds find
nothing new**. It then refreshes the affected chapters, absorbs the
spec into `logic/`, `mockup/` and `uiux/`, writes its ledger entry,
and, by default, retains the feature folder as ignored local history.
Set `delete_feature_folders: true` to delete it once the ledger entry
is committed and the branch is finished.

> The whole `features/` tree is gitignored working state. Once
> `implement` finishes, its `implement/<id>` ledger key is the durable
> shipped-feature marker. The ledger is always committed; it remains
> the only surviving record when feature-folder deletion is enabled.

**Ledger key** `implement/<date>-<slug>@Q<n>`. That key is also the
done marker: the id is retired and never reused. Ids are derived from
the groom date and slug, never allocated from a counter, so two
parallel feature branches can't mint the same one.

---

## `help`

[Page: when to reach for it, and how to tell it worked](commands/help.md)

Prints the usage block. In the Claude Code terminal CLI a hook answers
it before the model is invoked, so it costs zero tokens; elsewhere the
model runs the same script.

## `core`

Not a command. It carries the shared rules and scripts every other
skill reads. Install the whole suite - a capstone skill without
`core` cannot run.

---

## What lands where

```text
docs/capstone/
├── 00-index.md            what exists and where (no stamps)
├── 01-architecture.md     layers, boundaries, entry points
├── 02-models.md           entities, relationships, schema, validation
├── 03-conventions.md      paradigm, typing, error handling, DI
├── 04-data-flow.md        lifecycles, state ownership, failure paths
├── 05-dependencies.md     every package, why, where it's wired
├── 06-testing.md          layout, doubles, coverage shape
├── 07-operations.md       run it, env vars, infra, deploy
├── 08-glossary.md         the domain words your codebase invented
├── 09-interfaces.md       cross-repo produces/consumes tables
├── logic/                 business logic, one file per scenario
├── mockup/                one file per screen
├── uiux/                  direction, design system, per-screen chapters
│   ├── assets/            accepted brand SVGs - committed; working files ignored
│   │   └── references/    logo.svg + page-mockup.html for review (gitignored)
│   └── preview.html       the rendered style tile           (gitignored)
├── changelog.md           the folded ledger - always committed
├── changelog.d/           one fragment per new entry, folded on main - committed
├── questionnaires/        one file per recipient, for what the user cannot answer - committed
├── standards.md           how code should be written here
├── implementation.md      build's plan
├── review.md              opinionated findings          (gitignored)
├── review/                screenshots a frontend review took (gitignored)
├── *-interview.md         interview transcripts         (gitignored)
├── features/              specs, plans, review ledgers   (gitignored)
└── capstone.json          the project's settings and state - committed
```

`docs_dir` relocates all of it; `capstone.json`'s own path never
moves, so a custom location stays discoverable.

## Shared mechanics

**Config.** `capstone.json` in the host's global config directory,
created on first session by a hook or initializer. `expertise` (1–5) calibrates the conversation only, never the
docs. `teaching_mode` narrates what is happening and why.
`delete_feature_folders` defaults to `false`, retaining completed
feature folders as ignored local history; set it to `true` to delete
them after implement's wrap.
When the harness provides a structured question tool, Capstone uses it
for questions with a known set of answers, so options are clickable
and `Other` accepts typed text; otherwise it asks the same question in
normal conversation. An open-ended question, and anything you have to
read before answering - a gate's summary, a digest, a comparison of
options - is never put behind a dialog: it is written in the chat with
the question as its last line, and the run waits for your reply. A
dialog left unanswered records nothing.
`batch_questions` (`auto` by default) lets the `architecture`,
`standards`, `uiux` and `logic` interviews send a section's
independent questions in one dialog where the tool takes several;
`off` keeps one question per turn.
`docs_in_git` governs whether the reference is committed. The ledger
(`changelog.md` and `changelog.d/`), `capstone.json` and
`questionnaires/` ignore it and are always committed: the ledger
because it is the durable shipped-feature record, the config because a
setting on one machine is not a project standard, and the
questionnaires because each one is a record of what was asked of a
real person.
`subagent_threshold` (default 150 source files) is where `map` fans
out to subagents, and where an unrequested full build asks first.
`non_interactive` resolves every prompt to its default for headless
CI runs (approval gates still stop). `extract` picks which of `map`'s
extraction passes run (`["logic"]` skips the expensive uiux pass;
`[]` skips both). `interfaces` and `interfaces_frontmatter` control
the `09-interfaces.md` chapter; `cross_repo` controls whether
`groom`, `plan`, the `architecture` interview, and `map`'s interfaces
pass consult the `quarry` CLI for cross-repo contracts (`auto` uses
it only when the CLI is on PATH, and for `groom`/`plan` the docs area
in play also has a `09-interfaces.md`). `redact` lists env-var name
patterns whose values never reach the docs; `07-operations.md` writes
`<redacted>` for them. `workspaces` (project-scoped)
names each monorepo workspace; the name doubles as its quarry target.
`docs/capstone/capstone.json` is the project's own
shared config, committed like the ledger whatever `docs_in_git` says,
holding `pipeline`, `workspaces`, and any global key this repo
overrides; `expertise` and `teaching_mode` are personal, live in the
global file, and are ignored if found here.

**Cross-repo contracts.** With `cross_repo: "auto"` and quarry
installed, `groom` runs `quarry docs deps <repo> --downstream --json`
and reads each consumer's contract section before its first question.
In a monorepo with `workspaces` configured, `<repo>` is the
workspace name - the same name `quarry init --name` registers as a
target, chosen by which workspace's `path` contains the files the
feature touches (one call per workspace when several). `plan` writes
the constraint into every task that crosses a repo boundary.
The `architecture` interview looks up any existing system
a greenfield design will talk to (`quarry docs search`, then the
contract section) and writes the planned edges into a prescriptive
`09-interfaces.md`, so the feature chain can consult quarry from day
one. Going the other way, `quarry check` runs in the producer's CI:
it reads the working tree's `09-interfaces.md`, pairs each Produces
payload section with the matching Consumes section in every consumer
the quarry knows, and exits 1 when a field a consumer reads is gone
or changed type. `quarry update` runs the same comparison as advisory
notes. Both read the `### <Name>` sections `map` writes, which is why
the chapter, and not `01-architecture.md`'s Communication section,
holds the fields for a cross-repo channel - as a table, or as
`Model: <Entity>` naming a `### <Entity>` section in this repo's
`02-models.md`. `map` runs `quarry docs index --json` and
`quarry docs list --json` while writing `09-interfaces.md`, to find
the edges the registry's join could not settle and to check that this
repo is registered at all. Without
quarry, everything behaves exactly as before: the rows are written
with no `to` and no `from`, and the join happens whenever the repo
reaches a quarry.

**Interview lifecycle.** `interviewing` → `awaiting-formalization` →
`formalized`. The final state is written only *after* outputs are on
disk, so a crash can never strand a "done" marker over missing files.
After formalization, those outputs are the source of truth. Interviews
remain local resume and repair state; final files never cite them.

**The ledger.** Every run that writes records itself as one file in
`changelog.d/` before setting its done marker; the next writing run
on main folds the fragments into `changelog.md`, newest first,
bullets only, and deletes them. Distinct filenames mean two
doc-carrying PRs never conflict in the ledger. Rotation past 200
entries moves the oldest into `changelog-<YYYY>.md`, keys and bodies
together; a key is never dropped.

**Staleness.** Each generated file records the commit it was derived
at, a content hash of the tree under its globs, and the globs it
covers. A refresh diffs those globs against the
working tree - uncommitted changes count - and rewrites only what
moved; when a squash or rebase merge makes the commit unreachable,
the content hash keeps the check per-file instead of forcing a full
rebuild. `capstone_version` records which capstone wrote a file, so a
later release can migrate by version rather than guessing from shape.

**Descriptive, always.** Docs state facts with `file:line` pointers,
never recommendations. `review` is the sole opinionated output, and
only on request.

**TDD + YAGNI runs through everything.** `code-craft.md`'s ladder -
does this need to exist at all, is it already here, does the stdlib
or platform cover it, can it be one line - is climbed by every stage
that decides what will exist, not only the ones that write code.
`architecture` climbs it before agreeing a layer, `stack` before
researching a single vendor, `plan`/`build`/`implement` before writing
a line, and `review` judges against it. Your `standards.md` outranks
it, but only by a decision that names what it overrides; a silent
conflict resolves to the ladder.

**Interviews push back.** An answer that contradicts a recorded
decision, a craft rule, an earlier answer, or a number you already
gave gets challenged - with the specific consequence and an
alternative, at most twice, and only a second time if there is a new
argument. Then it is your call: your answer stands, and the interview
records both the decision and the objection so a later reader can tell
a considered trade-off from an oversight.

## CI

Two templates. `templates/capstone-map-check.yml` is the per-PR gate:
it clones capstone at the pinned release tag and runs
`skills/core/scripts/map-check.sh docs/capstone`, no API key, failing
on the `MAP CHECK:` verdict line. Unfolded `changelog.d/` fragments
are reported but never fail it, so a PR carrying its own ledger entry
still passes. The script's schema pass also fails the gate on a
secret-shaped string in any generated file.
`templates/capstone-map-review.yml` is the model half: nightly and on
`workflow_dispatch`, with an `ANTHROPIC_API_KEY` secret, failing on
the `MAP REVIEW:` line and ignoring the script's. It writes a config
with `non_interactive: true` so the headless run resolves every
prompt to its default.

A repo registered in a quarry adds `quarry init` and `quarry check`
to the same pull-request workflow; that gate reads the payload
sections, needs no API key, and is documented in quarry's README.
