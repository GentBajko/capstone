# doctor — verify and repair the docs area's own consistency

**Reads:** config → `<index_file>` → `<docs_dir>/changelog.md` →
every interview file's frontmatter → the outputs each done marker
implies (presence and stamps, not full bodies) →
`<docs_dir>/.gitignore`.

Read-only diagnosis first, then offered repairs. Every repair doctor
performs is a rule some protocol already defines — doctor centralizes
them; the owning protocol stays the source of truth. Beyond those
documented rules it proposes, never applies.

## Checks

1. **Torn writes** — a done marker (`formalized`, `plan_approved`,
   `implemented`) with no matching changelog key: repair = append the
   catch-up entry from the recorded decisions (core.md's ledger
   rule). A changelog key whose outputs are missing or partial:
   repair = regenerate the outputs from the recorded decisions, never
   re-interviewing (each stage's outputs-missing rule, per start.md).
2. **Approval integrity** — `plan_approved: true` with `plan.md`
   missing or truncated (plan.md's crash rule: re-run its Phase B,
   then re-gate); `approved_spec` no longer matching a checksum of
   the current `spec.md` (a voided approval — plan.md's Resume rule:
   drop the stale keys, re-plan).
3. **Index ↔ disk** — index rows pointing at missing files; files
   under `<docs_dir>` with no row (core.md's Index maintenance);
   stamp drift between an index row and its file's frontmatter.
4. **Lifecycle validity** — interview `status` values outside
   core.md's lifecycle; `formalized` with outputs absent; a `logic`
   checklist holding scenarios neither `written` nor `dropped` while
   the file says `formalized`.
5. **Housekeeping** — `<docs_dir>/.gitignore` or config keys missing
   (repair = run the initializer, core.md's rule); `capstone.json`
   invalid JSON or keys outside their ranges.
6. **Absorption drift** — `sync check`'s absorption count; repair =
   re-run `implement`'s absorb step (its Phase D step 2) per missed
   feature, reading that feature's `spec.md` if still on disk — a
   spec already deleted is reported unrecoverable, never guessed.

## Report, then repair

Present the findings table (check · finding · owning rule · proposed
repair), grouped auto-repairable (a documented crash rule) vs
needs-confirmation. Apply what the user approves — a user who invoked
doctor with "fix" pre-approves the documented crash rules — and
re-run the affected checks after. Append ONE changelog entry only
when something was repaired — key `doctor/<scope>@<stamp>`, listing
each repair and its owning rule. A clean or report-only run writes
nothing and says so.
