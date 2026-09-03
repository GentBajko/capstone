# review [backend|frontend] - opt-in judgment

**Reads:** config → `<index_file>` → the existing `review.md` (its
per-side stamps, before overwriting either side). Then per side.
**Backend:** every current topic chapter (after the refresh) →
`standards.md`, `../code-craft.md`, `../arch-craft.md` (the method
and its rulings) → source spot-checks where evidence
needs exact lines. **Frontend:** `docs/capstone/uiux/` (the
committed bar) → `mockup/` and `logic/` (what each screen must do) →
`../uiux-craft.md` (§7-8) → the frontend source via the chapters →
`07-operations.md` (the verified run commands) and the live app when
the harness can drive a browser.

The plugin's **only** opinionated output (core.md hard rule 1), and
only because the user invoked it. Never edits code.

## Sides

Bare `review` runs **both** sides, backend first. An argument runs one:

- `backend` (also `be`): architecture and backend judgment.
- `frontend` (also `fe`): UI judgment against the project's own
  design docs.

A one-sided run **rewrites only its own section** of `review.md` and
leaves the other side's section and stamp untouched. A project with no
frontend (the mockup records no visual surface, or there is no
`uiux/` and no client code) skips the frontend side on a bare run,
saying so, and records the section as not applicable.

## Method

The vendored craft files are the method, in full and on both sides:
`../arch-craft.md` for backend (vocabulary, the deletion test,
dependency categories, the smell baseline, the hot-spot walk) and
`../uiux-craft.md` for frontend (§7's refuse list and rulings, §8's
build-time checklist, and the Grading bars below). No installed skill
substitutes for either, so the same codebase is judged the same way on
any machine.

**One rule outranks both files:** the project's own recorded decisions
beat generic best practice. A divergence from the craft baseline is a
finding only when the final reference and standards don't already justify
the choice: show both and let the user rule. `arch-craft.md` §5 states
the same thing from the backend side, along with the rule to skip what
tooling already enforces.

**Capabilities, not method.** Three things the harness may or may not
have change what this command can *do*, never how it judges:

- **A live browser**: run the app per `07-operations.md`'s verified
  command and screenshot each surface in every shipped theme at
  desktop and mobile widths. Absent, judge from source and say so.
- **A security-review command or skill**: run it and fold its findings
  into the backend section with their evidence, ranked alongside the
  rest. Absent, spot-check the security dimension directly against the
  trust boundaries the chapters name.
- **A diff-review command**: when the user's concern is recent changes
  rather than the whole codebase, its output folds in the same way.

None of these decide severity or override a recorded decision; they
supply evidence the ranking then treats like any other.

## Procedure

1. **Ensure the ground is solid**, per side.
   Backend: the reference must be current (run the refresh path first
   if stale; no index at all → core.md's Missing reference rule builds
   one before this run continues): judgments must rest on verified
   facts. Frontend: without `docs/capstone/uiux/`, say so (findings
   then rest on the craft floor alone) and suggest `uiux`'s
   extraction mode first, so there is an incumbent standard to hold
   the code to. Never block on it.
2. **Preserve the evidence you are about to overwrite.** Before
   rewriting a side's section, read that side's stamp: if no changelog
   entry carries it, append the catch-up entry first; the rewrite
   destroys the only other evidence the earlier run happened.
