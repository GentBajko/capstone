# start - the greenfield pipeline, one stage at a time

**Reads:** config → each stage's interview file (status frontmatter)
and the presence of its outputs; the six pre-`build` interview files
in full, plus core.md's Stage ownership table, once, for the readback
pass (step 7); nothing else until a stage's own protocol runs.

Entry point when the user says just "capstone" or asks to start or
continue the pipeline. Runs the interview chain in order, resuming
wherever it stopped:

1. `mockup` → `docs/capstone/mockup/` (+ `mockup-interview.md`)
2. `logic` → `docs/capstone/logic/` (+ `logic-interview.md`)
3. `uiux` → `docs/capstone/uiux/` (+ `uiux-interview.md`)
4. `architecture` → the prescriptive reference
   (+ `architecture-interview.md`)
5. `standards` → `docs/capstone/standards.md`
   (+ `standards-interview.md`)
6. `stack` → the researched, user-picked stack in `05-dependencies.md`
   (+ `stack-interview.md`)
   - then the **readback**: the cross-stage pass of Procedure step 7.
     No subcommand, no outputs of its own.
7. `build` → `docs/capstone/implementation.md`, then working code
   (+ `build-interview.md`)

## Procedure

1. Per core.md: read the config (expertise governs every stage's
   conversation; `pipeline` records the fork below).
2. Determine each stage's state from its interview file and outputs,
   per core.md's Interview lifecycle:
   - **not started**: no interview file.
   - **in progress**: status `interviewing` or
     `awaiting-formalization` (for the latter, resume by re-presenting
     the stage's formalization gate, never generating without the
     user's approval; exception: `build` with `plan_approved: true`
     resumes coding per its Resume rules instead of re-gating), or
     `logic` with pending scenarios in its checklist.
   - **done**: status `formalized` (which per the lifecycle implies
     the outputs are on disk) and its changelog key is present;
     `formalized` with no key is repairable: append the missing entry
     from the recorded decisions, without re-interviewing.
   - **outputs missing**: status `formalized` but outputs missing or
     partial (a crash between output writes and reality): regenerate
     the outputs from the recorded decisions, without re-interviewing.
3. Hold the pipeline as progress tasks per core.md's Progress tasks
   rule, one per stage plus one for the readback pass (step 7), so the
   user sees where they are; the running stage's protocol adds its own
   tasks beneath. `uiux` formalized
   with `skipped: no-ui` shows as "skipped (no UI)".
4. The generate-vs-pipeline fork, asked at most once ever:
   - Skip it entirely when config `pipeline` is `true`/`false`, or when
     a stamped descriptive index already exists (an index without
     `mode: prescriptive` files proves the user chose `map`), or
     when any stage has started.
   - Otherwise, if the project has source code (≥1 tracked source
     file, the same measurement as `map`'s Phase 1 step 8), ask
     whether they want this greenfield pipeline or `map`, and
     write the answer to the project config's `pipeline` key (per
     core.md, creating `docs/capstone/capstone.json` holding just
     that key if absent).
   - On a `map` answer: execute `protocols/map.md` now and
     end the pipeline run.
5. Run the first non-done stage by executing its protocol file
   (`mockup.md`, `logic.md`, `uiux.md`, `architecture.md`,
   `standards.md`, `stack.md`, `build.md`) exactly, including its
   own formalization gate. Do not blend stages. `build.md` runs only
   after step 7's readback pass.
6. When a stage formalizes, announce it in one line and continue to
   the next ("mockup done; moving to logic; say stop to pause").
   Stopping is always safe: every stage persists its interview file,
   and the next `start` resumes exactly here.
7. **Before `build`, read the interviews back.** No stage can see two
   things: another stage's decisions, and whether a decision it wrote
   down was ever its own to make. A `stack` pick that breaks a
   `mockup` promise is not challengeable while either runs, and a
   business rule the architecture interview happened to reach gets
   filed under architecture because that is where it came up. This
   pass settles both, and it is the last point where either costs a
   paragraph instead of a rewrite.

   Run it when `stack` is `formalized` and `changelog.md` carries no
   `readback/all@Q<n>` key (`<n>` the highest `### Q<n>` across the
   six interview files), before executing `build.md`. Read
   `mockup-`, `logic-`, `uiux-`, `architecture-`, `standards-`, and
   `stack-interview.md` in full, then run the two halves in order:
   misplacement first, so the contradiction half cites final
   locations.

   **Misplacement: move it to its owner.** Against core.md's Stage
   ownership table, collect every `### Q<n>` whose subject belongs to
   a different stage - a business rule settled in
   `architecture-interview.md`, a component boundary settled in
   `logic-interview.md`, a library chosen in `standards-interview.md`
   - plus every decision one stage restates in its own words that
   another stage already owns. The declared crossings that section
   names are not findings, and neither is a citation: a stage
   pointing at another's decision is doing it right.

   Nothing is being re-decided here, only re-filed, so this half is
   **one digest rather than a debate**: list every move as a line
   ("the wind-down threshold: `architecture` §Q12 → `logic`"), and
   the user confirms the set, corrects a destination, or strikes a
   move. On confirmation, per move: append a `### Q<n>` to the
   receiving interview file carrying the decision verbatim, its
   recorded objection included, marked `source: <stage>-interview.md
   §Q<n>`; annotate the original entry as relocated rather than
   deleting it, since the interview is the record of what was
   actually asked; then regenerate both stages' affected outputs, the
   loser's without it and the owner's with it. A restatement is
   settled by replacing the non-owner's copy with a citation.

   **Contradiction and pushback: raise it.** Collect what the Pushback
   rule's Grounds make a finding **across** two stages: a decision
   contradicting one recorded in another stage, or one that cannot
   meet a number another stage recorded. Grounds that live inside a
   single interview are its own stage's to raise, not this pass's,
   and a `### Q<n>` that already records an objection and the user's
   answer is settled: never re-raised here, per the same rule's "then
   it is theirs".

   Raise these one per turn, ordered by blast radius, both sides
   cited `<stage>-interview.md §Q<n>`, under the same two-round cap;
   then the user's answer stands. A resolution appends a `### Q<n>`
   entry to the interview file of the stage that gives way, recording
   both sides per the rule and naming the entry it supersedes, then
   regenerates that stage's affected outputs from the amended
   decisions: never a re-interview, and `status` stays `formalized`.

   Every output either half regenerates takes its changelog entry,
   keyed to the stage that owns it (`standards/readback@Q<n>`).

   Close the pass with its own entry, key `readback/all@Q<n>`, even
   when it found nothing: it names what was read, every decision
   relocated and where it went, every finding, and how each was
   settled. Stopping mid-pass is safe: applied
   resolutions stand, the key goes unwritten, and the next `start`
   re-runs the pass. Resolutions raise the highest `§Q`, so that run
   re-checks once against the amended decisions, then writes the key
   and later runs skip.
8. After `build`, close out: the project runs. Point at everything
   generated, and note that from now on plain `map` runs replace
   prescriptive intent with observed fact as the code evolves.
