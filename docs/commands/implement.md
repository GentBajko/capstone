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
does the wrap happen, and the wrap applies `delete_feature_folders`:
the default retains the folder, while `true` deletes it after the
ledger entry and done marker are written.

## When to reach for it

`/capstone:implement <feature>` when the feature's plan is approved.

Reach for `feature` instead to run `groom → plan → implement` in one
pass; reach for `build` when the project itself does not exist yet, as
that is the greenfield code stage rather than the per-feature one.

## Prerequisites

`plan_approved: true` in the feature interview's frontmatter. Without
it `implement` stops, writes its changelog entry, and says why: the
gate is what makes the code traceable to a spec you signed off.

## The wrap and feature-folder retention

After the review loop the run refreshes the affected reference
chapters, absorbs the spec into the scenario and surface docs, writes
one `implement/<id>@Q<n>` ledger entry, and then applies the
`delete_feature_folders` setting. Its default `false` retains
`features/<date>-<slug>/` as ignored local history; `true` deletes it.
The identifier is retired by the ledger key in either mode and never
reused.

## Common questions

**What happens to my feature folder?** `delete_feature_folders` is
`false` by default, so the completed folder remains as ignored local
history. Set it to `true` to delete it after the ledger entry and done
marker are on disk. A retained folder is complete and is not re-run.

**How many review rounds will it do?** As many as it takes for two
consecutive rounds to find nothing new. Each round's findings are
recorded in the feature's `review-ledger.md` while the folder still
exists, and the counts survive in the changelog entry.

**Why is the ledger committed when everything else in `features/`
is not?** It is the durable shipped-feature marker and remains the
source of truth whether the local folder is retained or deleted.

## It's working if

The code is in the repository's source tree, the verifications named
in the plan pass, the chapters covering the touched paths carry fresh
stamps, the shipped behavior appears in `logic/` and the surface docs,
the feature folder follows `delete_feature_folders`, and the ledger
carries exactly one `implement/<id>@Q<n>` entry for it.
