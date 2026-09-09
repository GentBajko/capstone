# Shared Rules (read by every subcommand)

How a capstone run behaves: the config that calibrates it, the rules
that bind every protocol, and the order everything is read in. The
companion file `core-authoring.md` carries the rules for *producing*
an output (seeding, delegating, indexing, ignoring); every subcommand
except the two chain runners reads that one too.

## Config: the user's global `capstone.json`, and the project's shared one

Two config files, each with an owner. The global one belongs to the
user: `capstone.json` lives in
the agent's global config folder: `~/.claude` for Claude Code (or
`$CLAUDE_CONFIG_DIR` when set), the agent's own equivalent
(`~/.codex`, `~/.gemini`, ...) elsewhere. It is created at
installation, not per project: the plugin's SessionStart hook runs the
idempotent initializer from the `core` skill's `scripts/` directory
(`init-config.sh --global` via bash) on the first session after
install. When the file is missing anyway (an agent without hook
support), run that initializer yourself: `init-config.sh --global`
via bash, which on Windows means Git Bash. If bash is unavailable,
write this template yourself:

```json
{
  // Comments are allowed in this file; capstone reads around them.
  "expertise": null,                  // null = ask once | 1 vibe | 2 explorer | 3 builder | 4 engineer | 5 architect; conversation only, never the docs
  "teaching_mode": false,             // true = narrate each step and the concept behind it, at any expertise level
  "docs_dir": "docs/capstone",        // where generated docs land; relative path inside the repo
  "index_file": "docs/capstone/00-index.md", // chapter zero of the docs area; relative path inside the repo
  "subagent_threshold": 150,          // source-file count where map fans out to subagents and unrequested full builds ask first
  "docs_in_git": "ask",               // "commit" | "ignore" | "ask" - the factual reference only; the ledger is always committed
  "language": "en",                   // language the generated docs are written in
  "non_interactive": false,           // true = resolve every defaulted prompt silently (CI); approval gates still stop
  "extract": ["logic", "uiux"],       // map's extraction passes: ["logic","uiux"] both | ["logic"] skip uiux | [] skip both
  "interfaces": "auto",               // "auto" = write 09-interfaces.md when the repo talks to another repo | "off" = never
  "interfaces_frontmatter": false,    // true = also mirror the interface tables into frontmatter, for machine consumers
  "cross_repo": "auto",               // "auto" = groom/plan/architecture/map consult quarry when installed (groom/plan also need 09-interfaces.md) | "off" = never
  "redact": ["*_SECRET", "*_TOKEN", "*_PASSWORD", "*_KEY"] // env-var name patterns whose values the docs never quote; * matches any prefix or suffix
}
```

Read it first; absent keys use the defaults above. Both config files
are JSON with `//` line comments permitted (the created template
ships with one per key, so the options are readable in place); read
around them, keep them when editing a key's value, and never call
the file invalid for carrying them.

**Project config, shared and committed: `docs/capstone/capstone.json`,
optional.** The team's configuration for this repo: the settings every
run on it follows (`docs_dir`, `interfaces`, `cross_repo`, `redact`,
`extract`, `language`, or any other global key; a key set here
overrides the global file for this repo) and the project's state. Two
keys are project state that never goes global, `pipeline` and
`workspaces`; a protocol recording one creates the file holding just
that key, and that is the only way the file comes to exist. It is
never created as a matter of course. **It is always committed,
whatever `docs_in_git` says**, like the ledger: a config that lives on
one machine is not a standard. Two keys are personal and never belong
in it, `expertise` and `teaching_mode`: a run ignores them when found
there, `doctor` reports them (its check 5), and the global file keeps
them. The project file's path is fixed no matter what `docs_dir` is
set to: `docs_dir`
relocates generated outputs only, never the config, so a custom
`docs_dir` can always be discovered. `docs_dir` and `index_file` must
be relative paths inside the repository; refuse anything else.
Neither config file is ever indexed (settings, not docs), and neither
is a doc in hard rule 3's sense: a run edits one key in place and
keeps everything else, comments included.

