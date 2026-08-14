# start — the greenfield pipeline, one stage at a time

**Reads:** config → each stage's interview file (status frontmatter)
and the presence of its outputs — nothing else until a stage's own
protocol runs.

Entry point when the user says just "capstone" or asks to start or
continue the pipeline. Runs the interview chain in order, resuming
wherever it stopped:

1. `mockup` → `docs/capstone/mockup/` (+ `mockup-interview.md`)
2. `logic` → `docs/capstone/logic/` (+ `logic-interview.md`)
3. `design` → `docs/capstone/design/` (+ `design-interview.md`)
4. `architecture` → the prescriptive reference
   (+ `architecture-interview.md`)
5. `code-prefs` → `docs/capstone/code-prefs.md`
   (+ `code-prefs-interview.md`)
6. `stack` → the researched, user-picked stack in `05-dependencies.md`
   (+ `stack-interview.md`)
7. `build` → `docs/capstone/implementation.md`, then working code
   (+ `build-interview.md`)

## Procedure

1. Per core.md: read the config (expertise governs every stage's
   conversation; `pipeline` records the fork below).
2. Determine each stage's state from its interview file and outputs,
   per core.md's Interview lifecycle:
   - **not started** — no interview file.
   - **in progress** — status `interviewing` or
     `awaiting-formalization` (for the latter, resume by re-presenting
     the stage's formalization gate — never generate without the
     user's approval; exception: `build` with `plan_approved: true`
     resumes coding per its Resume rules instead of re-gating), or
     `logic` with pending scenarios in its checklist.
   - **done** — status `formalized` (which per the lifecycle implies
     the outputs are on disk) and its changelog key is present;
     `formalized` with no key is repairable: append the missing entry
     from the recorded decisions, without re-interviewing.
   - **outputs missing** — status `formalized` but outputs missing or
     partial (a crash between output writes and reality): regenerate
     the outputs from the recorded decisions, without re-interviewing.
3. Show the pipeline as a short checklist (done / in progress /
   pending) so the user sees where they are; `design` formalized with
   `skipped: no-ui` shows as "skipped (no UI)".
4. The generate-vs-pipeline fork, asked at most once ever:
   - Skip it entirely when config `pipeline` is `true`/`false`, or when
     a stamped descriptive index already exists (an index without
     `mode: prescriptive` files proves the user chose `generate`), or
     when
     any stage has started.
   - Otherwise, if the project has source code (≥1 tracked source file,
     the same measurement as `generate`'s Phase 1 step 8), ask
     whether they want this greenfield pipeline or `generate`, and
     write
     the answer to the project config's `pipeline` key (per core.md,
     creating `docs/capstone/capstone.json` holding just that key if
     absent).
   - On a `generate` answer: execute `protocols/generate.md` now and
     end the pipeline run.
5. Run the first non-done stage by executing its protocol file
   (`mockup.md`, `logic.md`, `design.md`, `architecture.md`,
   `code-prefs.md`, `stack.md`, `build.md`) exactly — including its
   own formalization gate. Do not blend stages.
6. When a stage formalizes, announce it in one line and continue to
   the next ("mockup done — moving to logic; say stop to pause").
   Stopping is always safe: every stage persists its interview file,
   and the next `start` resumes exactly here.
7. After `build`, close out: the project runs. Point at everything
   generated, and note that from now on plain `sync` runs replace
   prescriptive intent with observed fact as the code evolves.
