# logic — scenario-by-scenario business-logic interview

Sits between `mockup` and `architecture`: takes every scenario the product
has and lays its business logic bare — one scenario at a time, depth
first, until a developer could implement it without inventing a single
rule. Like `code-prefs`, the output is normative but records only the
user's own stated decisions.

Interview state: `docs/capstone/logic-interview.md` (same resumable
format; never indexed). Output: `docs/capstone/logic/` — one chapterized
file per scenario (`01-<scenario>.md`, `02-…`), the folder indexed under
Companion docs.

## Phase A — setup / resume

Resume from the interview file if present. Build the scenario list:
from `docs/capstone/mockup/README.md` and `mockup-interview.md` if they
exist (each journey/screen flow is a candidate scenario — confirm the
list with the user); otherwise elicit it ("walk me through everything a
user can do, headline by headline"). Order by importance and record the
agreed list as a checklist in the interview frontmatter, per core.md's
Interview lifecycle:

```yaml
scenarios:
  - {name: checkout, status: pending}   # pending | written | dropped
```

## Phase B — one scenario at a time, depth first

Finish a scenario completely before touching the next. The generation
rule: **"if I had to implement this scenario right now, what rule would
I have to invent?"** — the next question is whatever tops that list.
One question per turn; concrete options when enumerable; per the
expertise level in config.

Per scenario, cover until nothing is left to invent:

- **Trigger & preconditions** — who starts it, from where, in what
  state; what must already be true.
- **Steps** — the happy path, numbered, each step's exact rule: what is
  checked, what is computed (formulas, limits, rounding — exact
  numbers), what is read/written, who is allowed.
- **Branches** — every decision point and the rule that decides it.
- **Unhappy paths** — for each step: what if it fails, is invalid,
  happens twice, happens late, happens concurrently, is cancelled
  midway? Expected behavior for each, including what the user sees.
- **State transitions** — which entity lifecycle states this scenario
  moves, and which transitions are forbidden.
- **Invariants** — what must never be true afterwards, no matter what.
- **Outcomes & side effects** — success and failure endings;
  notifications, records, money moved.

When a scenario has nothing left to invent, present its summary, get
the user's confirmation ("laid bare?"), then write
`docs/capstone/logic/<NN>-<scenario>.md` immediately — sections exactly
as the bullets above, every rule traceable to its `§Q` entry — append
that scenario's changelog entry per core.md's ledger (key
`logic/<NN>-<scenario>@Q<n>`, `<n>` the highest `§Q` the scenario file
cites), flip that scenario's checklist entry to `written`, and move to
the next.
The user may stop at any point; written scenarios stand, the remaining
list stays `pending` in the frontmatter. A scenario the user decides
not to spec is marked `dropped`, with the reason in a `### D<n>` entry —
a drop is a done marker too, so it gets its own changelog entry naming
the scenario and that reason.

## Phase C — wrap

When every listed scenario is `written` or `dropped`, update the index
per core.md (one Companion docs row for `logic/`), set
`status: formalized` in the interview file (only now — per core.md's
Interview lifecycle), and note any cross-scenario contradictions
discovered — surface them as questions, not verdicts. If the user stops
earlier, leave status as `interviewing`; the pipeline treats pending
scenarios as in-progress.

**Consumers:** `design` reads `docs/capstone/logic/` to style each
screen's states and unhappy paths. `architecture` reads
`docs/capstone/logic/` to pre-fill models
(entities, invariants, consistency needs), data-flow (lifecycles), and
quality-attribute scenarios — never re-asking what a scenario file
answers.
