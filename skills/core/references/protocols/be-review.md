# be-review — opt-in architecture and backend judgment

With `fe-review` (the UI sibling), one of the two opinionated outputs
(core.md hard rule 1) — and only because the user invoked it.

## Method sources

Detected fresh every session from the skill list, never cached;
referenced by flow name, never file path. Whatever the source, the
project's own recorded decisions outrank generic best practice: a
divergence from a delegated skill's opinion is a finding only when
the reference and interviews don't already justify the choice — show
both and let the user rule.

- **`improve-codebase-architecture` installed** (with its companion
  `codebase-design` vocabulary — the deep-module school) — its flow
  is the architecture dimension's method: hot spots from the git
  history, a friction walk, the deletion test on anything shallow,
  candidates ranked by recommendation strength, existing ADRs
  respected rather than re-litigated. Use its vocabulary exactly
  (module, interface, depth, seam, adapter, leverage, locality) and
  fold its candidates in as findings.
- **`security-review` installed** (or a harness security-review
  command) — run it as the security dimension's method; fold its
  findings into the ranked output with their evidence.
- **A diff-review skill installed** (`code-review` — two-axis
  standards-vs-spec with a smell baseline — or equivalent) — offer
  it when the user's concern is recent changes rather than the whole
  architecture; its findings fold in like the others.
- **A stack best-practices skill installed** (the user's own or a
  maintained one) — it may serve as the stack-currency bar when the
  user names it; never adopt one silently.
- A named skill missing on an interactive run → offer its install
  per core.md's Delegation installs before falling back.
- **None** — `../arch-craft.md` is the method (vocabulary, deletion
  test, dependency categories, smell baseline, the hot-spot walk);
  the dimensions below are its checklist. Its §5 rulings — recorded
  decisions override the baseline; skip what tooling enforces — bind
  whichever source is active.


**Reads:** config → `<index_file>` → every current topic chapter
(after the refresh) → `code-prefs.md`, `../code-craft.md`,
`../arch-craft.md` (the fallback method and always-on rulings) →
source spot-checks where evidence needs exact lines.

1. Ensure the reference is current (run the refresh path first if stale) —
   judgments must rest on verified facts. Before overwriting an existing
   `be-review.md`, read its stamp: if no changelog entry carries it, append
   that catch-up entry first — the rewrite destroys the only other
   evidence the earlier run happened.
2. Review across these dimensions, drawing evidence from the topic files
   and spot-checking source: boundary integrity (violations of the
   project's own layering), dead or unwired code, typing erosion
   (escape-hatch concentrations, protocol bypasses), failure-path risk
   (partial-failure consequences, swallowed errors), test-coverage gaps
   weighted by criticality, shallow-module drag (interfaces nearly as
   complex as their implementations, judged by the deletion test:
   would deleting it concentrate complexity, or just move it?),
   recurring change-smells in the hot paths (the same logic shape
   duplicated, one change fanning out across many files, primitives
   standing in for domain concepts, speculative generality),
   internal consistency (the project violating
   its own stated conventions), security posture (trust-boundary
   validation, secret handling, authz on every mutating path, injection
   surfaces — via the installed security skill when present, else
   spot-checked directly), stack currency (dependencies and patterns
   against the dependencies chapter's own recorded floors and
   research dates), craft divergence (unearned abstractions and
   unclimbed ladder rungs per `../code-craft.md` — UI drift belongs
   to `fe-review`, never report it here), and — when
   `docs/capstone/code-prefs.md` exists — divergence between the user's
   stated preferences and the observed conventions.
3. Write `docs/capstone/be-review.md`: frontmatter stamps; a banner line
   "Opinion — generated judgment, not part of the factual reference.";
   findings ranked by severity, each with: the claim, evidence
   (`file:line`), why it matters, and a suggested direction (one
   sentence — no implementation plans).
4. Append the changelog entry per core.md's ledger — key
   `be-review/all@<stamp>` (`#2`, `#3` … for further reviews at the same
   stamp, each a real event). Facts about the run only: the file written
   or replaced, its stamp, the finding count and the count per severity
   band, and the dimensions exercised. The opinions stay in
   `be-review.md`.
5. Never edit code. Each rerun replaces the file. List it only under
   DESIGN.md's Companion docs table, never in the topic index.
