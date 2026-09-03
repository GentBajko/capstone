# start - the greenfield pipeline, one stage at a time

**Reads:** config → each stage's interview file (status frontmatter)
and the presence of its outputs; the six pre-`build` stages' final
outputs, plus core.md's Stage ownership table, once, for the readback
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
   - **not started**: no interview file, no complete final outputs, and
     no matching stage changelog key.
   - **in progress**: status `interviewing` or
     `awaiting-formalization` (for the latter, resume by re-presenting
     the stage's formalization gate, never generating without the
     user's approval; exception: `build` with `plan_approved: true`
     resumes coding per its Resume rules instead of re-gating), or
     `logic` with pending scenarios in its checklist.
    - **done**: complete final outputs and the matching stage changelog
       key are present. Local interview frontmatter saying `formalized`
       confirms the same state when it exists but is not required on a
       fresh clone;
     `formalized` with no key is repairable: append the missing entry
     from the recorded decisions, without re-interviewing.
    - **outputs missing**: status `formalized` or a stage changelog key
       exists, but outputs are missing or partial. Regenerate from the
       interview only when that local working record still exists;
       otherwise report the loss as unrecoverable and never invent the
       missing decisions.
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
7. **Before `build`, read the final outputs back.** No stage can see
   every later stage while it runs, so this pass checks ownership and
   contradictions across the completed body of work. The final files
   are the only decision sources: completed interview bodies are not
   opened, cited, or amended.

   Run it when the stack output is formalized and `changelog.md`
   carries no `readback/all@<stamp>` key, before executing `build.md`.
   `<stamp>` is a stable hash of the ordered latest changelog keys for
   the six stage outputs, so unchanged outputs skip and any amended
   stage runs the pass again.
   Read the final `mockup/`, `logic/`, `uiux/`, architecture chapters,
   `standards.md`, and `05-dependencies.md`, then run the two halves in
   order: misplacement first, so the contradiction half cites final
   locations.

   **Misplacement: move it to its owner.** Against core.md's Stage
   ownership table, collect every decision whose subject belongs to a
   different stage, plus every decision one stage restates in its own
   words that another final file already owns. A cross-reference to an
   owning final file is correct and is not a finding.

   Nothing is being re-decided here, only re-filed, so this half is
   **one digest rather than a debate**: list every move as a line
   ("the wind-down threshold: `01-architecture.md` →
   `logic/03-wind-down.md`"), and the user confirms the set, corrects
   a destination, or strikes a move. On confirmation, write the
   decision and its rationale into the owner's final file, remove it
   from the non-owner, and replace any needed mention there with a
   citation to the owning final file. Refresh the changed files'
   stamps, the index's `Settles`, `Not here`, and Terms ownership, and
   each owning stage's changelog entry. A missing owner file or
   scenario is created through that stage's protocol rather than
   improvised here.

   **Contradiction and pushback: raise it.** Collect what the Pushback
   rule's Grounds make a finding across two final outputs: decisions
   that contradict each other, or one that cannot meet a number the
   other records. Raise these one per turn, ordered by blast radius,
   with both final file locations cited, under the same two-round cap;
   then the user's answer stands. Write the resolution and rationale
   into the owning output and update or remove the superseded rule in
   the other output.

   Every output either half changes takes its changelog entry, keyed
   to the stage that owns it (`standards/readback@<stamp>`).

   Close the pass with its own entry, key
   `readback/all@<stamp>`, even when it found nothing: it names the
   final files read, every decision relocated and where it went, every
   finding, and how each was settled. Stopping mid-pass is safe:
   applied resolutions stand, the key goes unwritten, and the next
   `start` re-runs the pass.
8. After `build`, close out: the project runs. Point at everything
   generated, and note that from now on plain `map` runs replace
   prescriptive intent with observed fact as the code evolves.
