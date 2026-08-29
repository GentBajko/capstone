# Shared Rules (read by every subcommand)

How a capstone run behaves: the config that calibrates it, the rules
that bind every protocol, and the order everything is read in. The
companion file `core-authoring.md` carries the rules for *producing*
an output (seeding, delegating, indexing, ignoring); every subcommand
except the two chain runners reads that one too.

## User config: global `capstone.json`, per-project overrides

The config belongs to the user, not the repo. `capstone.json` lives in
the agent's global config folder: `~/.claude` for Claude Code (or
`$CLAUDE_CONFIG_DIR` when set), the agent's own equivalent
(`~/.codex`, `~/.gemini`, ...) elsewhere. It is created at
installation, not per project: the plugin's SessionStart hook runs the
idempotent initializer from the `core` skill's `scripts/` directory
(`init-config.sh --global` via bash) on the first session after
install. When the file is missing anyway (an agent without hook
support), run that initializer yourself, `init-config.sh --global`
via bash (macOS/Linux/Git Bash) or `init-config.ps1 -Global` via
powershell (Windows); if neither shell is available, write this
template yourself:

```json
{
  "expertise": null,
  "teaching_mode": false,
  "docs_dir": "docs/capstone",
  "index_file": "docs/capstone/00-index.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en"
}
```

Read it first; absent keys use the defaults above.

**Per-project state and overrides: `docs/capstone/capstone.json`,
optional.** Never created as a matter of course; it exists only when
something project-scoped must be recorded. Any global key set there
overrides the global file for this repo. Two keys are project state
that never goes global, `pipeline` and `workspaces`; a protocol
recording one creates the file holding just that key. The project
file's path is fixed no matter what `docs_dir` is set to: `docs_dir`
relocates generated outputs only, never the config, so a custom
`docs_dir` can always be discovered. `docs_dir` and `index_file` must
be relative paths inside the repository; refuse anything else.
Neither config file is ever indexed (settings, not docs).

`"expertise": null` means "not yet asked": behave as level 3 until the
ask-once rule below fills it. `pipeline` absent (or `null`) means the
generate-vs-pipeline fork (see `protocols/start.md`) has not been
asked; `true`/`false` records the user's answer so it is never
re-asked. `workspaces` (absent/`null`, or a list of `{"name", "path"}`):
absent means a single-rooted project. When set, each workspace carries
its own docs area at `<path>/docs/capstone/` (config keys inherit from
the root project file, then the global file), the root `<index_file>`
becomes an index-of-indexes (a workspace table linking each
workspace's index), `generate` and `sync` iterate the workspaces (an
argument targets one), and other
commands operate on the workspace whose paths the request touches,
asking when ambiguous.

`docs_in_git` (`"commit" | "ignore" | "ask"`) pre-answers the
commit-or-gitignore question **for the factual reference only**: the
index and the topic chapters, plus `logic/`, `mockup/`, `design/`,
`code-prefs.md`, and `changelog.md`.
`language` sets the generated docs' language. The user can change any
key by editing the files or just telling you.

## `expertise` (1-5): calibrates every conversation, never the docs

**It calibrates the conversation with the user only.** The generated
docs serve AI sessions and stay dense per style.md at every level:

