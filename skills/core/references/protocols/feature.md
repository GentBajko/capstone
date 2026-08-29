# feature - the feature chain, one stage at a time

**Reads:** config → `features/*/feature-interview.md` frontmatter and
each feature's outputs' presence; the stage protocols read the rest.

Entry point for taking one feature from idea to code:
`groom` → `plan` → `implement`, resuming wherever it stopped. The
argument is a feature description ("implementation add CSV export") or
an existing feature's slug.

## Procedure

1. Per core.md: read the config.
2. Resolve the feature: match the argument against
   `docs/capstone/features/*/` slugs and spec titles **and against the
   `implement/<NN>-<slug>` keys in `changelog.md`** (shipped features,
   whose folders `implement` deleted). No match → a new feature: the
   next `<NN>` above every number either source shows, so a retired
   one is never reused, and a short kebab slug derived from the
   description. No argument → list existing features with their stage,
   plus the shipped ones from their keys, and ask which to continue
   (or offer a new one).
3. Determine the stage from the feature's `feature-interview.md` and
   outputs, per core.md's Interview lifecycle:
   - **folder absent with an `implement/<NN>-<slug>` key present →
     shipped**, checked before every row below; say so and show the
     entry. A change request against it is a new feature per `groom`'s
     Resume rule, never a reopening: there is no folder left to reopen.
   - folder present with `implemented: true` → done but the wrap tore
     before its delete (implement.md Phase D step 6); finish the
     delete, say so, and stop. Never re-run the stage.
   - no directory and no key, or status `interviewing` /
     `awaiting-formalization` → `groom` (its Resume rules govern:
     `awaiting-formalization` re-presents the gate, never generating
     without approval, and `formalized` with `spec.md` missing is a
     crash groom regenerates from the recorded `§Q` decisions);
   - `formalized` without a valid plan approval → `plan`; valid
     means `plan_approved: true` AND `approved_spec` matching a
     checksum of the current `spec.md`, and a mismatch is a voided
     approval (plan's Resume rules also govern an unapproved or
     truncated `plan.md`);
   - a valid approval → `implement` (unchecked boxes resume mid-plan;
     every box checked resumes at its review loop and wrap).
4. Hold the three stages as progress tasks per core.md's Progress
   tasks rule: done stages completed, the current stage in progress,
   the rest pending; the running stage's protocol adds its own tasks
   beneath. Then execute the current stage's protocol file
   (`groom.md`, `plan.md`, `implement.md`) exactly, including its own
   gate. Do not blend stages. A stage counts as done only when its
   marker AND its changelog key are both present; a marker with no
   key is a torn write: append that stage's missing entry per
   core.md, never re-run the stage.
5. When a stage completes, announce it in one line and continue
   ("spec approved; planning next; say stop to pause"). Stopping is
   always safe: every stage persists its state, and the next
   `feature` run resumes exactly here.
