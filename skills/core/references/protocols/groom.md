# groom - doc-grounded feature interview

**Reads:** config → the feature's `feature-interview.md` (resume) →
`<index_file>` → the touched topic chapters (after the staleness
pass) → the `logic/` scenarios and `mockup/` screens it extends, plus
the `design/` chapters for UI features → `code-prefs.md`.

First stage of the feature chain (`groom` → `plan` → `implement`,
chained by `implementation`): turns a feature idea into a spec a
planner could work from, grounded in the existing reference instead of
re-exploring the repo. The superpowers brainstorming discipline,
adapted to capstone: the chapters are the context, every answer
persists before the next question, and the spec traces each
requirement to a recorded decision.

Prerequisite: a stamped `DESIGN.md` index. Without one, stop and point
the user at `generate` (existing code) or `start` (greenfield): grooming
against no reference is guessing.

State: `docs/capstone/features/<NN>-<slug>/feature-interview.md`, same
resumable format as the other interviews (frontmatter with `status`,
numbered `§Q` decision entries; standard lifecycle per core.md; never
indexed). `<NN>` continues the `features/` folder's numbering (01 when
the folder is new); `<slug>` is a short kebab name for the feature.
Output: `spec.md` beside it; the `features/` folder is one Companion
docs row. Later stages add their own keys to the same frontmatter
(`plan_approved`, `approved_spec`, `base_commit`, `implemented`);
`status: formalized` here means the spec is on disk, not that the
feature is built.

**Resume:** before anything else, match the request against existing
`docs/capstone/features/*/` slugs and spec titles: never mint a new
`<NN>` for a feature that already has a folder. On a match, read its
`feature-interview.md` and continue: `interviewing` resumes the
interview after re-running Phase A's staleness pass (never re-ask an
answered `§Q`), `awaiting-formalization` re-presents the gate,
`formalized` points at `plan`, unless the request changes the
feature itself: then reopen: set `status: interviewing`, interview
the change (new `§Q` entries naming the ones they supersede),
re-gate, and rewrite `spec.md`; the changed spec voids any recorded
plan approval via `plan`'s checksum rule. `formalized` with
`spec.md` missing or partial is a crash: regenerate the spec from the
recorded `§Q` decisions, without re-interviewing.

## Phase A - study

1. Per core.md: read the config; expertise governs the conversation.
2. From the DESIGN.md index, pick the topics the feature touches:
   architecture and models almost always; the rest as the idea
   implies. Run `sync check`'s staleness test on just those topics
   and refresh any stale ones first (as `ask` does): a spec groomed
   against a stale reference is stale on arrival. For
   `mode: prescriptive` chapters the refresh protocol's verdict
   governs: no tracked source yet → current by definition; code now
   exists → stale by definition, refresh first.
3. Read the picked chapters, plus whichever companion docs bear on the
   feature: the `logic/` scenarios it extends, the `mockup/` screens
   it changes, the `design/` chapters it touches, `code-prefs.md`.
   Never ask what these already answer.
4. An artifact argument (a ticket, a PRD, notes) seeds the interview
   per core.md's Artifact seeding rule.

## Phase B - the interview

One question per turn, expertise-calibrated, per the conduct rules in
`../interview.md`: concrete options when enumerable, quantified
answers, YAGNI ruthlessly. Record every answer as a `§Q` entry in
`feature-interview.md` before asking the next question. The
generation rule: **"if I had to write the spec right now, what would
I have to invent?"** The next question is whatever tops that list.

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
- **Requirements**: numbered, each traceable to its `§Q` entry.
- **Approach**: the chosen shape and the rejected alternatives.
- **Behavior**: happy path, branches, unhappy paths, state changes;
  exact rules with real numbers, `logic/`-style.
- **Reference impact**: which chapters this will change once built,
  AND the scenario docs to absorb into after implementation: the
  `logic/` scenarios it adds or amends, the `mockup/` screens it
  changes, the `design/` chapters it touches (`plan` reads this to
  scope its study; `implement`'s wrap performs the absorption; the
  `sync` refresh and `changelog` settle the chapters).
- **Out of scope**: non-goals, recorded as decisions.

Self-review before handing the file over (fix inline, don't re-gate):
no placeholders ("TBD", "handle errors appropriately"), no section
contradicting another, no requirement readable two ways, scoped to a
single plan. Then append the changelog entry per core.md's ledger: key
`groom/<NN>-<slug>@Q<n>`, `<n>` the highest `§Q` in
`feature-interview.md`; record the chosen approach with the rejected
alternatives and the out-of-scope rulings. Add or refresh the
`features/` Companion docs row, set `status: formalized` (only now,
outputs on disk), and hand the
user the `spec.md` path to review: a standalone run stops here; an
`implementation` chain run announces the stage and continues.

**Consumer:** `plan` turns the spec into a task-by-task implementation
plan; suggest it as the next step.
