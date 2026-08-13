# review — opt-in judgment (the one exception to "describe, never judge")

**Reads:** config → `<index_file>` → every current topic chapter
(after the refresh) → `code-prefs.md`, `../code-craft.md`,
`../design-craft.md` (the judgment bars) → source spot-checks where
evidence needs exact lines.

1. Ensure the reference is current (run the refresh path first if stale) —
   judgments must rest on verified facts. Before overwriting an existing
   `review.md`, read its stamp: if no changelog entry carries it, append
   that catch-up entry first — the rewrite destroys the only other
   evidence the earlier run happened.
2. Review across these dimensions, drawing evidence from the topic files
   and spot-checking source: boundary integrity (violations of the
   project's own layering), dead or unwired code, typing erosion
   (escape-hatch concentrations, protocol bypasses), failure-path risk
   (partial-failure consequences, swallowed errors), test-coverage gaps
   weighted by criticality, internal consistency (the project violating
   its own stated conventions), craft divergence (unearned abstractions
   and unclimbed ladder rungs per `../code-craft.md`; for UI surfaces,
   drift from `design/`'s commitments and `../design-craft.md`'s
   floor), and — when
   `docs/capstone/code-prefs.md` exists — divergence between the user's
   stated preferences and the observed conventions.
3. Write `docs/capstone/review.md`: frontmatter stamps; a banner line
   "Opinion — generated judgment, not part of the factual reference.";
   findings ranked by severity, each with: the claim, evidence
   (`file:line`), why it matters, and a suggested direction (one
   sentence — no implementation plans).
4. Append the changelog entry per core.md's ledger — key
   `review/all@<stamp>` (`#2`, `#3` … for further reviews at the same
   stamp, each a real event). Facts about the run only: the file written
   or replaced, its stamp, the finding count and the count per severity
   band, and the dimensions exercised. The opinions stay in `review.md`.
5. Never edit code. Each rerun replaces the file. List it only under
   DESIGN.md's Companion docs table, never in the topic index.
