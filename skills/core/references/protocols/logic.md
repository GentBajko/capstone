# logic - scenario-by-scenario business-logic interview

**Reads:** config → `logic-interview.md` (resume) →
`../logic-craft.md` (the method, in full, before the first scenario) →
`mockup/README.md`'s Scenarios table and `for: logic` open threads
(the question list) →
the existing `logic/` files when re-entering → in extraction
mode: the data-flow, models, and architecture chapters, then source
where cited.

Sits between `mockup` and `architecture`: takes every scenario the
product has and lays its business logic bare, one scenario at a time,
depth first, until a developer could implement it without inventing a
single rule. Like `standards`, the output is normative but records
only the user's own stated decisions.

Interview state: `docs/capstone/logic-interview.md` (same resumable
format; never indexed). Output: `docs/capstone/logic/`, one
chapterized file per scenario (`01-<scenario>.md`, `02-...`), the
folder indexed under the topic index (core-authoring.md's Index maintenance
rule): one row per scenario file, `Topic` reading `logic`.

## Phase A - setup / resume

Resume from the interview file when it is unfinished. When it is
formalized, read the final `logic/` files instead and open the interview
body only to repair a proven omission. An artifact argument seeds the
interview per core-authoring.md's Artifact seeding rule. Build the
scenario list: from `docs/capstone/mockup/README.md`'s **Scenarios**
table if it exists - `mockup` wrote it at this stage's unit, one row
per behavior the product decides, so it is the list rather than a
source for one. Extend it where the screens moved on,
then check the mockup's cardinality rule in both directions before
confirming anything: a `rule: logic` marker no row claims gets a
scenario, and a marker two rows both claim to decide gets its owner
named, the others left referencing it. Carry every open thread the
mockup README marked `for: logic` into the scenario that owns it:
those are questions the user was deliberately not asked yet, and they
are answered here or nowhere. Then confirm the list with the user.

