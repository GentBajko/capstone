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
support), run that initializer yourself: `init-config.sh --global`
via bash, which on Windows means Git Bash. If bash is unavailable,
write this template yourself:

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
workspace's index), `map` iterates the workspaces (an
argument targets one), and other
commands operate on the workspace whose paths the request touches,
asking when ambiguous.

`docs_in_git` (`"commit" | "ignore" | "ask"`) pre-answers the
commit-or-gitignore question **for the factual reference only**: the
index and the topic chapters, plus `logic/`, `mockup/`, `uiux/`,
`standards.md`, and `changelog.md`.
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

1. **Own state first.** A protocol with an interview or state file
   reads it before anything else; a protocol whose prior outputs
   exist (`uiux/`, `logic/`, `spec.md`, `review.md`, ...) reads
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
stamps (`generated_at_commit`, `generated_date`, `capstone_version`,
plus `paths_covered` where the refresh protocol applies; date-only
outside git).

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
  reference from interviews rather than reading one, and their
  prerequisites are upstream *interviews*, not the index. `uiux`
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

## Changelog ledger: `<docs_dir>/changelog.md`

**Every run that writes or changes a durable output records itself
there: one entry per done marker, appended before that marker is
set.** The entry is an output like any other; the run is not finished
until it is on disk. Protocols that only read (`help`, `map`'s check
mode) or only route (`start`, `feature`) write no entry; a
refresh one of them delegates is recorded by the protocol that
performs it. Sole exception: `start`'s readback pass
(`protocols/start.md` step 7) records itself, since it changes
recorded decisions rather than routing to a stage that would.

Create the file on first write (any stage may be its first writer)
with frontmatter stamps only (no `paths_covered`, so no refresh path
regenerates it), and add its Companion docs row. **Insert directly
below the frontmatter, never at end of file**: entries are
newest-first, so the newest is always the one directly under the
frontmatter. An entry is

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
`<target>` is the thing acted on (`03-invite-links`,
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
**The ledger is always committed, whatever `docs_in_git` says**, and
is that setting's sole exception. It is the only durable record of
why a feature was built the way it was: `implement` deletes the
feature folder - spec, plan, and review ledger - on the strength of
its entry here, so a local-only ledger would turn that deletion into
permanent loss on one machine change. `docs_in_git` and the absence
of git change how an entry is stamped, never whether it is written,
and never whether it is tracked.

**Merges:** every entry inserts at the same offset, directly below the
frontmatter, so branches conflict there routinely. Keep both sides and
re-sort the conflicted block by date, newest first: resolving by
picking a side drops a recorded event.

**Rotation:** the file is append-only and read whole by `doctor` and
`map check`, so it cannot grow without bound. Past **200 entries**,
`doctor` moves all but the newest 100 into
`changelog-archive-<YYYY>.md` beside it (same entry format, same
newest-first order, its own Companion docs row, never rewritten
afterwards).

**The keys never leave.** `feature` resolves shipped features and
allocates the next `<NN>` from the `implement/*` keys here, so
rotation leaves every archived entry's `## <date>` heading and `key:`
line in place, bullets removed, under a trailing `## Archived`
section naming the archive file. Bodies move; keys stay. A rotation
that drops a key retires an `<NN>` into reuse and makes a shipped
feature look unstarted.

**One writer at a time.** Nothing here locks: two sessions writing
the docs area at once (two terminals, or a `map` landing mid-wrap)
interleave into the same chapters and the same insert offset. Append-
only limits the damage to a conflict rather than a lost entry, and
the Merges rule resolves it, but the reference is single-writer by
assumption. When another capstone run may be live, say so and stop
rather than racing it.

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

**Referencing is not owning.** Any stage may cite another's decision and
should: `logic` naming the commercial model the mockup settled is
correct, and restating it instead would be the defect. A decision is
misplaced only where the non-owning stage is its **only** record, or
states it a second time in its own words.

**Declared crossings, which are not misplacement:** the mockup settles
the commercial model for everyone; the architecture interview's framing
section is pre-filled from `mockup-interview.md` by design; `logic` and
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

- it contradicts a decision already recorded in this project (cite the
  file and `§Q`);
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
it. This is the whole point of pushing back - a later reader, human or
agent, can tell a considered trade-off from an oversight, and `review`
will not re-raise a question already settled on purpose.

Vocabulary follows `expertise`: level 1 hears the consequence in plain
words ("that would slow down every page for your users - want me to
use X instead?"), level 5 gets the trade-off flatly. The level never
changes *whether* you push back, only how it sounds. This is
conversation, never the generated docs: the outputs stay factual per
hard rule 1, recording the decision and that it was challenged, never
grading it.

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

