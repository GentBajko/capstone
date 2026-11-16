# feature - the feature chain, one stage at a time

**Reads:** config → the ledger's `implement/*` keys →
`features/*/feature-interview.md` frontmatter and each feature's
outputs' presence → `../core-authoring.md` before the first stage; the
stage protocols read the rest.

Entry point for taking one feature from idea to code:
`groom` → `plan` → `implement`, resuming wherever it stopped. The
argument is a feature description ("add CSV export") or
an existing feature's slug.

## Procedure

1. Per core.md: read the config, then apply
   [Execution choice](../core.md#execution-choice). Always ask
   subagents or inline on entry, including a resumed feature, and
   wait for the answer before stage work or reference bootstrap.
2. Resolve the feature: match the argument against
   `docs/capstone/features/*/` ids and spec titles **and against the
   `implement/*` keys in the ledger** (`changelog.md`, its rotation
   files, and unfolded `changelog.d/` fragments: shipped features,
   whose folders `implement` may have deleted). No match → a new feature: id
   `<YYYY-MM-DD>-<slug>`, today's date plus a short kebab slug
   derived from the description (per `groom`'s naming rule; derived,
   never allocated from a ledger a parallel branch cannot see). A
   shipped feature's id, legacy `<NN>-<slug>` included, is never
   reused. No argument → list existing features with their stage,
   plus the shipped ones from their keys, and ask which to continue
   (or offer a new one).
3. Determine the stage from the feature's `feature-interview.md` and
   outputs, per core.md's Interview lifecycle:
   - **folder absent with an `implement/<id>` key present anywhere
     in the ledger → shipped**, checked before every row below; say
     so and show the entry. A change request against it is a new feature per `groom`'s
     Resume rule, never a reopening: any retained folder is completed
     local history, not a plan to reopen.
   - folder present with `implemented: true` and a matching
     `implement/<id>` key → shipped. If `delete_feature_folders` is
     `true`, finish the deletion from implement.md Phase D step 6;
     if it is `false`, retain the folder as expected local history.
     Say so and stop. Never re-run the stage.
   - folder present with `implemented: true` but no matching
     `implement/<id>` key → torn write; report it for `doctor` rather
     than re-running the stage or deleting the folder.
   - **the request changes an unshipped feature it matched** (the
     argument names it and adds or alters something about it) →
     `groom`, whatever the rows below say: its Resume rule reopens
     the spec, and a plan approved for the old spec is void once it
     changes. Routing on disk state alone would build the old plan
     and drop the change.
   - no directory and no key, or status `interviewing` /
     `awaiting-formalization` → `groom` (its Resume rules govern:
     `awaiting-formalization` re-presents the gate over the draft
     spec, never planning from an unapproved spec, and
     `formalized` with `spec.md` missing is a
     crash groom regenerates from the recorded `§Q` decisions and
     gates again);
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
   gate. Do not blend stages. Before the first stage protocol of the
   run, read `../core-authoring.md`: the wrapper left it out because
   routing needs none of it, and every stage lands its outputs under
   its rules (artifact seeding, the index row, the local-only ignore
   list). A cross-repo edge the feature adds is
   confirmed inside `groom` per core.md's Edge confirmation;
   `feature` carries its execution choice into every stage. A stage
   counts as done only when its marker AND its changelog key are both
   present; a marker with no
   key is a torn write: report it for `doctor`, which appends the
   missing entry per core.md; never re-run the stage.
5. When a stage completes, announce it in one line and continue
   ("spec approved; planning next; say stop to pause"). `groom`
   completes when the user approves the written `spec.md` at its
   gate, never when the file lands: a spec nobody checked is not
   planned from. Stopping is
   always safe: every stage persists its state, and the next
   `feature` run resumes exactly here.
6. Once `implement` wraps, close the chain by naming `review retro`:
   the session just finished is the evidence it reads. Name it, do not
   run it - retro proposes edits to the user's own steering files and
   starts when they ask. `retro` is never a `feature` argument: that
   argument is a description or a slug, so `feature retro` would groom
   a feature called "retro".
