# Capstone command reference

Every command, its arguments, what it reads, what it writes, and what
must exist first. For installation and updating see the
[README](../README.md); for contributing see
[CONTRIBUTING](../CONTRIBUTING.md).

**Jump to:**

1. [Invocation](#invocation)
2. [Three entry points](#three-entry-points)
3. [Reference commands](#reference-commands) — [`map`](#map) · [`doctor`](#doctor) · [`review`](#review)
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
`review backend`, `stack refresh`, `groom add CSV export`.

## Three entry points

Diagrammed end to end in [flows.md](flows.md): what each one does, in
what order, where it stops for you, and what it leaves on disk.


Everything else is a stage one of these runs, individually invocable
when you want to enter mid-chain.

| Situation | Command |
| --- | --- |
| A repo that already has code | `map` |
| A product that doesn't exist yet | `start` |
| One change to a mapped project | `feature <description>` |

---

## Reference commands

### `map`

Builds the factual reference, and keeps it true. **One verb because
the branch is readable off disk:** no index means build, an index
means refresh only what drifted.

| Argument | Behavior |
| --- | --- |
| *(none)* | No stamped index → full build. Stamped index → refresh what drifted. |
| `check` | Read-only trust report. Writes nothing, not even a ledger entry. |
| `rebuild` | Force a full rewrite of a reference that looks current. |
| `<topic>` | Rebuild one chapter: `architecture`, `models`, `conventions`, `data-flow`, `dependencies`, `testing`, `operations`, `glossary`, `interfaces`. |

**Writes** `docs/capstone/00-index.md`, the numbered chapters
(`09-interfaces.md`, the cross-repo produces/consumes tables, appears
when the repo talks to another repo; the `interfaces` config key can
turn it off), `logic/` (business-logic scenarios) and `uiux/`
(surface chapters); the `extract` config key can skip either
extraction pass.
Every file carries `generated_at_commit`, `generated_date`,
`capstone_version`, `content_hash` and `paths_covered` in
frontmatter; those globs are what a later refresh diffs against, and
the content hash is the stamp that survives squash and rebase merges,
so an unreachable commit degrades to a per-file check instead of a
full rebuild.

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
keys, required headings per chapter, `Site` paths checked with
`git ls-files --error-unmatch` and required to name one tracked file,
so a directory or a wildcard is a finding, and secret-shaped strings
reported by pattern name), then ends with a machine-parseable verdict:

```text
MAP CHECK: current
MAP CHECK: stale (<N> findings)
```

Exit 0 on current, 1 on stale, 2 on a usage error. `--headings` prints
the required-headings list the script embeds (`lint-sync.sh` keeps it
equal to `topics.md`); `--patterns` prints the secret patterns by name:
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

### `doctor`

Diagnoses and repairs the docs area's own consistency. Read-only
first, then offers repairs; every repair is a rule some protocol
already defines.

| Argument | Behavior |
| --- | --- |
| *(none)* | Report findings, ask before applying anything. |
| `fix` | Pre-approves the documented crash rules; anything else still asks. |

**Checks**: torn writes (a done marker with no ledger entry, or a
ledger key whose outputs are missing), approval integrity (voided plan
approvals, truncated plans), torn wraps (a feature folder left behind
after its entry landed), index ↔ disk drift, lifecycle validity,
housekeeping (missing `.gitignore` or config keys, an untracked
ledger), absorption drift, logic coverage, ledger size, schema
(`map-check.sh`'s part 8: missing frontmatter keys or required
headings, untracked `Site` paths, secret-shaped strings), and unfolded
`changelog.d/` fragments.

**Ledger key** `doctor/<scope>@<stamp>` - only when something was
actually repaired.

### `review`

The one command allowed opinions, and only when you ask for them.

| Argument | Behavior |
| --- | --- |
| *(none)* | Both sides, backend first. |
| `backend`, `be` | Architecture and backend judgment only. |
| `frontend`, `fe` | UI judged against the project's own design docs. |

**Writes** `docs/capstone/review.md` - one file, one section per side,
each with its own stamp. A one-sided run rewrites only its own
section. **Gitignored by default:** it is judgment, not reference.

**Ledger key** `review/<side>@<stamp>`.

---

## The greenfield pipeline

### `start`

Runs the seven stages in order, detecting what is finished and
resuming at the first incomplete one, then reconciles every final
stage output before `build`. Also what a bare `capstone`
triggers. On a repo that already has code it asks once whether you
want the pipeline or `map`, and records the answer.

```text
mockup → logic → uiux → architecture → standards → stack → build
```

Each stage below is individually invocable. Every one is a resumable
interview: answers are written to disk before the next question, so a
dead session loses nothing, and re-running never re-asks.

| Stage | Produces | State file |
| --- | --- | --- |
| `mockup` | `mockup/` - one file per screen: wireframe, elements, and a state inventory; `README.md` indexes the screens, the journeys, and the scenario list `logic` works from | `mockup-interview.md` |
| `logic` | `logic/` - one file per scenario: triggers, exact rules, branches, unhappy paths, invariants, and the dimensions ruled out | `logic-interview.md` |
| `uiux` | `uiux/01-direction.md`, `02-system.md`, `03-experience.md`, `screens/` | `uiux-interview.md` |
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
  reads exactly like a rule that does not exist.
- **`uiux`** requires a formalized `mockup`. On a repo that already has
  a frontend it runs in **extraction mode** instead: it documents the
  design that exists rather than interviewing for one.
- **`stack`** researches real options per capability with licenses and
  pricing; you pick. `stack refresh` re-vets recorded picks later.
  Ledger keys `stack/all@Q<n>` and `stack/refresh@Q<n>`.
- **Between `stack` and `build`** the pipeline reads all six stages'
  final outputs in two halves. First it **re-files what landed in the
  wrong stage** against core.md's Stage ownership table - a business
  rule in an architecture chapter belongs in `logic`, while a library
  in `standards.md` belongs in `05-dependencies.md` - as one digest you
  confirm, since nothing is being re-decided. Then it **raises what one
  final output says that contradicts another**. Same terms as any
  interview's pushback: evidence and final-file citations, two rounds
  at most, then your answer stands. The affected final outputs, index,
  stamps, and changelog entries are updated directly. Completed
  interview bodies are not read or amended. Ledger key
  `readback/all@<stamp>`; unchanged outputs produce the same stable
  stamp and skip.
- **`build`** requires a formalized `stack`. It writes an
  implementation plan, **stops for your approval**, then writes code -
  in subagents (fresh context per step) or inline, asked once before
  the first step. Ledger keys `build/plan@Q<n>` and `build/code@Q<n>`.

`build` and `implement` are the **only two commands allowed to write
source code**, and only after their plan gates.

---

## The feature chain

### `feature <description>`

Takes one feature from idea to shipped code, chaining the three
stages and resuming at the first unfinished one. Accepts a
description for a new feature or a slug for an existing one; with no
argument it lists features in flight and asks.

```text
groom → plan → implement
```

| Stage | Produces | Gate |
| --- | --- | --- |
| `groom <feature>` | `features/<date>-<slug>/spec.md` | Spec approval |
| `plan <feature>` | `features/<date>-<slug>/plan.md` | **Plan approval, before any code** |
| `implement <feature>` | Source code, then reference updates | - |

**`groom`** requires a stamped index; without one it builds the
reference first rather than refusing. It interviews a spec out of you
*against* the existing docs, so every requirement traces to a
recorded decision.

**`plan`** turns the spec into task-by-task TDD steps an engineer with
zero context could execute. Approval is recorded with a checksum of
the spec; editing the spec afterwards voids it.

**`implement`** executes tasks in dependency order, one commit each,
then **reviews the diff recursively until two consecutive rounds find
nothing new**. It then refreshes the affected chapters, absorbs the
spec into `logic/`, `mockup/` and `uiux/`, writes its ledger entry,
and **deletes the feature folder**.

> The whole `features/` tree is gitignored working state. Once
> `implement` finishes, its `changelog.md` entry is the only surviving
> record of why the feature was built that way - which is why the
> ledger is always committed.

**Ledger key** `implement/<date>-<slug>@Q<n>`. That key is also the
done marker: the id is retired and never reused. Ids are derived from
the groom date and slug, never allocated from a counter, so two
parallel feature branches can't mint the same one.

---

## `help`

Prints the usage block. In Claude Code a hook answers it before the
model is invoked, so it costs zero tokens.

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
├── changelog.md           the folded ledger - always committed
├── changelog.d/           one fragment per new entry, folded on main - committed
├── standards.md           how code should be written here
├── implementation.md      build's plan
├── review.md              opinionated findings          (gitignored)
├── *-interview.md         interview transcripts         (gitignored)
├── features/              specs, plans, review ledgers   (gitignored)
└── capstone.json          project-scoped overrides       (gitignored)
```

`docs_dir` relocates all of it; `capstone.json`'s own path never
moves, so a custom location stays discoverable.

## Shared mechanics

**Config.** `~/.claude/capstone.json`, created on first session by a
hook. `expertise` (1–5) calibrates the conversation only, never the
docs. `teaching_mode` narrates what is happening and why.
`docs_in_git` governs whether the reference is committed -
the ledger (`changelog.md` and `changelog.d/`) is the sole exception
and is always committed.
`subagent_threshold` (default 150 source files) is where `map` fans
out to subagents, and where an unrequested full build asks first.
`non_interactive` resolves every prompt to its default for headless
CI runs (approval gates still stop). `extract` picks which of `map`'s
extraction passes run (`["logic"]` skips the expensive uiux pass;
`[]` skips both). `interfaces` and `interfaces_frontmatter` control
the `09-interfaces.md` chapter; `cross_repo` controls whether
`groom`, `plan`, and the `architecture` interview consult the
`quarry` CLI for cross-repo contracts (`auto` uses it only when the
CLI is on PATH, and for `groom`/`plan` the repo also has a
`09-interfaces.md`).

**Cross-repo contracts.** With `cross_repo: "auto"` and quarry
installed, `groom` runs `quarry docs deps <repo> --downstream --json`
and reads each consumer's contract section before its first question,
and `plan` writes the constraint into every task that crosses a repo
boundary. The `architecture` interview looks up any existing system
a greenfield design will talk to (`quarry docs search`, then the
contract section) and writes the planned edges into a prescriptive
`09-interfaces.md`, so the feature chain can consult quarry from day
one. Without quarry, everything behaves exactly as before.

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
still passes. `templates/capstone-map-review.yml` is the model half:
nightly and on `workflow_dispatch`, with an `ANTHROPIC_API_KEY`
secret, failing on the `MAP REVIEW:` line and ignoring the script's.
It writes a config with `non_interactive: true` so the headless run
resolves every prompt to its default.
