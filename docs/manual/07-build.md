# Build the designed product

`build` turns the completed product design into an implementation plan and then code:

```text
/capstone:build
```

Use it for the whole-product design assembled by the greenfield stages. For one feature in an existing application, use [feature/implement](04-feature-workflow.md). `build` and `implement` are the two Capstone protocols allowed to write source code, each after its plan gate.

A standalone build first asks inline or subagents, even on resume. Within start it inherits the answer already given for the current run. A saved `execution` field is a record, not authorization for a new invocation. `non_interactive` does not supply this choice or approve the plan.

## Inputs and prerequisites

Build reads the index, architecture chapters, logic, mockup, UI design, standards, and the stack chapter. It needs the formalized capability matrix from stack, not merely an architecture draft that happens to list some packages. If that prerequisite is absent, it invokes stack first under the current execution choice.

The stage researches how the selected tools actually fit together: framework scaffolding, authentication integration, ORM/database wiring, and deployment conventions. It uses available research tools for unfamiliar APIs instead of treating remembered snippets as verified commands.

The local resume record is `build-interview.md`; the durable plan is `implementation.md`. There is no feature-specific `spec.md` or `features/<id>/plan.md` for this stage.

## What the plan contains

`implementation.md` begins with Global constraints copied from standards and the stack. It then specifies the module/file layout, each component's responsibility and key files, code sketches for important connections, how components communicate, and ordered steps with verification.

Build order starts with the agreed walking skeleton—the thinnest runnable end-to-end path—then backend capabilities in logic-scenario priority order and frontend screens in mockup order. A screen implements its `uiux/screens/` design and the shared system/experience constraints.

The closing Coverage table maps every logic scenario, mockup/UI screen, and index module to a build-order step, or to a recorded exclusion. The stage checks those lists afresh, verifies dependency order, and checks that every step has verification and researched wiring details. A plan that silently omits a scenario is incomplete even if its headline sounds plausible.

At the gate, review layout, order, first slice, coverage totals, and checks. Approval writes `build/plan@Q<n>` and then `plan_approved: true`. No source code is written before that gate.

## Execution and assets

The coding phase reads `implementation.md` and the craft rules rather than the full standards inventory again; the plan must already contain the relevant constraints. If a copied constraint proves wrong, update the plan visibly rather than letting the code silently diverge.

Inline mode executes steps in the current conversation. Subagent mode gives one fresh subagent one build-order step at a time, including full task details, code sketches, verified commands, and global constraints. These executors are sequential, not parallel: later steps consume earlier work. The coordinating agent verifies each report before advancing. Source commits follow the repository's recorded rules and the per-step commit discipline.

After frontend scaffolding but before the first screen, build reads the Assets table. An `awaited` asset stops that part of the build and names the missing file; it does not authorize a placeholder. Present SVGs move from the docs assets directory into the framework's static/public location, and the table's File paths change to their destinations. Favicons, app icons, and `og.png` are rasterized from those sources as required by the selected framework/platform.

Implementation code belongs in the repository source tree, never under the docs area. Build records `build/code@Q<n>` with completed steps, created paths, installed dependencies, and plan divergences. Its `formalized` marker is tied to a runnable walking skeleton; inspect the recorded steps and verification evidence instead of equating that marker with complete deployment or production readiness.

## Resume and finish

If the plan exists and the interview records approval, a resumed build continues coding from verified progress without re-presenting the approved plan or restarting completed steps. The new invocation still asks for execution mode. Unlike feature plan approval, this build protocol does not specify a checksum tied to a separate spec. If product decisions change substantially after approval, make that change explicit and have the implementation plan reviewed again rather than assuming an old marker covers it.

Once real code lands, run `/capstone:map` to replace prescriptive reference material with observed behavior. Build's protocol points to this refresh; it does not specify implement's two-dry-round feature review loop. Use `/capstone:review` when you want that separate codebase/design review. Neither a source commit nor a formalization marker means the application has been publicly deployed.

Sources: [build protocol](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/build.md), [execution choice](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md#execution-choice), [code and Git discipline](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/code-craft.md), [UI asset lifecycle](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/uiux.md).
