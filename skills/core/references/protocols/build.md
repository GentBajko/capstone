# build - implementation research, then working code

**Reads:** config → `build-interview.md` (resume) → the index and
chapters → `logic/`, `mockup/`, `design/`, `code-prefs.md`,
`../code-craft.md` → the stack chapter → the existing
`implementation.md` (resume).

The last stage: turns the whole reference into running code, backend
first, then frontend. With `implement`, one of the **two commands
allowed to write source code** (core.md hard rule 2), and only after
its plan gate.

State: `docs/capstone/build-interview.md` (standard lifecycle per
core.md; `formalized` here means the walking-skeleton slice runs).
Plan output: `docs/capstone/implementation.md` (companion, indexed).
Prerequisite: if `stack-interview.md` is not `formalized`, execute
`protocols/stack.md` first; `05-dependencies.md` existing is not
enough, since the architecture stage writes a draft of it too.

**Resume:** if `implementation.md` exists and the interview records
plan approval (`plan_approved: true` in its frontmatter, set at the
gate), skip straight to Phase C and continue from the last step whose
verification passes; never re-present an approved plan, never restart
finished steps.

## Phase A - implementation research

Read everything: the index and chapters, `docs/capstone/logic/`,
`docs/capstone/mockup/`, `docs/capstone/design/`,
`docs/capstone/code-prefs.md`, and the stack chapter. Research (web
search when available) how the chosen pieces actually connect:
scaffold conventions for the chosen framework, integration patterns
between the picks (auth ↔ framework, ORM ↔ database, deploy target),
official quickstarts for anything unfamiliar. Then write
`docs/capstone/implementation.md`:

- The module/file layout to create: backend tree, then frontend tree.
- Per component: what it does, its key files, and real code sketches
  for the load-bearing seams (the wiring, not the boilerplate).
- How components connect (interfaces, calls, events), each traceable
  to the architecture chapters that decided it.
- Build order: the walking-skeleton slice first (recorded in the
  architecture interview), then backend capabilities in logic-scenario
  priority order, then frontend screens in mockup order, each
  implementing its `design/screens/` chapter and
  `design/02-system.md`'s Implementation constraints; when the
  `impeccable` skill is installed, the frontend pass also honors its
  craft floor and finish-review flow.
- Per step: how to verify it works before moving on.
- **Coverage**, the closing section: a table mapping every `logic/`
  scenario, every `mockup/` and `design/screens/` screen, and every
  component in the index's module map to the build-order step that
  implements it. Anything deliberately excluded gets a row naming the
  recorded decision that excludes it. A row with no step is a gap in
  the plan; fix the plan, never the table.

Every code decision follows `code-prefs.md`, and every plan step and
line of code obeys `../code-craft.md` (TDD + YAGNI, earned
interfaces, and its Git section for every branch and commit this
stage makes; code-prefs wins on conflict): the layout and sketches
carry no layer, file, or abstraction the ladder didn't earn.

**Review, then re-review.** A drafted `implementation.md` is not
presentable until it survives full passes of this check, repeated
until a pass finds nothing to fix:

1. Re-open the source lists fresh (the index's module map, `logic/`'s
   scenario list, the `mockup/` and `design/screens/` file lists, the
   stack chapter's picks) and walk the Coverage table against them:
   every item has a step or a recorded exclusion.
2. Walk the build order: every step's dependencies (the components,
   interfaces, and data it consumes) are produced by an earlier step;
   the walking-skeleton slice is first; backend precedes the frontend
   that calls it.
3. Every step carries its verification, and every load-bearing seam
   its code sketch, checked against Phase A's research (the chosen
   stack's real APIs, not remembered ones).

Fix what a pass finds, then run the next full pass; a pass that found
anything voids the ones before it. Skipping or thinning a scenario,
screen, or component because the plan "covers it implicitly" is a
gap, not a judgment call.

## Phase B - the gate

Set `status: awaiting-formalization`; present the plan summary
(layout, build order, the first slice, and the Coverage table's
totals: N scenarios, N screens, N components, all mapped). The user
approves before any code is written. On approval, append the
changelog entry per core.md's ledger, key `build/plan@Q<n>` from
`build-interview.md`'s highest `### Q<n>`; record the approved module
layout, the build order starting with the walking-skeleton slice, and
the per-step verification method. Then record `plan_approved: true`
in the interview frontmatter; Phase C's coding sessions resume
against it.

## Phase C - write the code

**If the superpowers plugin is available** (its skills appear in your
skill list; missing on an interactive run, offer its install per
core-authoring.md's Delegation installs first): hand off. Invoke
`superpowers:writing-plans` with `implementation.md` plus the
reference as the spec (capstone's docs ARE the spec; skip superpowers'
brainstorming). The plan it writes must carry every
`implementation.md` step, in the same dependency order, with each
step's code sketches and verification intact: writing-plans expands
steps into tasks; it never merges, summarizes, or drops them. Before
executing, walk `implementation.md` step by step against the produced
plan and fix any step that was dropped, thinned, or reordered;
re-walk after fixes until a pass finds no gap. Then execute the plan
via whichever superpowers execution flow the user picks
(subagent-driven or inline).

**Otherwise**: execute `implementation.md` directly: smallest testable
steps, backend first, frontend second, verifying each step as the plan
specifies, honoring `code-prefs.md` throughout.

Either way, code lands in the repository's source tree (never under
the docs area). Append the changelog entry per core.md's ledger, key
`build/code@Q<n>`, same `<n>`; record which build-order steps are
complete, the source paths created, the dependencies installed, and
the divergences from `implementation.md`. Then set
`status: formalized` only when the walking-skeleton slice actually
runs.

## After

Point the user at the `sync` skill: as real code lands, refresh runs
flip the reference from prescriptive to observed, recording
divergences between the design and what was actually built.