An older mockup with no Scenarios table (or none at all) falls back to
eliciting the list ("walk me through everything a user can do,
headline by headline"). Order by importance and record the agreed list
as a checklist in the interview frontmatter, per core.md's Interview
lifecycle:

```yaml
scenarios:
  - {name: checkout, status: pending}   # pending | written | dropped
```

**Extraction mode (brownfield):** when there is no mockup but the
repo has code and a stamped reference, offer to extract instead of
elicit. The goal is the same map the interview would have produced,
with the code answering instead of the user:

- **Scenario discovery is an entry-point inventory, not a skim.**
  Enumerate every externally triggerable behavior from the chapters
  (`04-data-flow.md`, `02-models.md`, `01-architecture.md`; source
  only where a chapter labels its coverage shallow): routes and
  handlers, UI actions, jobs and crons, queue consumers, CLI
  commands, webhooks, lifecycle hooks. Every entry point must be
  claimed by exactly one scenario on the drafted list (a scenario may
  span several entry points); an unclaimed entry point means the list
  is not done. Confirm the drafted list with the user like any
  elicited list.
- **Per scenario, the file covers the full Phase B section list**
  (trigger and preconditions, steps with exact rules, branches,
  unhappy paths, state transitions, invariants, outcomes and side
  effects) from observed behavior, every rule cited `file:line`, and
  is swept against logic-craft's dimensions per its §5: each one the
  code either implements, cited `file:line`, or does not, and "not
  implemented" is recorded as the finding. An unhappy path the code
  does not handle is recorded as absent (style.md: absent things are
  facts too), never skipped.
- Present each draft; only the user's confirmation or correction
  makes it normative. Corrections are recorded as `### Q<n>` entries
  like any answer. Extraction outputs carry `paths_covered` (the
  globs the scenario's rules were read from), so `map` refreshes
  them as code moves; interview-derived files stay stamp-only and are
  absorbed by `implement` instead.

**Invoked by `map`** (its logic-coverage steps):
run extraction exactly as above, scoped to the missing scenarios,
with these differences: the files are written directly as descriptive
observations (hard rule 1; no per-scenario confirmation gate), the
scenario list is confirmed with the user only when the run is
interactive, no `logic-interview.md` is created (nothing was asked),
and the invoking protocol's changelog entry records the files instead
of per-scenario keys. A later standalone `logic` run confirms or
corrects those drafts and records the decisions as usual.

## Phase B - one scenario at a time, depth first

Finish a scenario completely before touching the next. The generation
rule: **"if I had to implement this scenario right now, what rule
would I have to invent?"**; the next question is whatever tops that
list. One question per turn; concrete options when enumerable; per
the expertise level in config.

**The generation rule orders; `../logic-craft.md` gates.** That rule
measures what you noticed, so a rule nobody thought to ask about reads
exactly like a rule that does not exist. Once the scenario's happy
path is known, run logic-craft §2's sweep against its sixteen
dimensions: generate each dimension's questions for this scenario,
delete the ones the mockup or an earlier scenario already answers,
batch the dimensions that do not apply into a single confirmation
rather than a question each, and ask what is left one per turn like
any other. D16 (invariants) runs last, against what the others
produced.

Per scenario, cover until nothing is left to invent:

- **Trigger & preconditions**: who starts it, from where, in what
  state; what must already be true.
- **Steps**: the happy path, numbered, each step's exact rule: what is
  checked, what is computed (formulas, limits, rounding, exact
  numbers), what is read/written, who is allowed.
- **Branches**: every decision point and the rule that decides it.
- **Unhappy paths**: for each step: what if it fails, is invalid,
  happens twice, happens late, happens concurrently, is cancelled
  midway? Expected behavior for each, including what the user sees.
- **State transitions**: which entity lifecycle states this scenario
  moves, and which transitions are forbidden.
- **Invariants**: what must never be true afterwards, no matter what.
- **Outcomes & side effects**: success and failure endings;
  notifications, records, money moved.

A scenario is finished when logic-craft §4's gate passes - every
dimension answered, cited to an earlier scenario, or recorded
inapplicable - not when nothing further comes to mind. A dimension the
user declines to settle is an open question, recorded as one, never an
inapplicable one.

Then present the summary, get the user's confirmation ("laid bare?"),
and write `docs/capstone/logic/<NN>-<scenario>.md` immediately:
sections exactly as the bullets above, with every confirmed rule and
its rationale written directly into the file and no interview-file or
question-number references, closing with `## Dimensions not in play` -
one line per dimension ruled out and why, per logic-craft §4, so a later reader can
tell "no money here" from "nobody asked". Append
that scenario's changelog entry per core.md's ledger (key
`logic/<NN>-<scenario>@Q<n>`, `<n>` the highest interview entry
incorporated into the scenario), flip that scenario's checklist entry
to `written`, and move
to the next. The user may stop at any point; written scenarios stand,
the remaining list stays `pending` in the frontmatter. A scenario the
user decides not to spec is marked `dropped`, with the reason in a
`### D<n>` entry; a drop is a done marker too, so it gets its own
changelog entry naming the scenario and that reason.

## Phase C - wrap

When every listed scenario is `written` or `dropped`, update the index
per core.md (one topic-index row per written scenario file and one
absence row naming each dropped scenario and its reason, all with
`Topic` reading `logic`), set
`status: formalized` in the interview file (only now, per core.md's
Interview lifecycle), and note any cross-scenario contradictions
discovered; surface them as questions, not verdicts. Report the
dimension coverage in one line - how many scenarios, how many
dimensions ruled inapplicable, and every dimension left open - so the
gaps `architecture` and `build` will meet are named before they get
there. If the user
stops earlier, leave status as `interviewing`; the pipeline treats
pending scenarios as in-progress.

**Consumers:** `uiux` reads `docs/capstone/logic/` to style each
screen's states and unhappy paths. `architecture` reads
`docs/capstone/logic/` to pre-fill models (entities, invariants,
consistency needs), data-flow (lifecycles), and quality-attribute
scenarios, never re-asking what a scenario file answers. `map` keeps
extraction-mode files current and extracts scenarios the map is
missing.
