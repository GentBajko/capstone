# `build`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`build` turns a finished design into working code. It researches how
the chosen stack actually connects, writes `implementation.md` as a
step-by-step plan with the backend before the frontend, and then
writes the source.

It stops for your approval between the plan and the first line of
code. `build` and `implement` are the only two capstone commands
allowed to write source at all, and both only after their plan gates,
which is the whole reason the reference can be trusted as descriptive
everywhere else.

## When to reach for it

`/capstone:build` as the last stage of the greenfield pipeline, once
`stack` is formalized. It is what `start` routes to after the
readback.

Reach for `implement` instead when the project already exists and one
approved feature plan is what you want executed. `build` stands up the
project; `implement` grows it.

## Prerequisites

A formalized `stack`, since the implementation research is about the
libraries you actually picked. `build` also reads `logic/`,
`mockup/`, `uiux/` and `standards.md`, and stops on an `awaited` row
in `uiux/02-system.md`'s `## Assets` table rather than inventing a
brand file.

## The gate, and how the code gets written

The plan lands in `docs/capstone/implementation.md` and the run stops
there. Nothing is written until you approve it.

Before research or prerequisite work, a standalone `build` always
asks whether to work inline or use subagents, including when you
resume. In the greenfield pipeline it carries the answer already
given to `start`. That choice applies throughout the run, including
plan review and coding. Code lands in the repository's own source
tree, never under the docs area.

## Common questions

**Will it write code without asking?** No. The plan gate stops the run
and the approval is explicit.

**Subagents or inline: which should I pick?** Subagents give each step
a fresh context and can consume your allowance faster; inline keeps
everything in one conversation and avoids extra agent usage. There
is no automatic default, and each new run asks again.

**It stopped saying an asset is awaited.** `02-system.md`'s
`## Assets` table marks each brand file `present` or `awaited`, and an
`awaited` row is a real blocker: supply the file or change the row.

**It diverged from `implementation.md`.** The divergences are recorded
in the ledger entry under `build/code@Q<n>`, alongside the source
paths created and the dependencies installed.

## It's working if

`docs/capstone/implementation.md` holds the plan you approved, source
code exists in the repository's own tree and not under the docs area,
the dependencies named in `05-dependencies.md` are the ones actually
installed, and the ledger carries both `build/plan@Q<n>` and
`build/code@Q<n>` entries.
