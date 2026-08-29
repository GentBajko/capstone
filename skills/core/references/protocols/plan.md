# plan - task-by-task implementation plan from a groomed spec

**Reads:** config → the feature's `feature-interview.md` → `spec.md`
→ the chapters, scenarios, and screens it cites → `code-prefs.md` →
`../code-craft.md` → the conventions and testing chapters.

Second stage of the feature chain: turns a formalized `spec.md` into a
plan an engineer with zero context could execute. The superpowers
writing-plans discipline (bite-sized steps, complete code, exact
paths, TDD throughout) with capstone's twist that context comes from
the chapterized reference, not repo exploration.

Prerequisite: the feature's interview `formalized` and `spec.md` on
disk. Interview missing or not yet `formalized` → execute
`protocols/groom.md` first (its Resume rules pick up mid-interview);
`formalized` with `spec.md` missing is a crash `groom`'s Resume rule
regenerates.

State: the feature's
`docs/capstone/features/<NN>-<slug>/feature-interview.md`
(`plan_approved: true` is set at the gate; the lifecycle `status`
stays `formalized`; this stage never touches it). Output: `plan.md`
beside the spec. Resolve a `<feature>` argument as `groom`'s Resume
rule does; with no argument and exactly one feature not yet
implemented, take it; otherwise ask.

**Resume:** an approval is valid only while `approved_spec` still
matches a checksum of the current `spec.md`. Valid → never re-present
the plan; point at `implement`. Mismatch → the approval is void:
delete `plan_approved` and `approved_spec` from the frontmatter
first, before touching `plan.md`, then re-run Phase A's study and
Phase B's review passes against the changed spec, update the plan,
and re-gate. If `plan.md` exists unapproved (or ends mid-sentence, a
crash artifact), finish it via Phase B's review passes, re-reading
Phase A's sources as needed, then re-present the gate.

## Phase A - study

Read the spec, then exactly what it cites: its Reference impact
chapters, the `logic/` scenarios and `mockup/` screens it names, plus
`code-prefs.md` (every code decision follows it), `../code-craft.md`
(the TDD + YAGNI discipline every planned task obeys; code-prefs wins
on conflict) and the conventions and testing chapters for how code
and tests are written here. The chapters answer where things live and
how they connect; read source files only where the plan must name
exact lines, or where a chapter labels its coverage shallow.

## Phase B - write the plan

Assume the executing engineer is skilled but knows nothing about this
codebase, its toolset, or good test design: the plan carries
everything. `plan.md`:

- **Header**: goal in one sentence; approach in 2-3; the stack pieces
  touched; global constraints copied verbatim from the spec and
  `code-prefs.md` (version floors, naming rules, banned patterns).
- **File map**: every file created or modified, one responsibility
  each, before any task is defined.
- **Tasks**: numbered `### Task N: <name>` headings, each the
  smallest unit that carries its own test cycle and is worth a fresh
  reviewer's gate. Fold setup, configuration, scaffolding, and
  documentation steps into the task whose deliverable needs them;
  split only where a reviewer could reject one task while approving
  its neighbor.
  Per task: exact paths (`Create:` / `Modify:` / `Test:`), interfaces
  consumed from earlier tasks and produced for later ones (exact
  names and signatures; a task's executor may see only its own task),
  then checkbox (`- [ ]`) steps of 2-5 minutes each: write the failing
  test (the actual test code), run it and see it fail (exact command,
  expected failure), implement minimally (the actual code), run it and
  see it pass (exact command), commit (message per code-craft's Git
  section: `<type>(<scope>): <subject>` plus the why in the body).
- Backend before frontend where the feature spans both.
- **Coverage**, the closing section: a table with one row per
  numbered spec requirement, per Behavior rule (each happy-path step,
  branch, unhappy path, and state change), and per global constraint,
  naming the task(s) that implement it and the task whose test proves
  it. A row with no task is a gap; fix the plan, never the table.
  There is no catch-all row, and no row covered "implicitly" by
  another.

Placeholders are plan failures: never "TBD", "add validation",
"similar to Task N", tests described but not written, or names no task
defines. If a step changes code, the step shows the code.

Every task climbs code-craft's ladder before it is written down: a
task that builds what a rung above already provides, or an
abstraction no rung earned, is cut from the plan, not deferred to the
executor's judgment, unless a spec requirement mandates it, which is
a recorded user decision and earns it per code-craft's never-lazy
list. The plan's tests are YAGNI-scoped per code-craft; its
interfaces appear only where that file says one is earned.

**Review, then re-review.** A drafted plan is not presentable until
it survives full passes of this check, repeated until a pass finds
nothing to fix:

1. Re-read `spec.md` top to bottom, fresh, against the Coverage
   table: every requirement, Behavior rule, and constraint lands on a
   real task; a spec line with no row means the pass failed.
2. Walk the tasks in order: names and signatures a task consumes
   match the task that defined them, and no task consumes what a
   later task defines.
3. Sweep for the placeholder patterns above; any survivor fails the
   pass.

Fix what a pass finds, then run the next full pass; a pass that found
anything voids the ones before it. Dropping a spec detail because a
task "obviously implies it" is a gap, not a judgment call: the
executor sees only the plan.

## Phase C - the gate

Present the summary: file map, task list, the Coverage table's totals
(N requirements and N behavior rules, all mapped), what Task 1
proves. The user approves before any code is written. On approval,
first append the changelog entry per core.md's ledger, key
`plan/<NN>-<slug>@Q<n>` from the same highest `§Q`; record the file
map, the task count and titles, and the global constraints pinned.
Then record `plan_approved: true` and `approved_spec: <checksum of
spec.md>` (`git hash-object spec.md`; any stable checksum outside
git) in the interview frontmatter; `implement` and the chain verify
the approval against it. `plan.md` is covered by the `features/`
Companion docs row; no separate row.

**Consumer:** `implement` executes the plan; suggest it as the next
step.
