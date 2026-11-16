# architecture - interview-driven design for a greenfield project

**Reads:** config → `architecture-interview.md` (resume) →
`../interview.md` in full before the first question → upstream
artifacts if present: `standards.md`, `logic/`,
`mockup/README.md` (screens as questions touch them) →
`../code-craft.md` (the ladder bounds the design) →
`../topics.md` at generation.

Design-time mode: there is no code to describe, so the reference is
built from an exhaustive interview instead. Three strict phases with a
user gate between the last two.

**YAGNI bounds the design, not just the code** (`../code-craft.md`).
This stage decides what will exist before anything does, so a layer,
boundary, service, queue, or abstraction agreed here is code the
ladder never gets a chance to stop later. Every structural element
needs a recorded reason it is needed **now**, captured while
interviewing and written into the final chapter with its rationale, or
traceable to a logic scenario; "we'll need it when we scale" is offered
as a deferred decision with a trigger rather than built. Exhaustive
means every question answered - it does not mean every part designed
in. This is a position you argue, not a veto: per core.md's Pushback
rule you make the case at most twice, and a user who still wants it
now gets it, with the exchange recorded.

**The exhaustiveness criterion is twofold.** The interview is complete
only when (a) every applicable item in `../interview.md`, the merged
question inventory, has been asked, answered, or recorded as
not-applicable, AND (b) every required section of every applicable topic
in `../topics.md` can be written from recorded answers. Payloads sit
inside (b): every `schema` a planned `09-interfaces.md` row names must
have its `02-models.md` `### <Entity>` field table answerable from
recorded decisions, or the row's inline fields must be. Both are
checkable conditions: sweep them and ask about whatever is not yet
answerable. Never assume: any default you want to apply must be surfaced
as a question or an explicitly-confirmed default, not silently adopted.
Read `../interview.md` in full before asking the first question; its
Conduct rules section governs the whole interview. Then check for
upstream artifacts, each read only if it exists:
`docs/capstone/standards.md`, `docs/capstone/logic/` (the business-logic
scenario files; they pre-fill models: entities, invariants,
consistency needs; data-flow: lifecycles; and quality-attribute
scenarios), and the mockup itself (`docs/capstone/mockup/README.md`,
plus individual screens when a question touches the flows they
depict). Record everything they answer as derived decisions; never
re-ask it.

A question here will regularly reach a decision this stage does not
own - a business rule, a screen's behavior, a library pick. Per
core.md's Stage ownership table, record it where it belongs: an
unsettled business rule is recorded as an open thread `for: logic` in
`architecture-interview.md` and named at the gate, never answered here,
and this stage never edits `logic/`; a rule `logic/` already settled
is cited, never restated. Conventions and dependency answers are
`standards`' and `stack`'s to settle: Phase D records them as
provisional (core.md's Stage ownership, Declared crossings). What this
stage settles is how the system is built, not what it decides at
runtime.

A different kind of stall is a question this stage does own and the
user cannot answer: the compliance regime, the real load numbers, the
retention window another team sets. Offer a questionnaire per
core.md's Questionnaires section rather than recording a guess as a
quality-attribute target.

## Phase A - setup / resume

The interview state lives in `docs/capstone/architecture-interview.md`.
If it exists and is unfinished, read it and resume; never re-ask an
answered question. If it is formalized, read the final architecture
chapters instead; open the interview body only to repair a proven
omission in them.
If it does not exist, create it, **seeding `## Open questions` once**
as a
section-granularity checkbox ledger (about 20 lines: one box per
`../interview.md` section, §0's subsections and §2's checklists each
their own, never one per question):

```markdown
---
project: <name>
started: <date>
status: interviewing   # see core.md "Interview lifecycle"
---

# Architecture Interview

## Decisions
(numbered Q&A entries appended here)

## Open questions
- [ ] §0 Framing
  - [ ] 0.1 Business & product
  - [ ] 0.2 Users & load
  - [ ] 0.3 Constraints
  - [ ] 0.4 Team & organization
  - [ ] 0.5 Operations & risk posture
- [ ] §1 Shape decisions
- [ ] §2 Topic checklists
  - [ ] → architecture.md
  - [ ] → models.md
  - [ ] → conventions.md
  - [ ] → data-flow.md
  - [ ] → dependencies.md
  - [ ] → testing.md
  - [ ] → operations.md
  - [ ] → glossary.md
- [ ] §3 Quality attributes
- [ ] §4 Conditional modules
- [ ] §5-6 Wrap-up + red-flag screen
(§0 and §2 start split; split any other section into sub-items only
when partially done)
```

§0 and §2 start split because their sub-items are the unit a resumed
run and a shared dialog both work in. A file an earlier version
seeded flat is resumed as found: split its section in progress and
leave the rest.

The file is created whether or not an artifact argument is given. An
artifact (an RFC, an ADR set, notes) then seeds the new file per
core-authoring.md's Artifact seeding rule.

## Phase B - the interview loop

- **One decision per question.** Offer concrete options when the
  choice space is enumerable; open-ended otherwise. The independent
  picks of one subsection of `../interview.md` §0, §2 or §4 may share
  a dialog per core.md's Shared dialogs. Every other question has a
  turn to itself: an open-ended one, a follow-up, and all of §1, §3,
  §5 and §6, where an answer is a one-way door, owes a response
  measure, or reopens a recorded decision. Ask follow-ups spawned by
  answers before the next dialog, and before moving to the next
  area.
- **Record immediately.** After each answer, and after every answer
  of a shared dialog, append its entry before asking anything
  further; the file must survive a dead session:

  ```markdown
  ### Q<n> - <topic>/<section> (<date>)
  **Q:** <question as asked>
  **A:** <answer as given>
  **Decision:** <the normalized decision this implies>
  ```

  Decisions derivable from earlier answers are recorded as
  `### D<n> - derived` entries with the reasoning, not re-asked, but
  state them to the user as you go so wrong derivations get caught.
- **Ground cross-repo edges in the real contract.** When config
  `cross_repo` is `auto` and the `quarry` CLI is on PATH (no
  `09-interfaces.md` precondition here - a greenfield repo has none
  yet), any answer or upstream doc naming an existing system this
  product will talk to gets looked up before the follow-up question:
  `quarry docs search "<name>"` to find the repo, then
  `quarry docs section <repo> "<contract>"` to read the contract as
  that repo documents it. Ask the follow-up against the real
  endpoint names and fields, cite them in the recorded decision, and
  record what the lookup settled as a `### D<n>` derived entry
  rather than asking the user to recite a contract that is already
  written down. When the search returns several repos on one
  contract, that is an edge the registry cannot settle: confirm it
  here, in the interview, per core.md's Edge confirmation, and
  record the answer as the `### D<n>` entry Phase D writes into the
  chapter's `to` or `from`. Lookup misses, config `off`, or no CLI →
  interview exactly as before. Protocol text, never a harness hook.
- **Question order:** walk `../interview.md` top to bottom: Framing
  (§0), then the one-way-door shape decisions (§1, with 2-3 candidates
  for macro-structure), then the topic-mapped checklists (§2), quality
  attributes with response measures (§3), the conditional modules that
  apply (§4), and the wrap-up sweep + red-flag screen (§5-6) before the
  gate. One module is out of order by design: §4's Frontend/clients
  module is walked with §2's → architecture.md checklist, as that
  checklist says, and is skipped when §4 is reached.
- **Maintain the ledger with appends and toggles, never whole-file
  rewrites.** Per turn: append the new `### Q<n>` entries (end-anchored
  edit or shell append), and flip one `- [ ]` to `- [x]` when a section
  or sub-item completes, the parent with its last sub-item. §4 gains
  its first sub-item, already ticked, when the Frontend/clients module
  is walked during §2. On a harness without partial-file edits, rewrite
  only when a box flips, not every turn. The interview ends when every
  box is checked after a full topics × sections sweep.

## Phase C - formalization gate

When every box is checked, set `status: awaiting-formalization`, present
the complete decision summary organized by topic (including the agreed
walking-skeleton slice, the deferred-decisions list with their triggers,
the risk/assumption log, any red-flag screen hits the user accepted,
and every open thread `for: logic`) and ask the user to formalize it.
The gate is a message question per core.md's Structured questions:
the summary is the chat message, its last line asks the user to
formalize or amend, and the turn ends there. Amendments update the
interview file and re-run the sweep. Do not generate anything until
the user explicitly formalizes.

## Phase D - generation

On the user's approval, write the full reference (the index plus every
applicable topic file) exactly as a normal `map` run would,
with
these differences:

