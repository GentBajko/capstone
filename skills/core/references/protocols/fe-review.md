# fe-review — opt-in UI judgment (be-review's frontend sibling)

**Reads:** config → `docs/capstone/design/` (the committed bar) →
`mockup/` and `logic/` (what each screen must do) → the frontend
source via the chapters → `guides/run-locally.md` and the live app
when the harness can drive a browser → the existing `fe-review.md`
stamp before overwriting.

With `be-review`, one of the two opinionated outputs (core.md hard
rule 1) — and only because the user invoked it. Suggests UI
improvements, ranked; never edits code.

## Method sources

Detected fresh every session from the skill list, never cached;
referenced by flow name, never file path:

- **`impeccable` installed** — run its `critique` flow (UX review
  with heuristic scoring) as the method; offer its `audit` when the
  user wants the technical layer (a11y, perf, responsive). Its
  browser machinery applies when the harness has one.
- **`design-taste-frontend` installed** — its pre-flight checklist
  audits the Persuade, Read, and Experience surfaces (its declared
  scope).
- **Neither** — `../design-craft.md` §7–8 is the checklist; the
  scoring method is this protocol's Grading section.
- Always: §7's rulings bind whichever source is active.
- A named skill missing on an interactive run → offer its install
  per core.md's Delegation installs before taking the fallback.

## Procedure

1. Ensure the bar exists: without `docs/capstone/design/`, say so —
   findings then rest on the craft floor alone — and suggest
   `design`'s extraction mode first, so there is an incumbent
   standard to hold the code to. Never block on it.
2. Inventory the surfaces from `design/screens/` (or the mockup, or
   the route table when neither exists). When
   `guides/run-locally.md` exists and the harness can drive a
   browser, run the app and screenshot the key screens in each
   shipped theme at desktop and mobile widths; otherwise judge from
   source, saying so.
3. Judge every surface through the three bars (Grading, below),
   drawing evidence from source (`file:line`) and screenshots.
4. Write `docs/capstone/fe-review.md`: frontmatter stamps; the banner
   "Opinion — generated judgment, not part of the factual
   reference."; findings ranked by severity, each with the claim,
   evidence, why it matters, and a suggested direction (one
   sentence — no implementation plans). Close by noting that any
   accepted finding can enter the feature chain
   (`implementation <finding>`) to become a gated, traceable change.
5. Append the changelog entry per core.md's ledger — key
   `fe-review/all@<stamp>` (`#2`, `#3` … for reruns at the same
   stamp). Facts only: the file written or replaced, its stamp, the
   finding counts per severity band, the surfaces exercised, and
   whether the run had a live browser. The opinions stay in
   `fe-review.md`. Before overwriting an earlier `fe-review.md`, read
   its stamp and append the catch-up entry if none carries it.
6. Each rerun replaces the file. List it only under DESIGN.md's
   Companion docs table; it is local-only (core.md's ignore list),
   like `review.md`.

## Grading — the three bars, in confidence order

1. **The project's own commitments** — drift from `02-system.md`'s
   locks (accent, radius, type scale, icon family, motion rules) and
   from each screen's `design/screens/` chapter. Highest confidence:
   the user already decided this standard; the critique only holds
   the code to it. Cite the commitment beside the violation.
2. **The craft floor** — violations of the refuse list and the
   build-time checklist (design-craft §7–8, or the installed skill's
   own floor). State which rule.
3. **Mode-appropriateness** — each surface judged by its mode from
   `01-direction.md`'s mode map: Operate on scanability,
   consistency, and state completeness; Persuade on hierarchy and
   conversion; Read on comprehension; Experience on the artifact
   leading. A missing mode map falls back to inferring the mode per
   surface, recorded as assumed.

Severity ranks by user harm, not rule count; a finding that appears
on several screens is one finding with a site list. Never restate
bar-1 drift as a bar-2 or bar-3 finding — one claim, its strongest
bar.
