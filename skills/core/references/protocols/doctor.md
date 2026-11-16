# doctor - verify and repair the docs area's own consistency

**Reads:** config (the global file, then the project's
`docs/capstone/capstone.json`) → `<index_file>` → the ledger
(`<docs_dir>/changelog.md`, its rotation files, and `changelog.d/`
fragments) → every interview file's frontmatter → the outputs each done marker
implies (presence, stamps, and final bodies for authority check 4b) →
`<docs_dir>/.gitignore` → `<docs_dir>/questionnaires/` →
`uiux/02-system.md`'s `## Assets` table and the `uiux/assets/` folder
it names → `scripts/map-check.sh` (check 9) and `map check`'s model
half, its absorption count and entry-point inventory (checks 6-7).

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
   Where the working record that repair needs is gone, report the
   loss as unrecoverable and invent nothing. An absent local-only
   output (`features/`, `review.md`, an interview file;
   core-authoring.md's Local-only outputs) is never this finding: a
   clone that did not make it does not have it.
   A `uiux/skipped@Q<n>` key has no outputs by design and is never
   this finding. An `edges/*` key is never this finding either: the
   far ends it records are a person's to change and `map`'s to drop
   with the row, so no repair restores one.
2. **Approval integrity**: `plan_approved: true` with `plan.md`
   missing or truncated (a crash, per plan.md's Resume paragraph);
   `approved_spec` no longer matching a checksum of the current
   `spec.md` (a voided approval, per the same paragraph). Repair =
   delete `plan_approved` and `approved_spec`, as that paragraph
   does first; rebuilding the plan and its gate are `plan`'s next
   run, never doctor's.
2b. **Torn wrap**: when `delete_feature_folders` is `true`, a
   `features/<id>/` folder still on disk, its interview saying
   `implemented: true`, while the ledger carries its
   `implement/<id>` key means the wrap died between recording and
   deleting. The same folder without `implemented: true` is an
   unfinished wrap that `implement`'s Resume completes: nothing is
   deleted. Repair = finish the delete (implement.md Phase D step 6),
   never re-run the stage. When the setting is `false`, that same
   folder is retained history and is not a finding. The inverse
   (`implemented: true` with no key) is a torn write, check 1.
3. **Index ↔ disk**: index rows pointing at missing files (a row
   for a local-only output is no finding when its file is absent); files
   under `<docs_dir>` with no row (core-authoring.md's Index
   maintenance; `review/`'s screenshots take none, per its Local-only
   outputs); an
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
5. **Housekeeping**: `<docs_dir>/.gitignore` missing,
   or the ignore file still listing `changelog.md` or `capstone.json`
   (repair = run the per-project initializer,
   `init-config.sh <docs_dir>`, per core-authoring.md's Local-only
   outputs; a config
   key that is merely absent takes its default and is no finding); `changelog.md` or the project
   `docs/capstone/capstone.json` untracked inside a git
   repo whatever `docs_in_git` says (both are always committed,
   core.md; repair = stage it, and report an untracked ledger loudly:
   every shipped feature's reasoning was one disk away from gone);
   `expertise` or `teaching_mode` in the project config (repair =
   move its value to the global file when that one holds none, then
   delete the key there; it is personal, the global file keeps it,
   and a run ignores it wherever it sits);
   a file in `questionnaires/` whose questions all still carry empty
   answer stubs while the stage that sent it has moved on (repair =
   report it and name the recipient and the send date, so the user can
   chase the answer or strike the open item; never fill a stub in, and
   never delete the file, which is the record of what was asked);
   `capstone.json` invalid JSON (`//` line comments are permitted
   per core.md and are never a finding) or keys outside their ranges;
   a row in `uiux/02-system.md`'s `## Assets` table whose `Status` is
   `present` while its `File` does not exist at the path the row
   records - under `uiux/assets/` until `build` moves it into the app
   tree and rewrites the cell (repair = set
   that row to `awaited`, or supply the file; `build` stops on an
   `awaited` row, and a `present` row that is not there stops it
   later and further from the cause).
6. **Absorption drift**: `map check`'s absorption count; repair =
   re-run `implement`'s absorb step (its Phase D step 2) per missed
   feature, reading that feature's `spec.md` if still on disk; a
   spec already deleted is reported unrecoverable, never guessed.
7. **Logic coverage**: `map check`'s entry-point inventory: entry
   points no `logic/` scenario claims; repair = the `map` refresh's
   logic-coverage step (extraction per missing scenario, map.md).
8. **Ledger size**: `changelog.md` past 200 entries; repair = the
   rotation in core.md's ledger rule (move all but the newest 100,
   each into the `changelog-<YYYY>.md` of the year its own date falls
   in, added to that file when an earlier rotation already made it;
   keys **with** their bodies; nothing is left behind in
   `changelog.md`). Dropping a key is never part of
   it: shipped features resolve from the `implement/*` keys wherever
   they live, so a dropped one is a shipped feature that reads as
   unstarted and an id freed for reuse. A legacy
   `changelog-archive-<YYYY>.md` with a stripped-key `## Archived`
   section is left as-is and searched like any other ledger file.
9. **Schema**: the part-8 pass of `map check`'s script
   (`scripts/map-check.sh`: frontmatter keys, `known_as` included,
   required headings, and on `09-interfaces.md` the `edges:` block's
   four edge findings - a row with no `site`, a `site` the tree does
   not hold, a missing or empty `### <Name>` payload section, and a
   `schema` naming an entity `02-models.md` has none of - plus
   secret-shaped strings per file); repair = the `map`
   refresh, which regenerates a file missing a key or heading against
   the current template; a secret is removed by hand, never
   regenerated around.
10. **Unfolded fragments**: files sitting in `changelog.d/`; repair =
   fold them per core.md's ledger rule. Doctor applying any approved
   repair is a writing run and folds anyway; on a non-default branch
   the fold is skipped per that rule and the fragments are reported
   as the designed state, not a finding.

## Report, then repair

**What `fix` pre-approves.** Exactly the repairs that restore a state
a crash rule already defines without choosing anything: check 1's
catch-up ledger entry, check 2's removal of the stale approval keys,
check 2b's finish-the-delete, check 5's initializer run, and check
10's fold. Everything else - regenerating outputs, a `map` refresh,
absorption, extraction, rotation, and every other repair above - is
listed and asked, `fix` or not.

Present the findings table (check · finding · owning rule · proposed
repair), grouped pre-approvable (the five above) vs
needs-confirmation, as a message question per core.md's Structured
questions: the table is the chat message, its last line asks which
repairs to apply, and the turn ends there. Invoked with `fix`, doctor
applies the pre-approvable repairs before presenting the table, marks
them applied in it, and still ends the turn on the question about the
rest (a run with nothing left to ask says so and ends instead).
Apply what the user approves and re-run the affected checks after.
Write the changelog entry (a `changelog.d/` fragment, folded per
core.md's ledger rule when on the default branch) only when something
was repaired, key `doctor/<scope>@<stamp>`, listing each repair and
its owning rule, once that turn's repairs are on disk: a `fix` run
writes it before ending on the question, and repairs approved after
it are a new event at the same stamp (`.2` per core.md's ledger
rule). A clean or report-only run writes nothing and says so.