- Frontmatter gains `mode: prescriptive`; stamps are date-only unless a
  git repo already exists.
- Decisions and their rationale are written directly into the owning
  chapter. Citations point only at other final outputs and planned
  paths from the decided layout, since no code exists.
- Conventions answers land in `03-conventions.md` and dependency
  picks in `05-dependencies.md` as provisional, each marked in the
  text: "provisional: `standards` owns this" and
  "provisional: `stack` owns this". Those stages confirm and rewrite
  them.
- `paths_covered` uses the planned layout's globs.
- A banner on each file: "Prescriptive design intent; code does not
  exist yet."
- `09-interfaces.md` is applicable when the design declares any
  cross-repo edge (and config `interfaces` is `auto`): the
  frontmatter `edges:` block per `../topics.md`, `site` naming a
  planned path from the decided layout with no line number, `schema`
  naming the entity `02-models.md` declares for that payload, and the
  Produces/Consumes tables rendered from the block. Contract fields
  come from the interview's quarry lookups where they ran. This is
  the one stage that writes `to` and `from` as it writes the rows,
  because the interview settled each one with the user (the Edge
  confirmation bullet above); a `map` run over the same chapter later
  leaves them exactly as they are. Writing the chapter here is what
  lets `groom` and `plan` consult quarry from day
  one, and gives `map` a declared design to check the observed edges
  against once code exists.

Append the changelog entry per core.md's ledger: key
`architecture/all@Q<n>`, `<n>` the highest `### Q<n>`/`### D<n>` in
`architecture-interview.md`; record the chapters written and that they
carry `mode: prescriptive`, the one-way-door choices with the
alternatives rejected, the walking-skeleton slice, the deferred
decisions with their triggers, the open threads `for: logic`, and the
topics recorded not-applicable with their reasons. A later `map`
refresh of these chapters is a `map` run and records itself under a
`map/` changelog key, never as an architecture entry.

Only after every output is on disk, set `status: formalized` (per
core.md's Interview lifecycle, never before generation). Outputs on
disk, the `architecture/all` key present and
`status: awaiting-formalization` is a finished stage whose marker was
not written: set `status: formalized`, never re-gate.

**Lifecycle:** once code exists, `map`'s refresh protocol
treats every `mode: prescriptive` file as stale by definition: it
rewrites them descriptively and records designed-vs-implemented
divergences as facts ("designed as X; implemented as Y
(`file:line`)"), preserving the design rationale inline and
describing, not judging.
