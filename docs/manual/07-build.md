# Build the designed product

`build` turns the completed product design into an implementation plan and then code:

```text
/capstone:start build
```

Use it for the whole-product design assembled by the greenfield stages. For one feature in an existing application, use [feature/implement](04-feature-workflow.md). `build` and `implement` are the two Capstone protocols allowed to write source code, each after its plan gate.

A standalone build first asks inline or subagents, even on resume. Within start it inherits the answer already given for the current run. A saved `execution` field is a record, not authorization for a new invocation. `non_interactive` does not supply this choice or approve the plan.

## Inputs and prerequisites

Build reads the index, architecture chapters, logic, mockup, UI design, standards, and the stack chapter. It needs the formalized capability matrix from stack, not merely an architecture draft that happens to list some packages. If the `stack/all` key is absent or the matrix is incomplete (a capability row with no pick, no-dependency decision, "not needed" ruling, or open or deferred marker), it invokes stack first under the current execution choice. Entered directly, it then runs the readback pass when no `readback/all@<stamp>` key matches the current outputs.

The stage researches how the selected tools actually fit together: framework scaffolding, authentication integration, ORM/database wiring, and deployment conventions. It uses available research tools for unfamiliar APIs instead of treating remembered snippets as verified commands.

The local resume record is `build-interview.md`, created when research starts; the durable plan is `implementation.md`. There is no feature-specific `spec.md` or `features/<id>/plan.md` for this stage.

## What the plan contains

`implementation.md` begins with Global constraints copied from standards and the stack. It then specifies the module/file layout, each component's responsibility and key files, code sketches for important connections, how components communicate, and ordered steps with verification.

Build order starts with the agreed walking skeleton - the thinnest runnable end-to-end path, read from the architecture ledger entry when the chapters do not record it - then backend capabilities in the order of the mockup README's Scenarios table and frontend screens in mockup order. A screen implements its `uiux/screens/` design and `uiux/02-system.md`'s Implementation constraints. Each step is a checkbox in `implementation.md`.

The closing Coverage table maps every logic scenario, mockup/UI screen, and index module to a build-order step, or to a recorded exclusion. The stage checks those lists afresh, verifies dependency order, and checks that every step has verification and researched wiring details. A plan that silently omits a scenario is incomplete even if its headline sounds plausible.

At the gate, review layout, order, first slice, coverage totals, and checks. Approval writes `build/plan@<stamp>` (build asks no interview questions, so its keys carry the run's commit stamp) and then `plan_approved: true`. No source code is written before that gate.

## Execution and assets

The coding phase reads `implementation.md` and the craft rules rather than the full standards inventory again; the plan must already contain the relevant constraints. If a copied constraint proves wrong, build stops and asks you; a changed step or constraint goes back through the plan gate before coding continues.

Inline mode executes steps in the current conversation. Subagent mode gives one fresh subagent one build-order step at a time, including full task details, code sketches, verified commands, and global constraints. These executors are sequential, not parallel: later steps consume earlier work. The coordinating agent verifies each report before advancing. Source commits follow the repository's recorded rules and the per-step commit discipline.

After frontend scaffolding but before the first screen, build reads the Assets table. An `awaited` asset stops that part of the build and names the missing file; it does not authorize a placeholder. Present SVGs move from the docs assets directory into the framework's static/public location, and the table's File paths change to their destinations. Favicons, app icons, and `og.png` are rasterized from those sources as required by the selected framework/platform.

Implementation code belongs in the repository source tree, never under the docs area. Each step's checkbox is checked when its verification passes. The walking skeleton is the first milestone and is reported, not recorded as done. When every box is checked, build records `build/code@<stamp>` with the steps, created paths, installed dependencies, and plan divergences, then sets `formalized`; a session that ends with steps unchecked records no entry. That marker still does not mean deployment or production readiness.

## Resume and finish

If the plan exists and the interview records approval, a resumed build continues coding from the first unchecked step without re-presenting the approved plan or restarting completed steps. The new invocation still asks for execution mode. Unlike feature plan approval, this build protocol does not specify a checksum tied to a separate spec. If product decisions change substantially after approval, make that change explicit and have the implementation plan reviewed again rather than assuming an old marker covers it.

Once real code lands, run `/capstone:map` to replace prescriptive reference material with observed behavior. Build's protocol points to this refresh; it does not specify implement's two-dry-round feature review loop. Use `/capstone:review` when you want that separate codebase/design review. Neither a source commit nor a formalization marker means the application has been publicly deployed.

Sources: [build protocol](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/protocols/build.md), [execution choice](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/core.md#execution-choice), [code and Git discipline](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/code-craft.md), [UI asset lifecycle](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/protocols/uiux.md).