`"expertise": null` means "not yet asked": behave as level 3 until the
ask-once rule below fills it. `pipeline` absent (or `null`) means the
generate-vs-pipeline fork (see `protocols/start.md`) has not been
asked; `true`/`false` records the user's answer so it is never
re-asked. `workspaces` (absent/`null`, or a list of `{"name", "path"}`):
absent means a single-rooted project. When set, each workspace carries
its own docs area at `<path>/docs/capstone/` (config keys inherit from
the root project file, then the global file), the root `<index_file>`
becomes an index-of-indexes (a workspace table linking each
workspace's index), `map` iterates the workspaces (an
argument targets one), and other
commands operate on the workspace whose paths the request touches,
asking when ambiguous.
**The workspace name is the quarry target name**: quarry registers
each workspace with
`quarry init --name <name> --docs-dir <path>/docs/capstone` and
imports it under that folder, so a protocol passing `<repo>` to
quarry passes the workspace name whenever the request's files fall
inside a workspace, and the origin URL's last path segment otherwise
(the single-rooted case, and the root index-of-indexes, which quarry
imports under the origin name). An edge into a monorepo therefore
resolves to the workspace name, never the monorepo's, and a `from`
someone writes by hand names the workspace too.

`docs_in_git` (`"commit" | "ignore" | "ask"`) pre-answers the
commit-or-gitignore question **for the factual reference only**: the
index and the topic chapters, plus `logic/`, `mockup/`, `uiux/`, and
`standards.md`. Two things are exempt and always committed: the
ledger (`changelog.md`, its rotation files, `changelog.d/`), per its
own rule below, and the project config
`docs/capstone/capstone.json`, per the paragraph above.
`language` sets the generated docs' language. The user can change any
key by editing the files or just telling you.

