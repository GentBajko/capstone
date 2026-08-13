# plan — task-by-task implementation plan from a groomed spec

Second stage of the feature chain: turns a formalized `spec.md` into a
plan an engineer with zero context could execute. The superpowers
writing-plans discipline — bite-sized steps, complete code, exact
paths, TDD throughout — with capstone's twist that context comes from
the chapterized reference, not repo exploration.

Prerequisite: the feature's interview `formalized` and `spec.md` on
disk. Interview missing or not yet `formalized` → execute
`protocols/groom.md` first (its Resume rules pick up mid-interview);
`formalized` with `spec.md` missing is a crash `groom`'s Resume rule
regenerates.

State: the feature's
`docs/capstone/features/<NN>-<slug>/feature-interview.md`
(`plan_approved: true` is set at the gate; the lifecycle `status`
stays `formalized` — this stage never touches it). Output: `plan.md`
beside the spec. Resolve a `<feature>` argument as `groom`'s Resume
rule does; with no argument and exactly one feature not yet
implemented, take it — otherwise ask.

**Resume:** an approval is valid only while `approved_spec` still
matches a checksum of the current `spec.md`. Valid → never re-present
the plan; point at `implement`. Mismatch → the approval is void:
delete `plan_approved` and `approved_spec` from the frontmatter
first, before touching `plan.md`, then re-run Phase A's study and
Phase B's self-review against the changed spec, update the plan, and
re-gate. If `plan.md` exists unapproved (or ends mid-sentence — a
crash artifact), finish it via Phase B's self-review — re-reading
Phase A's sources as needed — then re-present the gate.

## Phase A — study

Read the spec, then exactly what it cites: its Reference impact
chapters, the `logic/` scenarios and `mockup/` screens it names, plus
`code-prefs.md` (every code decision follows it) and the conventions
and testing chapters for how code and tests are written here. The
chapters answer where things live and how they connect; read source
files only where the plan must name exact lines, or where a chapter
labels its coverage shallow.

## Phase B — write the plan

Assume the executing engineer is skilled but knows nothing about this
codebase, its toolset, or good test design — the plan carries
everything. `plan.md`:

- **Header** — goal in one sentence; approach in 2–3; the stack pieces
  touched; global constraints copied verbatim from the spec and
  `code-prefs.md` (version floors, naming rules, banned patterns).
- **File map** — every file created or modified, one responsibility
  each, before any task is defined.
- **Tasks** — numbered `### Task N: <name>` headings, each the
  smallest unit that carries its own test cycle and is worth a fresh
  reviewer's gate. Fold setup, configuration, scaffolding, and
  documentation steps into the task whose deliverable needs them;
  split only where a reviewer could reject one task while approving
  its neighbor.
  Per task: exact paths (`Create:` / `Modify:` / `Test:`), interfaces
  consumed from earlier tasks and produced for later ones (exact
  names and signatures — a task's executor may see only its own task),
  then checkbox (`- [ ]`) steps of 2–5 minutes each: write the failing
  test (the actual test code), run it and see it fail (exact command,
  expected failure), implement minimally (the actual code), run it and
  see it pass (exact command), commit.
- Backend before frontend where the feature spans both.

Placeholders are plan failures — never "TBD", "add validation",
"similar to Task N", tests described but not written, or names no task
defines. If a step changes code, the step shows the code.

Self-review (fix inline): every spec requirement points at a task that
implements it; none of the placeholder patterns above survive; names
and signatures used in later tasks match the tasks that defined them.

## Phase C — the gate

Present the summary: file map, task list, what Task 1 proves. The user
approves before any code is written. On approval, first append the
changelog entry per core.md's ledger — key `plan/<NN>-<slug>@Q<n>` from
the same highest `§Q`; record the file map, the task count and titles,
and the global constraints pinned. Then record
`plan_approved: true` and `approved_spec: <checksum of spec.md>`
(`git hash-object spec.md`; any stable checksum outside git) in the
interview frontmatter — `implement` and the chain verify the approval
against it. `plan.md` is covered by the `features/` Companion docs
row — no separate row.

**Consumer:** `implement` executes the plan; suggest it as the next
step.
