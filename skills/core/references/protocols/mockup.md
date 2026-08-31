# mockup - adaptive product-discovery interview, then the full mockup

**Reads:** config → `mockup-interview.md` (resume) → the existing
`mockup/` outputs when re-entering. Everything else comes from the
user.

Upstream of `architecture`: defines the product (purpose, business plan, usage
scenarios) before any architecture exists. Philosophy is the opposite of
`architecture`'s checklist-driven interview: only the seed questions are
predetermined; every question after them must be **generated from the
answers**.

## The generation rule

After each answer, ask yourself: "If I had to build the full mockup
right now, what would I have to invent?" The next question is whatever
tops that list. The interview is complete when the user says stop, or
when nothing remains that would change the mockup.

**Where it stops.** The mockup depicts; it does not decide - the
general form is core.md's Stage ownership table. When the next
question's answer would be a **rule** - a threshold, a formula, a
branch condition, who wins a conflict, what happens when something
fails - it is not this stage's to ask. Name the behavior, record the
question as an open thread addressed to `logic`, and move on. What
this stage settles is what the user sees, what they can act on, and
where that leads. A number nobody stated is never the answer to a
mockup question: `logic` asks it with the rigor it needs, and a guess
recorded here outranks nothing and contradicts everything.

The one exception is the **commercial model** (tiers, prices, grants,
the rate and runway equations): the business-plan angle settles it
here, and every later stage references those files rather than
restating them.

## Phase A - setup / resume

State lives in `docs/capstone/mockup-interview.md`, same resumable format
as `architecture`'s interview file (status frontmatter per core.md's
Interview lifecycle, numbered `### Q<n>` entries with question, answer
as given, and normalized decision, plus an `## Open threads` ledger:
seed it once with the angle areas (purpose, business plan, journeys,
behaviors), then maintain it with appends and checkbox toggles, never
whole-file rewrites; a question the generation rule's stop hands to
`logic` is logged here as an open thread marked `for: logic`, never
answered). Append each entry before asking the next
question. Resume = read the file, never re-ask. An artifact argument
(a PRD, notes, screenshots) seeds the interview per core.md's
Artifact seeding rule.

## Phase B - the seeds (the only predetermined questions)

1. "Describe the project as you would to a friend: what is it, and why
   should it exist?"
2. "Who exactly is it for, and what do they do today instead?"
3. "A year after launch, what does success look like, in numbers if you
   can?"

As soon as the answers imply it (asking directly if still unclear
after the seeds), record the product's interaction surfaces in the
interview frontmatter: `surfaces: [web|mobile|cli|api|none]`, any
combination. `uiux` keys on it (no visual surface → that stage
records itself skipped), and for non-visual surfaces Phase E's
"screens" are the surface's units (endpoints, commands, message
flows): same files, same sections, the wireframe replaced by the
interaction transcript it depicts.

## Phase C - generated questions

One per turn, each derived from prior answers via the generation rule.
Angles to mine (a compass, not a checklist):

- **Purpose**: the problem, why now, non-goals, what it must never become.
- **Business plan**: who pays and how much; pricing model; market size
  and reachable slice; competition and the differentiator; acquisition
  channel; unit economics; run costs; regulatory exposure; biggest risk.
