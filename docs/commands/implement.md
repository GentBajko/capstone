# `implement`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-feature-chain).

## What it does

`implement` executes an approved `plan.md` task by task with
verification after each one, in subagents or inline as you pick, then
reviews its own diff, refreshes the chapters the change affected, and
absorbs the shipped behavior back into `logic/`, `mockup/` and
`uiux/`.

A standalone invocation always asks **inline or subagents** before
prerequisite work or execution, including resumes with only review or
wrap left. When entered through `feature`, it carries that run's
answer. Inline covers every task, review and reference refresh, even
when subagent tools are available. Subagents use fresh contexts and
can consume your allowance faster; neither mode is chosen for you.

The review loop runs until two consecutive rounds find nothing new.
One clean round is not enough, because the round that fixes a finding
is the round most likely to introduce the next one. Only after that
does the wrap happen, and the wrap ends by deleting the feature folder
on the strength of the ledger entry it just wrote.

## When to reach for it

`/capstone:implement <feature>` when the feature's plan is approved.

Reach for `feature` instead to run `groom → plan → implement` in one
pass; reach for `build` when the project itself does not exist yet, as
that is the greenfield code stage rather than the per-feature one.

## Prerequisites

`plan_approved: true` in the feature interview's frontmatter. Without
it `implement` stops, writes its changelog entry, and says why: the
gate is what makes the code traceable to a spec you signed off.

## The wrap, and why the folder goes

After the review loop the run refreshes the affected reference
chapters, absorbs the spec into the scenario and surface docs, writes
one `implement/<id>@Q<n>` ledger entry, and deletes
`features/<date>-<slug>/`. The whole `features/` tree is gitignored
working state, so that entry is the only surviving record of why the
feature was built the way it was. The identifier is retired with it
and never reused.

## Common questions

**It deleted my feature folder.** That is the last step of the wrap,
and it happens only after the ledger entry is on disk. If you find the
folder still there while the ledger already carries its key, the wrap
died between the two and `doctor` finishes the delete.

**How many review rounds will it do?** As many as it takes for two
consecutive rounds to find nothing new. Each round's findings are
recorded in the feature's `review-ledger.md` while the folder still
exists, and the counts survive in the changelog entry.

**Why is the ledger committed when everything else in `features/`
is not?** Because the folder is deleted and the ledger is not. A
local-only ledger would turn that deletion into permanent loss on one
machine change.

## It's working if

The code is in the repository's source tree, the verifications named
in the plan pass, the chapters covering the touched paths carry fresh
stamps, the shipped behavior appears in `logic/` and the surface docs,
`features/<date>-<slug>/` is gone, and the ledger carries exactly one
`implement/<id>@Q<n>` entry for it.
