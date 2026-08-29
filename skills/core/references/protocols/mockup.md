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

## Phase A - setup / resume

State lives in `docs/capstone/mockup-interview.md`, same resumable format
as `architecture`'s interview file (status frontmatter per core.md's
Interview lifecycle, numbered `### Q<n>` entries with question, answer
as given, and normalized decision, plus an `## Open threads` ledger:
seed it once with the three angle areas (purpose, business plan,
scenarios), then maintain it with appends and checkbox toggles, never
whole-file rewrites). Append each entry before asking the next
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
- **Scenarios**: personas; each core journey walked step by step ("then
  what happens?"); the first-run experience; unhappy paths and edge
  users; frequency of use; a day-in-the-life.
- **Probes**: vague words → numbers; contradictions between answers;
  superlatives ("simple", "seamless") → what specifically; unstated
  assumptions said back for confirmation.

Drill each answer until concrete before moving on. The user may stop at
any time; jump to Phase D and record remaining vagueness honestly.

## Phase D - the gate

Set `status: awaiting-formalization`; present the summary organized as
purpose / business plan / scenarios, plus what is still vague. The user
formalizes or amends; do not generate until they do.

## Phase E - the mockup

On formalization, write `docs/capstone/mockup/` as **chapterized
markdown, no HTML anywhere**. One file per screen the scenarios imply,
numbered in journey order (`01-<screen>.md`, `02-<screen>.md`, …), each
with frontmatter naming the scenario(s) it serves and the `§Q` entries
it implements, and these sections:

- `## Layout`: an ASCII wireframe in a fenced code block plus a short
  element tree (what contains what).
- `## Elements`: every interactive element: its exact label/copy, what
  it does, where it leads.
- `## States`: the variants the scenarios imply: empty, loading,
  error, success.

Every element must trace to an interview answer; anything invented is
marked "assumed" inline. The folder's **only index is `README.md`**: a
markdown table mapping screens → scenarios → interview entries, with
all "assumed" items collected there for the user to review. Only after
every screen file and the README are on disk, append the changelog entry
per core.md's ledger: key `mockup/all@Q<n>`, `<n>` the highest
`### Q<n>` in `mockup-interview.md`; record the screens written with the
scenarios they serve, the purpose and business-model decisions, and the
vagueness the gate left open. Then set `status: formalized`
in the interview file (per core.md's Interview lifecycle).

**Handoff:** (when running inside the `start` pipeline, it continues
automatically) the natural next step is the `logic` skill: it takes the
scenarios this mockup depicts and lays their business rules bare, one
by one; `uiux` then turns the screens into a committed frontend
design, before any architecture. `architecture` (run after these) reads
`mockup-interview.md` and never re-asks what it answers: its framing
section (§0 of `../interview.md`) is largely pre-filled by this
interview.
