# Shared Rules (read by every subcommand)

## User config — `docs/capstone/capstone.json`

The config lives at the fixed path `docs/capstone/capstone.json` no
matter what `docs_dir` is set to — `docs_dir` relocates generated
outputs only, never the config, so a custom `docs_dir` can always be
discovered. Read it first if present; absent keys use the defaults
below. **Legacy path:** capstone used to default to `docs/design`. If
`docs/capstone/capstone.json` is absent but `docs/design/capstone.json`
exists, that project predates the rename — use it and its `docs_dir` as
they stand, and offer once to move the directory to `docs/capstone`
(`git mv` when tracked) and update `docs_dir`; never migrate unasked and
never generate a second tree alongside the old one.
`docs_dir` and `index_file` must be relative paths inside the
repository; refuse anything else. The plugin materializes the file:
whenever you write any output and it does not exist, run the idempotent
initializer from the `docs` skill's `scripts/` directory —
`init-config.sh` via bash (macOS/Linux/Git Bash) or `init-config.ps1`
via powershell (Windows); if neither shell is available, write this
template yourself —

```json
{
  "expertise": null,
  "docs_dir": "docs/capstone",
  "index_file": "DESIGN.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en",
  "pipeline": null
}
```

`"expertise": null` means "not yet asked" — behave as level 3 until the
ask-once rule below fills it. `"pipeline": null` means the
docs-vs-pipeline fork (see `protocols/start.md`) has not been asked;
`true`/`false` records the user's answer so it is never re-asked. The
config file is never indexed (it is a settings file, not a doc).

`docs_in_git` (`"commit" | "ignore" | "ask"`) pre-answers the
commit-or-gitignore question **for the factual reference only** — the
index and the topic chapters, plus `guides/`, `onboarding.md`,
`logic/`, `mockup/` and `code-prefs.md`. `language` sets the generated
docs' language. The user can change any key by editing the file or just
telling you.

## Local-only outputs — `<docs_dir>/.gitignore`

Some outputs are personal working state and are **never committed**,
whatever `docs_in_git` says: `features/` (the whole feature chain —
interviews, specs, plans, review ledgers), every `*-interview.md`,
`capstone.json`, `review.md`, and `changelog.md`. The initializer writes
`<docs_dir>/.gitignore` listing exactly those; whenever you write into
`<docs_dir>` and that file is absent, create it — the same idempotent
initializer does both (`init-config.sh [docs_dir]` /
`init-config.ps1 [docs_dir]`). The `.gitignore` itself is committed, so
the rules travel with the repo.

**`groom`, `plan`, and `implement` never commit the docs area.** They
commit source code only — `implement`'s per-task commits name the paths
the task touched and never `git add` `<docs_dir>` or `<index_file>`.
Reference chapters that `implement`'s wrap refreshes are left staged or
dirty for the repo's normal flow to handle, per `docs_in_git`.

**`expertise` (1–5) calibrates every conversation with the user — never
the generated docs**, which serve AI sessions and stay dense per
style.md regardless:

1. **vibe** — plain language only; explain any unavoidable term in one
   clause; interviews ask about goals and experience, then derive the
   technical decision yourself and confirm it in plain words ("I'll use
   a managed database so you never run servers — OK?"); strong
   recommended defaults; never ask for numbers the user can't know —
   translate ("roughly how many people at once?") and derive the
   technical targets yourself, recording them as derived decisions.
   This overrides the interview conduct rules' quantification demands:
   the numbers still get recorded, but you compute them.
2. **explorer** — as 1, but introduce the proper term alongside each
   plain explanation and add short why-it-matters notes; teach while
   asking.
3. **builder** (default) — normal technical vocabulary; recommended
   option first with one-line trade-offs.
4. **engineer** — terse; jargon unexplained; ask for numbers directly
   (percentiles, RTO/RPO); rationale only on request.
5. **architect** — maximally terse; lead with trade-off matrices;
   challenge weak or inconsistent answers; the user drives, you record.

If `expertise` is null or missing and the task is interactive (any
interview, `ask`, `onboarding`, `review`), ask ONE question — "How
technical should I be with you?" with the five levels — then write the
answer into the config file (creating it with all keys if needed), and
never ask again. Non-interactive runs behave as level 3 without asking
and leave `expertise` null.

## Hard rules

1. **Describe, never judge** — facts with `file:line` pointers; no
   recommendations, grades, or comparisons. Sole exception: `review`,
   and only because the user explicitly invoked it.
2. **Write only the configured docs area** — `<docs_dir>/*` plus the
   index `<index_file>` (defaults: `docs/capstone/*` and `DESIGN.md`) and
   the config file. Never touch source code, `openspec/`, or
   human-authored docs. Sole exceptions: the `build` protocol (invoked
   directly or as `start`'s final stage) and the `implement` protocol
   (invoked directly or as `implementation`'s final stage) write
   source code and their implementation-plan artifacts — that is their
   purpose — and only after their plan gates.
3. **Docs are skill-owned** — re-runs may rewrite any generated section;
   manual edits are not preserved. Sole exception: `changelog.md` is
   append-only — re-runs add entries and never rewrite, reorder, or
   drop them.
4. Follow `style.md` (same directory) for every sentence you write.
5. **Record what you did** — every run that writes or changes a durable
   output appends its entry to `<docs_dir>/changelog.md` before setting
   its done marker (Changelog ledger, below). Nothing this plugin does
   goes unrecorded.

Everything a subcommand writes carries the topic-file frontmatter stamps
(`generated_at_commit`, `generated_date`, plus `paths_covered` where the
refresh protocol applies; date-only outside git).

**Index maintenance:** every file this plugin writes under
`docs/capstone/` must be listed in `DESIGN.md` — topics in the topic
index (chapterized filenames: `01-architecture.md` … `08-glossary.md`,
so the folder reads in order even without the index), everything else
(review, changelog, onboarding, code-prefs, implementation, guides/,
logic/, mockup/, features/) as a row in a "Companion docs" table (file
· what it is · date). All indexes
and outputs are markdown — never generate HTML, for anything. The only exceptions are interview Q&A files
(`architecture-interview.md`, `mockup-interview.md`,
`code-prefs-interview.md`, `logic-interview.md`, `stack-interview.md`,
`build-interview.md`, `features/*/feature-interview.md`,
`features/*/review-ledger.md`) and `capstone.json`, which are never
indexed. After writing your output, append your changelog entry
(Changelog ledger, below), then add or refresh your
row; if `DESIGN.md` does not exist yet, create a minimal one (title +
the two tables) rather than leaving the output orphaned.

## Changelog ledger — `<docs_dir>/changelog.md`

**Every run that writes or changes a durable output records itself
there: one entry per done marker, appended before that marker is set.**
The entry is an output like any other — the run is not finished until it
is on disk. Protocols that only read (`check-docs`, `ask`, `help`) or
only route (`start`, `implementation`) write no entry; a refresh one of
them delegates is recorded by the protocol that performs it.

Create the file on first write — any stage may be its first writer —
with frontmatter stamps only (no `paths_covered`, so no refresh path
regenerates it), and add its Companion docs row. **Insert directly below
the frontmatter, never at end of file**: entries are newest-first and
`protocols/changelog.md` reads from the top. Only the `changelog`
command writes a heading carrying a `(<base>..<head>)` range; a stage
entry is

    ## <date> — <stage>: <target>
    key: <stage>/<target>@<rev>

followed by one bullet per output path, naming what changed about it,
the decisions and rejected options recorded, and what was left open,
deferred, dropped, or ruled out of scope — the facts a later rewrite of
that output would erase. It is a receipt, not a second copy: never
restate what the output already says, point at it. `<target>` is the
thing acted on (`03-invite-links`, `02-models.md`, `run-locally`; `all`
for a run covering the whole project). `<rev>` is the highest interview
question number the output traces to (`Q7`) for a stage with an
interview file, otherwise the run's stamp.

Before appending, search the file for the key: if it is already there,
this is a resumed run and the entry stands — never append a second.
A done marker found with no matching key is a torn write: append the
missing entry from the recorded decisions, never re-run the stage.
Writes to `*-interview.md`, `features/*/review-ledger.md` and
`capstone.json` are not reported. A run that produced little still
records — a dropped scenario, a topic recorded absent, a capability left
open are the entry's content, never a reason to skip it. `docs_in_git`
and the absence of git change how an entry is stamped, never whether it
is written.

## Interview lifecycle (shared by all interviews)

An interview file's `status` moves `interviewing` →
`awaiting-formalization` (set when the summary gate is presented) →
`formalized`, and **`formalized` is written only AFTER the stage's
outputs — its changelog entry included — are fully on disk** — never
before generation, so a crash can't
strand a formalized stage with missing outputs. Exception: `logic` has
per-scenario gates instead of one summary gate, so it never uses
`awaiting-formalization` — it stays `interviewing` and keeps a scenario
checklist in its frontmatter
(`scenarios: [{name, status: pending|written|dropped}]`), moving
straight to `formalized` once every listed scenario is `written` or
`dropped` and the index row exists. The pipeline runner
(`protocols/start.md`) keys stage completion on these rules.

Voice: `check-docs`/`ask`/`changelog` are facts only — including the
changelog entries other stages append, `review`'s among them. `review` is the
one opinionated output. `code-prefs`, `logic`, `stack`, and `groom`'s
`spec.md` are normative but only record the user's own stated
decisions; `build`'s `implementation.md` and `plan`'s `plan.md` are
instructional like `guides`. `guides`/`onboarding` may use
imperative/narrative voice, but every command must be verified and every
step cites its files — style.md's density and naming rules still bind.

Maintenance: each subcommand = `references/protocols/<name>.md` + a
wrapper skill at `skills/<name>/`; update both when the surface changes,
plus `scripts/help.sh` AND `scripts/help.ps1` (same usage text, kept in
sync — one per platform). Every script in this plugin ships as .sh
(Unix/Git Bash) and .ps1 (Windows) pairs — sole exception:
`help-hook.sh` is bash-only because `hooks.json` invokes bash
explicitly. `scripts/lint-sync.sh` (and
`.ps1`) asserts every cross-file invariant — run it after any surface
change; CI runs it on every push.