3. **Backend side**: review across these dimensions, drawing evidence
   from the topic files and spot-checking source: boundary integrity
   (violations of the project's own layering), dead or unwired code,
   typing erosion (escape-hatch concentrations, protocol bypasses),
   failure-path risk (partial-failure consequences, swallowed errors),
   test-coverage gaps weighted by criticality, shallow-module drag
   (interfaces nearly as complex as their implementations, judged by
   the deletion test: would deleting it concentrate complexity, or
   just move it?), recurring change-smells in the hot paths (the same
   logic shape duplicated, one change fanning out across many files,
   primitives standing in for domain concepts, speculative
   generality), internal consistency (the project violating its own
   stated conventions), security posture (trust-boundary validation,
   secret handling, authz on every mutating path, injection surfaces;
   via the installed security skill when present, else spot-checked
   directly), stack currency (dependencies and patterns against the
   dependencies chapter's own recorded floors and research dates),
   craft divergence (unearned abstractions and unclimbed ladder rungs
   per `../code-craft.md`), and, when `docs/capstone/standards.md`
   exists, divergence between the user's stated preferences and the
   observed conventions.
4. **Frontend side**: inventory the surfaces from `uiux/screens/`
   (or the mockup, or the route table when neither exists). When
   `07-operations.md` carries a verified run command and the harness
   can drive a browser, run the app and screenshot the key screens in
   each shipped theme at desktop and mobile widths; otherwise judge
   from source, saying so. Judge every surface through the three bars
   (Grading, below), drawing evidence from source (`file:line`) and
   screenshots.
5. **Write `docs/capstone/review.md`** in the shape below.
6. **Append the changelog entry** per core.md's ledger: key
   `review/<side>@<stamp>`, `<side>` being `backend`, `frontend`, or
   `all` for a bare run covering both (`#2`, `#3` … for further
   reviews at the same stamp, each a real event). Facts about the run
   only: the sections written or replaced, their stamps, the finding
   count per severity band per side, the backend dimensions exercised,
   the frontend surfaces exercised, and whether the run had a live
   browser. The opinions stay in `review.md`.
7. Never edit code. List `review.md` only under the index's Companion
   docs table, never in the topic index. It is local-only
   (core-authoring.md's ignore list), so it is never committed.

## The output: one file, two sections

`docs/capstone/review.md`, frontmatter stamps, then the banner line
"Opinion: generated judgment, not part of the factual reference."

**Each side carries its own stamp line**, directly under its heading,
because a one-sided run leaves the other side untouched and a reader
must be able to tell how old each half is:

```markdown
## Backend

_Reviewed <date> at <commit> · dimensions: <the ones exercised>_

### Critical
### Important
### Minor

## Frontend

_Reviewed <date> at <commit> · surfaces: <N> · live browser: yes|no_

### Critical
### Important
### Minor
```

A side never run yet, or not applicable, keeps its heading with one
line saying so and why: an absent section reads like an oversight,
whereas "not run" and "no visual surface" are facts.

On a bare run, open with a `## Summary`: one line per side giving the
counts per severity band, so the two halves can be weighed against
each other without scrolling. A one-sided run refreshes only its own
line there.

Every finding, either side: the claim, evidence (`file:line`, plus a
screenshot reference where one exists), why it matters, and a
suggested direction in one sentence, no implementation plans. Close
the file by noting that any accepted finding can enter the feature
chain (`implementation <finding>`) to become a gated, traceable
change.

**Legacy files:** older versions wrote `be-review.md` and
`fe-review.md`. Both present or either → carry nothing over (a review
is regenerated wholesale, never merged), write `review.md`, say the
old files are superseded, and offer to delete them. They are
gitignored and regenerable, so deleting is safe, but it is the user's
call.

## Grading - the frontend's three bars, in confidence order

1. **The project's own commitments**: drift from `02-system.md`'s
   locks (accent, radius, type scale, icon family, motion rules),
   from `03-experience.md`'s interaction rules (confirmation and undo
   policy, feedback thresholds, error recovery, input burden, the
   accessibility floor), and from each screen's `uiux/screens/`
   chapter. Highest confidence:
   the user already decided this standard; the critique only holds
   the code to it. Cite the commitment beside the violation.
2. **The craft floor**: violations of the refuse list and the
   build-time checklist (uiux-craft §7-8, or the installed skill's
   own floor). State which rule.
3. **Mode-appropriateness**: each surface judged by its mode from
   `01-direction.md`'s mode map: Operate on scanability, consistency,
   and state completeness; Persuade on hierarchy and conversion; Read
   on comprehension; Experience on the artifact leading. A missing
   mode map falls back to inferring the mode per surface, recorded as
   assumed.

Severity ranks by user harm, not rule count; a finding that appears on
several screens is one finding with a site list. Never restate bar-1
drift as a bar-2 or bar-3 finding: one claim, its strongest bar.

**Between the sides:** UI drift is a frontend finding and backend
craft divergence is a backend one; never report the same claim in both
sections. A finding that genuinely spans both (an API shape forcing a
bad interaction) goes in the section that owns the fix, and names the
other side.
