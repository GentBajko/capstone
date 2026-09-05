# groom - doc-grounded feature interview

**Reads:** config → the feature's `feature-interview.md` (resume) →
`<index_file>` → the touched topic chapters (after the staleness
pass) → the `logic/` scenarios and `mockup/` screens it extends, plus
the `uiux/` chapters for UI features → `standards.md`.

First stage of the feature chain (`groom` → `plan` → `implement`,
chained by `feature`): turns a feature idea into a spec a
planner could work from, grounded in the existing reference instead of
re-exploring the repo. The superpowers brainstorming discipline,
adapted to capstone: the chapters are the context, every answer
persists before the next question, and the spec traces each
requirement to a recorded decision.

Prerequisite: a stamped index. Without one, build it first per core.md's
Missing reference rule (run `map`, which builds one when none
exists), then groom against it: grooming against no reference is
guessing, and `map` producing no index either - an empty repo - is
the one case that stops the run.

State: `docs/capstone/features/<id>/feature-interview.md`, same
resumable format as the other interviews (frontmatter with `status`,
numbered `§Q` decision entries; standard lifecycle per core.md; never
indexed). `<id>` is `<YYYY-MM-DD>-<slug>`: the date this groom began
plus a short kebab name for the feature. The id is derived from the
request, never allocated from a ledger: the old `<NN>-<slug>` scheme
took the next number from what was visible on the current branch, so
two parallel PRs both minted `03-`. Existing `<NN>-<slug>` folders
and keys stay as they are and are matched like any other id; only
new features get the date form.
Output: `spec.md` beside it; the `features/` folder is one Companion
docs row. Later stages add their own keys to the same frontmatter
(`plan_approved`, `approved_spec`, `base_commit`, `implemented`);
`status: formalized` here means the spec is on disk, not that the
feature is built.

**Resume:** before anything else, match the request against existing
`docs/capstone/features/*/` ids and spec titles **and against the
`implement/*` keys in the ledger** (`changelog.md`, its rotation
files, and unfolded `changelog.d/` fragments, per core.md), whose
features are shipped and whose folders `implement` deleted. Never
reuse a shipped feature's id, legacy `<NN>-<slug>` ids included.

A match on a changelog key only (no folder) is a **shipped** feature:
say so and show that entry. A request to change it is a new feature
grooming against the shipped behavior now recorded in `logic/` and the
chapters, not a reopening: give it its own date-slug id, and have its
`§Q` entries cite the earlier key as the thing being amended. There is no
folder to reopen, and re-deriving one from the changelog would invent
decisions the user never restated.

A match on a folder still present continues as before: read its
`feature-interview.md` and continue: `interviewing` resumes the
interview after re-running Phase A's staleness pass (never re-ask an
answered `§Q`), `awaiting-formalization` re-presents the gate,
`formalized` points at `plan`, unless the request changes the
feature itself: then reopen from `spec.md`, set `status: interviewing`,
and interview only the change (new `§Q` entries may name prior working
entries internally, but the rewritten spec may not),
re-gate, and rewrite `spec.md`; the changed spec voids any recorded
plan approval via `plan`'s checksum rule. `formalized` with
`spec.md` missing or partial is a crash: regenerate the spec from the
recorded `§Q` decisions, without re-interviewing.

## Phase A - study

1. Per core.md: read the config; expertise governs the conversation.
2. From the index, pick the topics the feature touches:
   architecture and models almost always; the rest as the idea
   implies. Run `map check`'s staleness test on just those topics
   and refresh any stale ones first (as `ask` does): a spec groomed
   against a stale reference is stale on arrival. For
   `mode: prescriptive` chapters the refresh protocol's verdict
   governs: no tracked source yet → current by definition; code now
   exists → stale by definition, refresh first.
3. Read the picked chapters, plus whichever companion docs bear on the
   feature: the `logic/` scenarios it extends, the `mockup/` screens
   it changes, the `uiux/` chapters it touches, `standards.md`.
   Never ask what these already answer.
4. **Cross-repo constraints, before the first question.** When config
   `cross_repo` is `auto` (the default), the `quarry` CLI is on PATH,
   and the repo has a `09-interfaces.md`: run
   `quarry docs deps <repo> --downstream --json` (`<repo>` = the last
   path segment of this repo's origin URL), then
   `quarry docs section <consumer> "<contract>"` for each consumer
   the deps call returns, to read the contract fields each downstream
   repo actually depends on. When the feature touches an interface no
   declared edge covers, fall back to
   `quarry docs search "<name>"`. Any condition unmet (config `off`,
   no CLI, no chapter) → skip silently and groom exactly as before.
   This lives here, in protocol text, deliberately - never as a
   harness hook, because capstone also runs on harnesses without
   hooks.
5. An artifact argument (a ticket, a PRD, notes) seeds the interview
   per core-authoring.md's Artifact seeding rule.

## Phase B - the interview

One question per turn, expertise-calibrated, per the conduct rules in
`../interview.md`: concrete options when enumerable, quantified
answers, YAGNI ruthlessly. Record every answer as a `§Q` entry in
`feature-interview.md` before asking the next question. The
generation rule: **"if I had to write the spec right now, what would
I have to invent?"** The next question is whatever tops that list.

- When Phase A step 4 found downstream consumers, the **first
  question cites the constraint**: name the consumer, the contract,
  and the fields it reads, and ask how the feature holds or breaks
  them. A groomed change to a produced interface that never surfaced
  its consumers is a spec defect.
- Scope first: if the description hides several independent features,
  say so and split: each gets its own `features/` entry and its own
  chain run. Groom one; list the rest in the interview file.
- Settle purpose, users, and success criteria before mechanics.
- For the shape decision, present 2-3 approaches with trade-offs and a
  recommendation, never one. Record the rejected alternatives and
  why.
- Walk the unhappy paths like `logic` does: per step: fails, invalid,
  happens twice, happens late, concurrent, cancelled midway.
- A feature that contradicts a recorded decision in the reference is a
  question, not a silent override: show the chapter's decision, ask
  which governs.

## Phase C - the gate, then the spec

Present the design as a short summary (what it does, chosen approach,
edge-case posture, what's out of scope) and set
`status: awaiting-formalization`. On approval write `spec.md`:

- **What & why**: the feature in one paragraph; success criteria.
- **Requirements**: numbered, with each confirmed decision and any
  needed rationale written directly into the spec.
- **Approach**: the chosen shape and the rejected alternatives.
- **Behavior**: happy path, branches, unhappy paths, state changes;
  exact rules with real numbers, `logic/`-style.
- **Reference impact**: which chapters this will change once built,
  AND the scenario docs to absorb into after implementation: the
  `logic/` scenarios it adds or amends, the `mockup/` screens it
  changes, the `uiux/` chapters it touches (`plan` reads this to
  scope its study; `implement`'s wrap performs the absorption; the
  `map` refresh settles the chapters).
- **Out of scope**: non-goals, recorded as decisions.

Self-review before handing the file over (fix inline, don't re-gate):
no placeholders ("TBD", "handle errors appropriately"), no section
contradicting another, no requirement readable two ways, scoped to a
single plan. Then write the changelog entry per core.md's ledger: key
`groom/<id>@Q<n>`, `<n>` the highest `§Q` in
`feature-interview.md`; record the chosen approach with the rejected
alternatives and the out-of-scope rulings. Add or refresh the
`features/` Companion docs row, set `status: formalized` (only now,
outputs on disk), and hand the
user the `spec.md` path to review: a standalone run stops here; an
`feature` chain run announces the stage and continues.

**Consumer:** `plan` turns the spec into a task-by-task implementation
plan; suggest it as the next step.
