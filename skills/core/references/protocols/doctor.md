# doctor - verify and repair the docs area's own consistency

**Reads:** config → `<index_file>` → the ledger
(`<docs_dir>/changelog.md`, its rotation files, and `changelog.d/`
fragments) → every interview file's frontmatter → the outputs each done marker
implies (presence, stamps, and final bodies for authority check 4b) →
`<docs_dir>/.gitignore`.

Read-only diagnosis first, then offered repairs. Every repair doctor
performs is a rule some protocol already defines; doctor centralizes
them, and the owning protocol stays the source of truth. Beyond those
documented rules it proposes, never applies.

## Checks

1. **Torn writes**: a done marker (`formalized`, `plan_approved`,
   `implemented`) with no matching changelog key: repair = append the
   catch-up entry from the recorded decisions (core.md's ledger
   rule). A changelog key whose outputs are missing or partial:
   repair = regenerate the outputs from the recorded decisions, never
   re-interviewing (each stage's outputs-missing rule, per start.md).
2. **Approval integrity**: `plan_approved: true` with `plan.md`
   missing or truncated (plan.md's crash rule: re-run its Phase B,
   then re-gate); `approved_spec` no longer matching a checksum of
   the current `spec.md` (a voided approval; plan.md's Resume rule:
   drop the stale keys, re-plan).
2b. **Torn wrap**: a `features/<id>/` folder still on disk
   while the ledger carries its `implement/<id>` key: the
   wrap died between recording and deleting. Repair = finish the
   delete (implement.md Phase D step 6), never re-run the stage. The
   inverse (`implemented: true` with no key) is a torn write, check 1.
3. **Index ↔ disk**: index rows pointing at missing files; files
   under `<docs_dir>` with no row (core-authoring.md's Index maintenance); an
   index still at the legacy root `DESIGN.md` (repair = the legacy
   move in core-authoring.md's Index maintenance), or one still carrying stamp
   columns (repair = drop them; freshness lives in each file's
   frontmatter, and a second copy only drifts).
4. **Lifecycle validity**: interview `status` values outside
   core.md's lifecycle; `formalized` with outputs absent; a `logic`
   checklist holding scenarios neither `written` nor `dropped` while
   the file says `formalized`.
4b. **Final-output authority**: an indexed final output names an
   interview file or cites an interview question. Repair = write the
   confirmed decision and rationale directly into the owning output
   and remove the working-state provenance. Read a completed interview
   body only when the final output lacks content needed for that
   repair; if it is unavailable, report the omission as unrecoverable
   and never guess.
5. **Housekeeping**: `<docs_dir>/.gitignore` or config keys missing,
   or the ignore file still listing `changelog.md` (repair = run the
   initializer, core.md's rule); `changelog.md` untracked inside a git
   repo whatever `docs_in_git` says (the ledger is always committed,
   core.md; repair = stage it, and report it loudly: every shipped
   feature's reasoning was one disk away from gone);
   `capstone.json` invalid JSON (`//` line comments are permitted
   per core.md and are never a finding) or keys outside their ranges.
6. **Absorption drift**: `map check`'s absorption count; repair =
   re-run `implement`'s absorb step (its Phase D step 2) per missed
   feature, reading that feature's `spec.md` if still on disk; a
   spec already deleted is reported unrecoverable, never guessed.
7. **Logic coverage**: `map check`'s entry-point inventory: entry
   points no `logic/` scenario claims; repair = the `map` refresh's
   logic-coverage step (extraction per missing scenario, map.md).
8. **Ledger size**: `changelog.md` past 200 entries; repair = the
   rotation in core.md's ledger rule (move all but the newest 100
   into `changelog-<YYYY>.md`, keys **with** their bodies; nothing is
   left behind in `changelog.md`). Dropping a key is never part of
   it: shipped features resolve from the `implement/*` keys wherever
   they live, so a dropped one is a shipped feature that reads as
   unstarted and an id freed for reuse. A legacy
   `changelog-archive-<YYYY>.md` with a stripped-key `## Archived`
   section is left as-is and searched like any other ledger file.
9. **Unfolded fragments**: files sitting in `changelog.d/`; repair =
   fold them per core.md's ledger rule. Doctor applying any approved
   repair is a writing run and folds anyway; on a non-default branch
   the fold is skipped per that rule and the fragments are reported
   as the designed state, not a finding.

## Report, then repair

Present the findings table (check · finding · owning rule · proposed
repair), grouped auto-repairable (a documented crash rule) vs
needs-confirmation. Apply what the user approves (a user who invoked
doctor with "fix" pre-approves the documented crash rules) and
re-run the affected checks after. Write ONE changelog entry (a
`changelog.d/` fragment, folded per core.md's ledger rule when on
the default branch) only
when something was repaired, key `doctor/<scope>@<stamp>`, listing
each repair and its owning rule. A clean or report-only run writes
nothing and says so.