1. **vibe**: plain language only; explain any unavoidable term in one
   clause; interviews ask about goals and experience, then derive the
   technical decision yourself and confirm it in plain words ("I'll
   use a managed database so you never run servers. OK?"); strong
   recommended defaults; never ask for numbers the user can't know:
   translate ("roughly how many people at once?") and derive the
   technical targets yourself, recording them as derived decisions.
   This overrides the interview conduct rules' quantification demands:
   the numbers still get recorded, but you compute them.
2. **explorer**: as 1, but introduce the proper term alongside each
   plain explanation and add short why-it-matters notes; teach while
   asking.
3. **builder** (default): normal technical vocabulary; recommended
   option first with one-line trade-offs.
4. **engineer**: terse; jargon unexplained; ask for numbers directly
   (percentiles, RTO/RPO); rationale only on request.
5. **architect**: maximally terse; lead with trade-off matrices;
   challenge weak or inconsistent answers; the user drives, you
   record.

## `teaching_mode` (boolean, default `false`)

**Turns on teach-while-working narration at any expertise level.**
When `true`,
while working (any stage, not just interviews) narrate each meaningful
step in one or two sentences: what is being done and why it matters to
the product, naming the proper term for what just happened and the one
transferable idea behind it ("this file is a 'migration': a script
that changes the database's shape without losing its data"). One
concept per step; the user is here to learn the craft, never to sit
through a lecture. When a stage finishes, say what now exists and what
comes next. Vocabulary follows `expertise`: level 1 hears the plain
words first with the term in passing, level 4 just the term. Narration
is conversation only; the generated docs stay dense per style.md. When
`false`, no teaching narration: report per your level and move on.

If `expertise` is null or missing and the task is interactive (any
interview, `review`), ask ONE
question ("How technical should I be with you?" with the five levels),
write the answer into the global config file (creating it with all
keys if needed), and never ask again. Non-interactive runs behave as
level 3 without asking and leave `expertise` null.

## Hard rules

1. **Describe, never judge**: facts with `file:line` pointers; no
   recommendations, grades, or comparisons. Sole exceptions:
   `review`, and only because the user explicitly invoked it.
2. **Write only the configured docs area**: `<docs_dir>/*` plus the
   index `<index_file>` (default `docs/capstone/00-index.md`, inside
   the docs area)
   and the two config files (global and per-project). Never touch
   source code, `openspec/`, or human-authored docs. Sole exceptions:
   the `build` protocol (invoked directly or as `start`'s final stage)
   and the `implement` protocol (invoked directly or as
   `implementation`'s final stage) write source code and their
   implementation-plan artifacts, which is their purpose, and only
   after their plan gates. The `design` protocol may invoke the
   installed `impeccable` / `design-taste-frontend` skills; their own
   working artifacts (`PRODUCT.md`, `.impeccable/`, surface briefs)
   are those skills' to write per their own rules: outside the docs
   area, never indexed or maintained by this plugin.
3. **Docs are skill-owned**: re-runs may rewrite any generated
   section; manual edits are not preserved. Sole exception:
   `changelog.md` is append-only; re-runs add entries and never
   rewrite, reorder, or drop them.
4. Follow `style.md` (same directory) for every sentence you write,
   and `core-authoring.md` for landing it: what is never committed,
   what gets indexed, and how a stage seeds and delegates.
5. **Record what you did**: every run that writes or changes a durable
   output appends its entry to `<docs_dir>/changelog.md` before
   setting its done marker (Changelog ledger, below).

## Progress tasks: every run shows where it stands

At the start of every run, create a visible task list with the
harness's todo/task tool: one task per phase or numbered step of the
protocol being executed; the chain runners (`start`,
`implementation`) hold one task per stage. Mark a task in progress
when it starts and completed the moment its outputs are on disk,
never in batches at the end: the list is how the user follows where
everything stands. Work discovered mid-run (a repair, a missing
scenario, a review finding to fix) is added as its own task, never
held in memory. On a harness without a todo tool, print the checklist
and re-print it with updated statuses at each transition. Interviews
track questions in the interview file as always; their task list
tracks phases (study, interview, gate, generation), not individual
questions.

## Read discipline: every run's first act

Every subcommand reads in the same order, before doing anything else:

1. **Own state first.** A protocol with an interview or state file
   reads it before anything else; a protocol whose prior outputs
   exist (`design/`, `logic/`, `spec.md`, `review.md`, ...) reads
   them before regenerating or extending. Never write blind over your
   own docs.
2. **Discovery through the index, never by globbing.**
   `<index_file>`'s tables say what exists and where; open only the
   files this run's purpose needs. Freshness comes from each file's
   own frontmatter, not the index.
3. **Chapters before source; cited files only.** A chapter answers
   where and how; open source only where a chapter is stamped stale,
   labels its coverage shallow, or exact lines must be named.
4. **Refresh-before-trust only where the protocol says so** (groom's
   staleness pass, review's step 1); everywhere else read as-is and
   note the stamps.
5. **Never re-read** what is already in context this session unless
   it changed on disk.
6. **Every protocol carries a `**Reads:**` block** near its top
   naming exactly what it opens unprompted, in read order (own state
   → consumed outputs; the config is always first per this file).
   Anything beyond the block needs an index row or a citation trail
   justifying the read.

Everything a subcommand writes carries the topic-file frontmatter
stamps (`generated_at_commit`, `generated_date`, plus `paths_covered`
where the refresh protocol applies; date-only outside git).

## Missing reference: build it, don't refuse

**A protocol that consumes the reference and finds no `<index_file>`
runs `sync` first, then continues its own work.** `sync` refreshes an
index that exists and falls back to `generate` when none does, so the
one rule covers both the never-generated repo and the abandoned one.
Announce it in one line ("no reference yet; building it first"), run
it, then resume the protocol that was invoked. This replaces refusing
with a pointer at `generate` or `start`: a user who asked for a
feature spec wants the spec, not an errand.

Four bounds on it:

- **Once per run.** If `sync` produces no index either (`generate`'s
  empty-repo stop: no source files, no entry points, no manifests),
  say so and stop. Never loop.
- **The greenfield stages are exempt** (`mockup`, `logic`, `design`,
  `architecture`, `code-prefs`, `stack`, `build`): they build the
  reference from interviews rather than reading one, and their
  prerequisites are upstream *interviews*, not the index. `design`
  without a mockup still points at `mockup`; `build` without a
  formalized stack still runs `stack`.
- **`generate`, `sync`, and `doctor` are exempt.** The first two are
  what the rule delegates to; `doctor` diagnoses the docs area, so a
  missing index is a finding it reports, never a thing it silently
  builds.
- **Interview prerequisites are untouched.** This rule fires only on
  a missing index, never to skip a gate or invent a decision the user
  has not made.

## Changelog ledger: `<docs_dir>/changelog.md`

**Every run that writes or changes a durable output records itself
there: one entry per done marker, appended before that marker is
set.** The entry is an output like any other; the run is not finished
until it is on disk. Protocols that only read (`help`, `sync`'s check
mode) or only route (`start`, `implementation`) write no entry; a
refresh one of them delegates is recorded by the protocol that
performs it.

Create the file on first write (any stage may be its first writer)
with frontmatter stamps only (no `paths_covered`, so no refresh path
regenerates it), and add its Companion docs row. **Insert directly
below the frontmatter, never at end of file**: entries are
newest-first, so the newest is always the one directly under the
frontmatter. An entry is

    ## <date> - <stage>: <target>
    key: <stage>/<target>@<rev>

followed by one bullet per output path, naming what changed about it,
the decisions and rejected options recorded, and what was left open,
deferred, dropped, or ruled out of scope: the facts a later rewrite of
that output would erase. Never restate what the output already says;
point at it. `<target>` is the thing acted on (`03-invite-links`,
`02-models.md`; `all` for a run covering the whole
project). `<rev>` is the highest interview question number the output
traces to (`Q7`) for a stage with an interview file, otherwise the
run's stamp.

Before appending, search the file for the key: if it is already there,
this is a resumed run and the entry stands; never append a second. A
done marker found with no matching key is a torn write: append the
missing entry from the recorded decisions, never re-run the stage.
Writes to `*-interview.md`, `features/*/review-ledger.md` and
`capstone.json` are not reported. A run that produced little still
records: a dropped scenario, a topic recorded absent, a capability
left open are the entry's content, never a reason to skip it.
`docs_in_git` and the absence of git change how an entry is stamped,
never whether it is written.

**Merges:** every entry inserts at the same offset, directly below the
frontmatter, so branches conflict there routinely. Keep both sides and
re-sort the conflicted block by date, newest first: resolving by
picking a side drops a recorded event.

## Interview lifecycle (shared by all interviews)

An interview file's `status` moves `interviewing` →
`awaiting-formalization` (set when the summary gate is presented) →
`formalized`, and **`formalized` is written only AFTER the stage's
outputs, its changelog entry included, are fully on disk**, never
before generation, so a crash can't strand a formalized stage with
missing outputs. Exception: `logic` has per-scenario gates instead of
one summary gate, so it never uses `awaiting-formalization`; it stays
`interviewing` and keeps a scenario checklist in its frontmatter
(`scenarios: [{name, status: pending|written|dropped}]`), moving
straight to `formalized` once every listed scenario is `written` or
`dropped` and the index row exists. The pipeline runner
(`protocols/start.md`) keys stage completion on these rules.

## Voice per output

`sync check` is facts only, as are the changelog entries every
stage appends, `review`'s among them.
`review` is the sole opinionated output. `code-prefs`, `logic`,
`design`, `stack`, and `groom`'s `spec.md` are normative but only
record the user's own stated decisions (`logic` and `design` in
extraction mode are descriptive like the chapters: observed fact, hard
rule 1 in full); `build`'s `implementation.md` and `plan`'s `plan.md`
are instructional: they may use imperative voice, but every command
must be verified and every step cites its files; style.md's density
and naming rules still bind.

