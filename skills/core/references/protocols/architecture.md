# architecture - interview-driven design for a greenfield project

**Reads:** config → `architecture-interview.md` (resume) →
`../interview.md` in full before the first question → upstream
artifacts if present: `code-prefs.md`, `logic/`,
`mockup-interview.md`, `mockup/README.md` (screens as questions touch
them) → `../topics.md` at generation.

Design-time mode: there is no code to describe, so the reference is
built from an exhaustive interview instead. Three strict phases with a
user gate between the last two.

**The exhaustiveness criterion is twofold.** The interview is complete
only when (a) every applicable item in `../interview.md`, the merged
question inventory, has been asked, answered, or recorded as
not-applicable, AND (b) every required section of every applicable topic
in `../topics.md` can be written from recorded answers. Both are
checkable conditions: sweep them and ask about whatever is not yet
answerable. Never assume: any default you want to apply must be surfaced
as a question or an explicitly-confirmed default, not silently adopted.
Read `../interview.md` in full before asking the first question; its
Conduct rules section governs the whole interview. Then check for
upstream artifacts, each read only if it exists:
`docs/capstone/code-prefs.md`, `docs/capstone/logic/` (the business-logic
scenario files; they pre-fill models: entities, invariants,
consistency needs; data-flow: lifecycles; and quality-attribute
scenarios), `docs/capstone/mockup-interview.md`, and the mockup itself
(`docs/capstone/mockup/README.md`, plus individual screens when a
question touches the flows they depict). Record everything they answer
as derived decisions; never re-ask it.

## Phase A - setup / resume

The interview state lives in `docs/capstone/architecture-interview.md`.
If it exists, read it and resume; never re-ask an answered question.
An artifact argument (an RFC, an ADR set, notes) seeds the interview
per core-authoring.md's Artifact seeding rule.
If not, create it, **seeding `## Open questions` once** as a
section-granularity checkbox ledger (about 20 lines, one box per
`../interview.md` section, not per question):

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
- [ ] §1 Shape decisions
- [ ] §2 Topic checklists
- [ ] §3 Quality attributes
- [ ] §4 Conditional modules
- [ ] §5-6 Wrap-up + red-flag screen
(split a section into sub-items only when partially done)
```

## Phase B - the interview loop

- **One question per turn.** Offer concrete options when the choice
  space is enumerable; open-ended otherwise. Ask follow-ups spawned by
  answers before moving to the next area.
- **Record immediately.** After each answer, append an entry before
  asking the next question; the file must survive a dead session:

  ```markdown
  ### Q<n> - <topic>/<section> (<date>)
  **Q:** <question as asked>
  **A:** <answer as given>
  **Decision:** <the normalized decision this implies>
  ```

  Decisions derivable from earlier answers are recorded as
  `### D<n> - derived` entries with the reasoning, not re-asked, but
  state them to the user as you go so wrong derivations get caught.
- **Question order:** walk `../interview.md` top to bottom: Framing
  (§0), then the one-way-door shape decisions (§1, with 2-3 candidates
  for macro-structure), then the topic-mapped checklists (§2), quality
  attributes with response measures (§3), the conditional modules that
  apply (§4), and the wrap-up sweep + red-flag screen (§5-6) before the
  gate.
- **Maintain the ledger with appends and toggles, never whole-file
  rewrites.** Per turn: append the new `### Q<n>` entry (end-anchored
  edit or shell append), and flip one `- [ ]` to `- [x]` when a section
  completes. On a harness without partial-file edits, rewrite only when
  a box flips, not every turn. The interview ends when every box is
  checked after a full topics × sections sweep.

## Phase C - formalization gate

When every box is checked, set `status: awaiting-formalization`, present
the complete decision summary organized by topic (including the agreed
walking-skeleton slice, the deferred-decisions list with their triggers,
the risk/assumption log, and any red-flag screen hits the user accepted)
and ask the user to formalize it. Amendments update the interview file
and re-run the sweep. Do not generate anything until the user explicitly
formalizes.

## Phase D - generation

On the user's approval, write the full reference (the index plus every
applicable topic file) exactly as a normal `map` run would,
with
these differences:

- Frontmatter gains `mode: prescriptive`; stamps are date-only unless a
  git repo already exists.
- Citations point at interview entries
  (`architecture-interview.md §Q12`) and at planned paths from the
  decided layout, since no code exists.
- `paths_covered` uses the planned layout's globs.
- A banner on each file: "Prescriptive: written from the design
  interview, not from code."

Append the changelog entry per core.md's ledger: key
`architecture/all@Q<n>`, `<n>` the highest `### Q<n>`/`### D<n>` in
`architecture-interview.md`; record the chapters written and that they
carry `mode: prescriptive`, the one-way-door choices with the
alternatives rejected, the walking-skeleton slice, the deferred
decisions with their triggers, and the topics recorded not-applicable
with their reasons. A later `map` refresh of these chapters is a
`map` run and records itself under a `map/` changelog key, never as
an architecture entry.

Only after every output is on disk, set `status: formalized` (per
core.md's Interview lifecycle, never before generation).

**Lifecycle:** once code exists, `map`'s refresh protocol
treats every `mode: prescriptive` file as stale by definition: it
rewrites them descriptively and records designed-vs-implemented
divergences as facts ("designed as X (architecture-interview.md §Q7),
implemented as Y (`file:line`)"), describing, not judging.