- **Journeys**: personas; the core journeys named and sequenced as
  paths through screens ("where do they land, what do they reach for,
  where does that take them?"); the first-run experience; frequency of
  use; a day-in-the-life. Walk a journey until its *screens* are
  known, not until its rules are: "then what happens?" is asked of the
  interface, and the moment the honest answer is a rule, the stop
  above applies.
- **Behaviors**: what the product must decide on its own, named but
  never settled here - resolution and authority, money and metering,
  lifecycle and recovery, membership and permission, whatever else
  this domain adds. These become Phase E's scenario inventory and
  `logic`'s question list; here they are only found, named, and
  attached to the screens they surface on.
- **Probes**: vague words → numbers **the user already knows** (price,
  audience, scale, deadline), never numbers they would invent to
  satisfy the question; contradictions between answers;
  superlatives ("simple", "seamless") → what specifically; unstated
  assumptions said back for confirmation.

Drill each answer until concrete before moving on. The user may stop at
any time; jump to Phase D and record remaining vagueness honestly.

## Phase D - the gate

Set `status: awaiting-formalization`; present the summary organized as
purpose / business plan / journeys / behaviors, plus what is still
vague and, separately, the open threads marked `for: logic` - named so
the user can see what the next stage will settle rather than mistaking
it for something forgotten. The user formalizes or amends; do not
generate until they do.

## Phase E - the mockup

On formalization, write `docs/capstone/mockup/` as **chapterized
markdown, no HTML anywhere**. One file per screen the scenarios imply,
numbered in journey order (`01-<screen>.md`, `02-<screen>.md`, …), each
with frontmatter naming the scenario(s) it serves and the `§Q` entries
it implements, and these sections:

- `## Layout`: an ASCII wireframe in a fenced code block plus a short
  element tree (what contains what).
- `## Elements`: every interactive element: its label, what it does,
  where it leads. The label is the working copy a wireframe cannot do
  without; register, tone, and final wording are `uiux`'s, which
  ratifies or replaces it.
- `## States`: **an inventory, not a specification.** One line per
  state the journeys imply (empty, loading, error, success, and every
  named condition this screen has): what the user sees in it, and the
  trigger *named* - never quantified, and never a decision about what
  the product does or says. "Low credits: the DM steers toward a
  stopping beat; what triggers it and whether anything is surfaced is
  `logic`'s." A state whose rule is not settled carries
  `rule: logic` inline, which is what `uiux` and `logic` both key on;
  the state is not thereby vague, it is correctly unfinished.

Every element and state must trace to an interview answer; anything
invented is marked "assumed" inline **and** listed in the screen's
`assumed:` frontmatter - states included, since an invented trigger
reads as settled fact to every stage downstream. A section is never
filled to look complete: `rule: logic` is the honest entry, an
invented threshold is a defect.

The folder's **only index is `README.md`**, carrying three tables:

- **Screens** → the journeys served → the `§Q` entries implemented.
- **Journeys**: each journey as its path through the screens
  (`01 → 02 → 05`). Mockup's own unit, and what `uiux` and `build`
  order their work by.
- **Scenarios for `logic`**: the behavior inventory from Phase C, one
  row each - the behavior named, the screens it surfaces on, and the
  open threads it must settle. This table is `logic`'s question list,
  so it is written at `logic`'s unit: a thing the product decides
  ("credit metering and exhaustion", "who resolves a contested
  action"), never a route through screens. **The completeness test:**
  every state and element marked `rule: logic` anywhere in the folder
  is claimed by exactly one row. An unclaimed one means the inventory
  is not finished.

All "assumed" items are collected in the README too, for the user to
review. Only after every screen file and the README are on disk,
append the changelog entry per core.md's ledger: key
`mockup/all@Q<n>`, `<n>` the highest `### Q<n>` in
`mockup-interview.md`; record the screens written with the journeys
they serve, the purpose and business-model decisions, the scenario
inventory handed to `logic`, and the vagueness the gate left open.
Then set `status: formalized` in the interview file (per core.md's
Interview lifecycle).

**Handoff:** (when running inside the `start` pipeline, it continues
automatically) the natural next step is the `logic` skill: it takes
the README's Scenarios table and settles each behavior's rules, one by
one, including every question this stage logged `for: logic`; `uiux`
then turns the screens into a committed frontend design, before any
architecture. Both stages outrank this one on anything they settle: a
`rule: logic` state is filled in by `logic`, and this folder is
regenerated rather than defended when the two disagree. `architecture` (run after these) reads
`mockup-interview.md` and never re-asks what it answers: its framing
section (§0 of `../interview.md`) is largely pre-filled by this
interview.
