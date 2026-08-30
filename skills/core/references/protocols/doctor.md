# doctor - verify and repair the docs area's own consistency

**Reads:** config → `<index_file>` → `<docs_dir>/changelog.md` →
every interview file's frontmatter → the outputs each done marker
implies (presence and stamps, not full bodies) →
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
2b. **Torn wrap**: a `features/<NN>-<slug>/` folder still on disk
   while `changelog.md` carries its `implement/<NN>-<slug>` key: the
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
5. **Housekeeping**: `<docs_dir>/.gitignore` or config keys missing,
   or the ignore file still listing `changelog.md` (repair = run the
   initializer, core.md's rule); `changelog.md` untracked inside a git
   repo whatever `docs_in_git` says (the ledger is always committed,
   core.md; repair = stage it, and report it loudly: every shipped
   feature's reasoning was one disk away from gone);
   `capstone.json` invalid JSON or keys outside their ranges.
6. **Absorption drift**: `sync check`'s absorption count; repair =
   re-run `implement`'s absorb step (its Phase D step 2) per missed
   feature, reading that feature's `spec.md` if still on disk; a
   spec already deleted is reported unrecoverable, never guessed.
7. **Logic coverage**: `sync check`'s entry-point inventory: entry
   points no `logic/` scenario claims; repair = the `sync` refresh's
   logic-coverage step (extraction per missing scenario, sync.md).
8. **Ledger size**: `changelog.md` past 200 entries; repair = the
   rotation in core.md's ledger rule (archive all but the newest 100
   into `changelog-archive-<YYYY>.md`, leaving every archived entry's
   `## <date>` heading and `key:` line behind under `## Archived`).
   Dropping a key is never part of it: `feature` allocates the next
   `<NN>` from those keys, so a dropped one is a reused number and a
   shipped feature that reads as unstarted.

## Report, then repair

Present the findings table (check · finding · owning rule · proposed
repair), grouped auto-repairable (a documented crash rule) vs
needs-confirmation. Apply what the user approves (a user who invoked
doctor with "fix" pre-approves the documented crash rules) and
re-run the affected checks after. Append ONE changelog entry only
when something was repaired, key `doctor/<scope>@<stamp>`, listing
each repair and its owning rule. A clean or report-only run writes
nothing and says so.