`non_interactive` (boolean, default `false`): when `true`, every
prompt resolves to its recommended default without being asked, so
`claude -p "/capstone:map"` runs headlessly in CI. A question that
carries a default (a confirm, a mode ask, `docs_in_git: "ask"`'s
commit-or-ignore question) takes the default and is noted in the
report. A question with no default - an approval gate (`plan`'s,
`build`'s, a spec gate), the execution choice below, consent to write
main, an interview question - is never answered by inventing consent: the run says what it is
blocked on and stops. It changes how prompts resolve, never what gets
written.

`extract` (list, default `["logic", "uiux"]`): which of `map`'s
extraction passes run. `["logic"]` skips the uiux surface extraction
(the expensive half for a backend service with no frontend to speak
of), `[]` skips both. A pass not listed is skipped everywhere `map`
would run it - build, refresh, and its coverage checks - and
`map check` reports that pass as disabled by config rather than as a
gap. Interview-derived `logic/` and `uiux/` files are untouched by
this key; it gates extraction only.

`interfaces` (`"auto" | "off"`, default `"auto"`): whether `map`
writes the `09-interfaces.md` chapter (see `topics.md`). `auto` means
the chapter's own Applicable test decides: a repo that talks to no
other repo gets no chapter. `off` skips the interfaces pass entirely.
`interfaces_frontmatter` (boolean, default `false`): the chapter's
`edges:` frontmatter block is canonical and always written, and so is
its `known_as` list of the names other systems reach this repo by
(see `topics.md`); this key adds the legacy top-level `produces:` /
`consumes:` lists beside it, for a machine consumer pinned to the 6.2
shape. Leave it off unless something needs it - a second copy of the
same rows is one more thing to drift.

`cross_repo` (`"auto" | "off"`, default `"auto"`): whether `groom`,
`plan`, the `architecture` interview, and `map`'s interfaces pass
consult the `quarry` CLI (their protocols carry the exact calls: deps
and section lookups for the first three, `quarry docs index --json`
for `map`, whose `ambiguous` rows are the edges the registry's join
could not settle). `auto` means: use it only when the CLI is
on PATH **and**, for `groom` and `plan`, the docs area in play has a
`09-interfaces.md` (`architecture` and `map` drop that second
condition - a greenfield repo has no chapter yet, and writing the
chapter is `map`'s job), so a machine without quarry behaves exactly
as before with no configuration. `off` is the kill switch for someone
who has quarry installed but does not want the calls. `auto` with the
CLI on PATH is also the condition under which a run asks the user to
settle an edge the registry could not (Edge confirmation, below).

`redact` (list of env-var name patterns, default
`["*_SECRET", "*_TOKEN", "*_PASSWORD", "*_KEY"]`): variables whose
values never reach the docs. `*` stands for any run of characters at
the start or the end of a name, so `*_KEY` covers `STRIPE_KEY` and
`AWS_*` covers `AWS_SECRET_ACCESS_KEY`; matching is case-insensitive.
A matching variable's Default column in `07-operations.md` reads
`<redacted>`, and its value is quoted nowhere in the reference: not in
a compose excerpt, not in the text around a `file:line` citation. A
project that keeps secrets under other names extends the list in
`docs/capstone/capstone.json`; the override replaces the list, so
repeat the defaults you still want.

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
   assume the vocabulary; the user drives, you record. (Challenging a
   weak answer is not a level-5 behavior: see Pushback below, which
   every level does, differing only in wording.)

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
   `feature`'s final stage) write source code and their
   implementation-plan artifacts, which is their purpose, and only
   after their plan gates.
3. **Docs are skill-owned**: re-runs may rewrite any generated
   section; manual edits are not preserved. Two named exceptions.
   `changelog.md` is append-only; re-runs add entries and never
   rewrite, reorder, or drop them. And the `to` and `from` values in
   `09-interfaces.md`'s `edges:` block belong to the person or the
   confirmation that wrote them: **no run writes or edits one**. A
   consumer's code holds an address, a producer's code holds nothing
   about its callers, so those values answer a question no read of
   this repo can, and a run that re-derived them would overwrite an
   answer with a guess. `map` writes the rest of each row - `kind`,
   `name`, `site`, `schema` - and merges by `(direction, kind, name)`
   per `topics.md`'s interfaces section.
4. Follow `style.md` (same directory) for every sentence you write,
   and `core-authoring.md` for landing it: what is never committed,
   what gets indexed, and how a stage seeds and delegates.
5. **Record what you did**: every run that writes or changes a durable
   output writes its entry as a `<docs_dir>/changelog.d/` fragment
   before setting its done marker (Changelog ledger, below).

## Execution choice

**Always ask at the start of every `feature` or `start` run, including
a new invocation that resumes unfinished work, and wait for the
user's explicit choice before starting any stage work:**

> "Run this pipeline inline in this conversation, or use subagents
> with fresh contexts? Inline avoids extra agent usage; subagents can
> consume your plan's allowance faster."

This is a required choice with **no default**, at every expertise
level. Do not infer it from plan size, tool availability, a saved
`execution` value, an earlier run, silence, or a generic "go ahead".
`non_interactive` cannot answer it: report the missing choice and
stop. If subagents are unavailable, say so when asking; wait for the
user to choose inline or pause rather than selecting inline for them.

The answer governs the **whole current run**: research, prerequisite
stages, reference bootstrap or refresh, planning, readback, coding,
review and wrap. Inline means no subagent dispatch, including
explorers and reviewers, even when tools are available or `map` is
above `subagent_threshold`. Perform that work in this conversation.
Subagent mode permits dispatch where the stage calls for it, under
that stage's existing ordering and concurrency limits.

Carry the explicit answer through stage handoffs and continuation of
the same active run, including context compaction; do not ask again
at each stage. A standalone `implement` or `build` invocation follows
this same choice gate before any prerequisite work or execution,
including a resume that has only review or wrap left. When reached
from `feature` or `start`, it inherits that run's answer instead.

The executor records the choice in its interview frontmatter when
that file exists. That value records the last choice; it never
authorizes a new run. Progress, interview answers and plan approvals
still resume under their own rules. If the user changes mode during
the run, apply the new explicit choice to remaining work; do not
restart completed work or silently change modes yourself.

## Progress tasks: every run shows where it stands

At the start of every run, create a visible task list with the
harness's todo/task tool: one task per phase or numbered step of the
protocol being executed; the chain runners (`start`,
`feature`) hold one task per stage. Mark a task in progress
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

1. **Own state first.** A protocol with an unfinished interview or
   state file reads it before anything else. For a formalized stage,
   read only interview frontmatter needed for lifecycle metadata, then
   read its final outputs; open the completed body only to repair a
   proven omission. A protocol whose prior outputs exist (`uiux/`,
   `logic/`, `spec.md`, `review.md`, ...) reads them before regenerating
   or extending. Never write blind over your own docs.
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
stamps (`generated_at_commit`, `generated_date`, `capstone_version`,
plus `paths_covered` and `content_hash` where the refresh protocol
applies; date-only outside git). `content_hash` is
`git ls-files -s --full-name -- <the file's paths_covered globs>`
piped through `git hash-object --stdin`, truncated to 12 chars
(`ls-files` expands the globs; `ls-tree` does not, and would hash
nothing). It exists
because squash and rebase merges make every branch-commit stamp
unreachable: a refresh that cannot diff from `generated_at_commit`
recomputes this hash instead, and an unchanged hash means current,
so the run degrades to a per-file check rather than a full rebuild.

`capstone_version` is this plugin's own version, read once per run
from its manifest (`.claude-plugin/plugin.json` at the plugin root,
two levels above the running skill's directory; every harness
manifest carries the same value). It records **which capstone wrote
the file**, which template drift cannot: drift detects a section that
went missing, never a section whose meaning changed under it, and
never a rename. A later release migrates an output by reading this
key, not by guessing from shape. Unreadable manifest → omit the key
rather than inventing one; a wrong version is worse than none.

## Missing reference: build it, don't refuse

**A protocol that consumes the reference and finds no `<index_file>`
runs `map` first, then continues its own work.** `map` builds when
there is no index and refreshes when there is, so one delegation
covers both the never-mapped repo and the abandoned one.
Announce it in one line ("no reference yet; building it first"), run
it, then resume the protocol that was invoked. This replaces refusing
with a pointer at `map` or `start`: a user who asked for a
feature spec wants the spec, not an errand.

Five bounds on it:

- **Once per run.** If `map` produces no index either (its
  empty-repo stop: no source files, no entry points, no manifests),
  say so and stop. Never loop.
- **The greenfield stages are exempt** (`mockup`, `logic`, `uiux`,
  `architecture`, `standards`, `stack`, `build`): they build the
  reference through interviews rather than reading one, and their
  prerequisites are upstream formalized outputs, with interview
  frontmatter used only to resume an unfinished stage. `uiux`
  without a mockup still points at `mockup`; `build` without a
  formalized stack still runs `stack`.
- **`map` and `doctor` are exempt.** `map` is what the rule
  delegates to; `doctor` diagnoses the docs area, so a
  missing index is a finding it reports, never a thing it silently
  builds.
- **Interview prerequisites are untouched.** This rule fires only on
  a missing index, never to skip a gate or invent a decision the user
  has not made.
- **A big repo is asked, not told.** Do `map`'s Phase 1 step 8
  sizing first (count tracked source files). Above
  `subagent_threshold` (default 150), say what it will cost - a full
  `map` across N files, before the thing they actually asked for
  - and wait for a yes. Announcing is enough below the threshold;
  above it, a silent full read of someone's monorepo is a bill they
  did not agree to. Declined → do not fall back to working without a
  reference: say what is missing and stop.

## Edge confirmation: answer what the registry cannot join

`map` writes `kind`, `name`, `site` and `schema` into
`09-interfaces.md`'s `edges:` block and never a `to` or a `from`
(hard rule 3). Quarry supplies those by joining every registered
repo's declarations on `(kind, name)`. One repo on the other side
gives one edge; no repo at all leaves the row a publication.
**Several repos on one contract is the case a person has to settle**,
and this section is that ask.

The trigger is narrow. When config `cross_repo` is `auto` and the
`quarry` CLI is on PATH, run `quarry docs index --json` once and read
its `ambiguous` list, keeping the rows whose `repo` is this repo (in
a monorepo with `workspaces` configured, the workspace name, per the
naming contract above). Ask about those rows and nothing else: a row
the join settled is already right, a row with no partner is a
publication and asking would only invite a guess, and a row whose
`to`/`from` is already written is answered. With `cross_repo` off, no
CLI, or an empty `ambiguous` list, nothing is asked and the run
continues.

The ask is **one digest**, whatever the row count, in the shape
core-authoring.md's Artifact seeding uses: a numbered list, one line
per row, each naming its direction, `kind`, `name`, `site`, and the
candidate repos quarry reported, in the order quarry reported them.
The user answers per row with a repo name, several names for a
produced contract, `unknown`, or `skip`. Every answer but `skip` is
written into that row's `to` (a list when several) or `from` in the
block, and the tables are rendered from it. `unknown` records a real
answer: no sibling repo sits on the other side, quarry keeps the row
as a publication, and no later run re-asks it. `skip` writes nothing,
and the row comes back next time.
A name quarry does not list is still written, since the user may know
something the registry has yet to be told; quarry's `docs index`
then reports it unresolved. Vocabulary follows `expertise` like any
interview turn: at level 1 the question reads "which of your other
services reads this queue?", and the phrase "resolve the edge" waits
for level 4.

Under `non_interactive` the run asks nothing, leaves those rows'
`to`/`from` absent, and ends its report with
`N interfaces unresolved; run /capstone:map interfaces`.

Where each protocol asks:

- `map` (`protocols/map.md`, the interfaces pass) asks after the
  block is written and before the chapter is rendered, so the answers
  land in the same run that found the rows.
- `groom`, and `feature` through it (`protocols/groom.md`, Phase A
  step 4), asks before its first question, and only about the
  interfaces the feature adds or changes. The answer goes into the
  spec's Reference impact for `implement`'s wrap to write into the
  chapter, and the confirmed name is what the rest of the interview's
  deps and section calls use.
- `architecture`, and `start` through it
  (`protocols/architecture.md`, the "Ground cross-repo edges" bullet
  and Phase D), confirms each planned edge in the interview, and
  Phase D writes the prescriptive chapter with those names already in
  place.

An answer is a decision, so the run's changelog entry names the rows
it settled in one bullet.

## Changelog ledger: `<docs_dir>/changelog.md`

**Every run that writes or changes a durable output records itself
there: one entry per done marker, on disk before that marker is
set.** The entry is an output like any other; the run is not finished
until it is on disk. Protocols that only read (`help`, `map`'s check
mode) or only route (`start`, `feature`) write no entry; a
refresh one of them delegates is recorded by the protocol that
performs it. Sole exception: `start`'s readback pass
(`protocols/start.md` step 7) records itself, since it changes
recorded decisions rather than routing to a stage that would.

**Entries land as fragments, one file each, folded on sight.** A run
never inserts into `changelog.md` directly: it writes its entry as
its own file, `<docs_dir>/changelog.d/<YYYY-MM-DD>-<stage>-<target>.md`
(the key, slugged, as the filename), holding the complete entry and
nothing else. Distinct filenames are the whole point: the old rule
inserted every entry at the same offset directly below the
frontmatter, so two doc-carrying branches conflicted there every
single time; two branches each writing one new file never conflict.
The fixed-offset insert is retired; nothing writes to `changelog.md`
except the fold.

**Folding:** the next run that already writes the docs area (`map`
building or refreshing, `implement`'s wrap, `doctor` applying
repairs) also folds, **but only on the repo's default branch**
(main/master; anywhere in a repo without branches): read every file
in `changelog.d/`, insert the entries into `changelog.md`
newest-first directly below its frontmatter, delete the fragments,
all in the same run. On any other branch, write your fragment and
leave every fragment alone - folding there would put two branches'
entries back at the same insert offset, which is exactly the
conflict fragments exist to remove. The folded
end state is byte-identical to the old single file. Read-only runs
(`map check`) report leftover fragments instead of folding them, so
a read-only gate stays read-only; a fragment that reaches a reader
before it was folded is a small extra file, harmless, folded away by
the next writing run on main. Create `changelog.md` at the first
fold (any stage may trigger it) with frontmatter stamps only (no
`paths_covered`, so no refresh path regenerates it), and add its
Companion docs row; `changelog.d/` needs no row of its own.

**Reading the ledger means reading all of it**: `changelog.md`, its
rotation files, and any unfolded `changelog.d/` fragments. Every rule
in this section that searches for a key searches all three. An entry
is

    ## <date> - <stage>: <target>
    key: <stage>/<target>@<rev>

followed by **bullets only: no paragraphs, no preamble, no narration
of how the run went.** One bullet per output path naming what changed
about it, then one bullet each for a decision taken, an option
rejected, or a thing left open, deferred, dropped, or ruled out of
scope: the facts a later rewrite of that output would erase. One fact
per bullet, one line where it fits and never more than three; a
bullet needing a paragraph is several bullets. Never restate what the
output already says; point at it. An entry that reads as a story is
wrong even when every fact in it is right: this file is scanned by a
later run hunting one key, never read start to finish.
`<target>` is the thing acted on (`2026-09-05-invite-links`,
`02-models.md`; `all` for a run covering the whole
project). `<rev>` is the highest interview question number incorporated
when the output was formalized (`Q7`) for a stage with an interview
file, otherwise the run's stamp. The revision belongs in the key only;
the output never cites the interview or its question numbers.

Before writing a fragment, search the ledger (all of it, per the rule
above) for the key: if it is already there, this is a resumed run and
the entry stands; never write a second. A
done marker found with no matching key is a torn write: append the
missing entry from the recorded decisions, never re-run the stage.
Writes to `*-interview.md`, `features/*/review-ledger.md` and
`capstone.json` are not reported. A run that produced little still
records: a dropped scenario, a topic recorded absent, a capability
left open are the entry's content, never a reason to skip it.
**The ledger is always committed, whatever `docs_in_git` says** -
`changelog.md`, its rotation files, and `changelog.d/` fragments
alike - and is, with the project config, one of that setting's two
exemptions. It is the only durable record of
why a feature was built the way it was: `implement` deletes the
feature folder - spec, plan, and review ledger - on the strength of
its entry here, so a local-only ledger would turn that deletion into
permanent loss on one machine change. `docs_in_git` and the absence
of git change how an entry is stamped, never whether it is written,
and never whether it is tracked.

**Merges:** fragments carry distinct filenames, so two doc-carrying
branches merge cleanly; the next writing run folds both. A conflict
inside `changelog.md` itself can still appear in a repo whose
branches predate fragments: keep both sides and re-sort the
conflicted block by date, newest first; resolving by picking a side
drops a recorded event.

**Rotation:** the folded file is read whole by `doctor` and
`map check`, so it cannot grow without bound. Past **200 entries**,
the next fold (or `doctor`) moves all but the newest 100 into
`changelog-<YYYY>.md` beside it, the year the moved entries' dates
fall in (same entry format, same newest-first order, its own
Companion docs row, never rewritten afterwards). **Keys move with
their bodies**: a rollup file is still greppable, and every rule that
resolves a key already reads the rotation files, so nothing is left
behind in `changelog.md` - no stripped headings, no `## Archived`
stub section. A repo carrying a `changelog-archive-<YYYY>.md` and an
`## Archived` section from the old body-stripping rotation keeps
them as-is; key searches include them.

**The keys never leave.** `implement` deletes a feature's folder on
the strength of its entry here, and `groom` and `feature` resolve
shipped features from the `implement/*` keys, wherever they live.
Deleting an entry - rather than rotating it - makes a shipped
feature look unstarted and frees its identifier for silent reuse.
Why not delete old entries instead of rotating: same reason.

**One writer at a time.** Nothing here locks: two sessions writing
the docs area at once (two terminals, or a `map` landing mid-wrap)
interleave into the same chapters, and both may fold at once.
Fragments limit the damage - an unfolded entry is never a lost entry
- but the reference is single-writer by assumption. When another
capstone run may be live, say so and stop rather than racing it.

## Interview lifecycle (shared by all interviews)

Interview files are resumable working state. After formalization, the
stage's outputs are the source of truth and every later stage consumes
those outputs. Completed interview bodies are read only to repair a
proven omission in an owning output; the repair lands before work
continues. Final outputs never name or cite interview files or question
numbers. See core-authoring.md's Interviews are working state rule.

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

## Stage ownership: which stage settles what

Interviews generate their questions from the answers before them, so a
stage routinely *surfaces* a decision it does not own - the mockup
stumbles onto a pricing rule, the architecture interview onto a
business rule. Surfacing it is fine. **Recording it there is the
defect**, because the owning stage then either re-decides it or never
sees it.

| Stage | Settles | Never settles |
| --- | --- | --- |
| `mockup` | What exists: surfaces, screens, their elements and where those lead, journeys, the inventory of behaviors the product must decide - and the commercial model: what is sold, at what price, for what allowance, and the equations that price it | The rules behind any of it, the ledger its own commercial model is spent through included |
| `logic` | What happens: triggers and preconditions, exact rules and formulas, branches, unhappy paths, state transitions, invariants, outcomes - including the ledger behind a commercial model it never prices | How it is built, how it looks, what anything costs |
| `uiux` | How it looks and feels: direction, tokens, composition, each state's styled treatment, motion, copy register | When a state is entered, or what a rule decides |
| `architecture` | How the system is built: components and boundaries, models and relationships, data flow, quality attributes, deployment shape | The business rules those components apply |
| `standards` | How code is written here: typing, errors, testing, naming, what an AI must never do in this repo | Which libraries do it |
| `stack` | What is used: libraries, services, versions, licenses, prices | How they are wired, or coded against |

**The test.** A decision belongs to the stage whose subject it answers,
never the stage that happened to reach it first.

**On money, where the two rows meet: `mockup` sets the price, `logic`
runs the ledger.** Anything answering *what does it cost and what do
you get* is the mockup's, formulas included - the one place it decides
arithmetic, and the reason its own stop rule carries an exception.
Anything answering *what happens to the balance, and when* is
`logic`'s: debiting, reserving, reconciling, refunding, expiry, the
behavior at zero, and who absorbs a failure. Expiry is `logic`'s even
though it is commercially motivated, because it is a lifecycle
transition; "unused credits expire monthly" is priced in the mockup
and enforced in a scenario.

**Referencing is not owning.** Any stage may cite another final output
and should: `logic` naming the commercial model the mockup settled is
correct, and restating it instead would be the defect. A decision is
misplaced only where the non-owning stage is its **only** record, or
states it a second time in its own words.

**Declared crossings, which are not misplacement:** the mockup settles
the commercial model for everyone; architecture's framing questions are
pre-filled from the formalized mockup by design; `logic` and
`uiux` in extraction mode record observed fact from code rather than
decisions.

`start`'s readback pass (`protocols/start.md` step 7) is where anything
misfiled anyway gets moved to its owner.

## Pushback: challenge twice, then it is their call

**An interview that records a bad decision without saying so has
failed at its job.** Every interview stage challenges an answer that
looks wrong - but on evidence, never on taste, and never more than
twice.

**Grounds.** Push back only when you can name the conflict:

- it contradicts a decision already recorded in this project's final
   outputs (cite the owning file);
- it contradicts a craft file the stage answers to (`code-craft.md`'s
  ladder or TDD cycle, `arch-craft.md`, `uiux-craft.md`), which for
  the ladder is the case core.md's precedence rule calls an override;
- it contradicts an earlier answer in this same interview;
- it cannot meet a number the user already gave (the stated load,
  budget, deadline, or compliance constraint);
- it is factually broken: an incompatible license, a deprecated or
  unmaintained pick, a pattern that cannot do what they just asked of
  it.

"I would have chosen differently" is not grounds. Neither is a
generic best practice with no stated consequence here.

**The two rounds.**

1. **First.** Say what breaks, concretely and in one short turn: the
   specific consequence, where it conflicts, and the alternative you
   would take instead. Then ask again.
2. **Second, only with a new argument.** If they keep their answer,
   push back once more *only if you have something they have not
   heard* - a consequence you did not raise, or a fact their reply
   revealed. Repeating the first objection louder is not a second
   round; if you have nothing new, skip straight to accepting.

**Then it is theirs.** After two rounds the user's answer stands, and
you take it without further argument, sulking, or hedged compliance.
Do not reopen it later in the interview, and do not relitigate it at
the formalization gate. The one place a settled decision is looked at
again is `start`'s readback pass (`protocols/start.md` step 7), and
only against another stage's decisions: no interview can see those
while it runs, so the conflict was never raisable here.

**Record both sides.** The `### Q<n>` entry records the decision *and*
the objection: what you raised, what they chose, and the reason they
gave if they gave one. The stage's changelog entry gets one bullet for
it. The final output carries the accepted decision and any rationale a
later reader needs, without interview provenance. This is the whole
point of pushing back - a later reader, human or agent, can tell a
considered trade-off from an oversight, and `review` will not re-raise
a question already settled on purpose.

Vocabulary follows `expertise`: level 1 hears the consequence in plain
words ("that would slow down every page for your users - want me to
use X instead?"), level 5 gets the trade-off flatly. The level never
changes *whether* you push back, only how it sounds. This is
conversation, never the generated docs: the outputs stay factual per
hard rule 1, recording the decision and that it was challenged, never
grading it.

## Questionnaires: what the user cannot answer alone

Pushback assumes the user holds the answer and is choosing badly.
Some questions are not that. The compliance regime, last quarter's
real load numbers, the retention policy another team owns - on those
the user can only guess, and a guess recorded as a decision is worse
than a recorded gap. The person who knows is not in this
conversation, so the useful output of the question is a document they
can be sent.

**Grill the send, not the subject.** Never interview the user about
the thing they have just told you they do not know. Ask only what
they can always answer: who holds the knowledge, and what you need
back. Two exchanges, no more.

1. Who can answer this? A name or a team is enough.
2. Is there a date you need it back by, and does the recipient need
   anything to make sense of the ask?

Then write the file, say where it is, and go to the next question.

The trigger is narrow. An answer of "I don't know", "ask X", or a
guess the user flags as a guess, on a question whose `### Q<n>` entry
would otherwise record a fabricated decision. One offer per question
and never repeated: the user may decline and leave the item open,
which is recorded as an open question exactly as it is today.

The output is `<docs_dir>/questionnaires/<YYYY-MM-DD>-<slug>.md`, the
slug naming the recipient rather than the question, so several
stalled questions from one interview batch into one document. Its
sections, in this order:

- `## Purpose` - why the document exists and the decision riding on
  the answers.
- `## Context` - one paragraph orienting a reader who was not in the
  interview: what the project is, what stage it has reached, and why
  they are being asked.
- `## How to answer` - the deadline if there is one, roughly how much
  work this is, and that a partial answer or an explicit "I don't
  know" is more useful than a skipped question.
- `## Questions` - one `### ` heading per question, most important
  first, each a single idea and never compound, each followed by an
  empty blockquote for the answer to be written into. A one-line
  italic *Why this matters* goes under a question that could be
  misread or that invites a throwaway, and nowhere else.
- `## Anything else?` - the closing catch-all.

**Never invent a question to fill the document out.** The count is
honest to what stalled: one stalled question is a one-question
questionnaire. Padding spends the recipient's attention on questions
nobody was blocked on, and the answers you actually needed are the
ones they then skip.

The interview records the send as its `### Q<n>` entry, naming the
file and the recipient, and the item stays open in the stage's ledger
until an answer arrives. Formalization is not blocked by it: the
stage closes with those items recorded open, like any other open
question. When the user comes back with answers, resume the interview
at those questions and write the answers into the stage's own output;
the questionnaire file stays on disk as the record of what was asked.

`questionnaires/` is committed, like the ledger and `capstone.json`
(core-authoring.md's Local-only outputs), and the folder gets a
Companion docs row.

Vocabulary follows `expertise` in the two exchanges, like any
interview turn. The document itself is pitched at its recipient
instead, spelling out what a stranger to the project needs and
dropping the shorthand the interview has been speaking in.
`architecture`, `logic`, `mockup`, `stack`, `standards` and `uiux`
each name this section at the point they record an answer.

## Voice per output

`map check` is facts only, as are the changelog entries every
stage appends, `review`'s among them.
`review` is the sole opinionated output. `standards`, `logic`,
`uiux`, `stack`, and `groom`'s `spec.md` are normative but only
record the user's own stated decisions (`logic` and `uiux` in
extraction mode are descriptive like the chapters: observed fact, hard
rule 1 in full); `build`'s `implementation.md` and `plan`'s `plan.md`
are instructional: they may use imperative voice, but every command
must be verified and every step cites its files; style.md's density
and naming rules still bind.

