# `plan`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-feature-chain).

## What it does

`plan` turns a groomed spec into `plan.md`: task-by-task TDD steps an
engineer with zero context could execute, in dependency order, each
with the test that proves it.

Your approval is recorded with a checksum of the spec it was written
against. Editing the spec afterwards voids the approval rather than
leaving a plan that quietly no longer matches, and the next run drops
the stale keys and re-plans. A plan is only as good as the spec it was
derived from, so the link between them is made checkable instead of
assumed.

## When to reach for it

`/capstone:plan <feature>` after `groom`, naming the feature by slug.

Reach for `feature` instead to run the chain end to end; reach for
`implement` when a plan is already approved and you want it executed.
`plan` writes and gates, and writes no code at all.

## Prerequisites

An approved `spec.md` for the feature. `plan` reads it, then the
chapters, scenarios and screens the spec cites, then `standards.md`
and the conventions and testing chapters, so the tasks come out in
this project's idiom rather than a generic one.

## The ladder, and what it removes

Every task is trimmed against the craft file's ladder before it enters
the plan: does this need to exist at all, is it already here, does the
standard library or the platform cover it, can it be one line. Your
`standards.md` outranks the ladder, but only by a decision that names
what it overrides; a silent conflict resolves to the ladder.

## Common questions

**I edited the spec after approving the plan.** The approval is void.
The checksum no longer matches, and the next run drops the approval
keys and re-plans against the spec as it now reads.

**The plan looks smaller than I expected.** The ladder trims
speculative work. If something was cut that you need, say so and
record the decision: an override that names what it overrides is
respected, an unexplained one is not.

**Can `implement` start without this?** No. `implement` requires
`plan_approved: true` in the feature interview's frontmatter, so an
unapproved plan stops it before the first task.

## It's working if

`docs/capstone/features/<date>-<slug>/plan.md` lists tasks in
dependency order, each naming the files it touches and the test that
proves it, the feature interview carries `plan_approved: true` and an
`approved_spec` checksum, and the ledger carries a `plan/<id>@Q<n>`
entry recording the file map, the task count and the constraints
pinned.
