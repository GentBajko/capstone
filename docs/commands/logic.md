# `logic`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`logic` pins down the business rules one scenario at a time, walked
until a developer could implement the scenario without inventing a
single rule: the trigger, the exact steps, the real formulas, the
branches, what happens when the payment fails or the user clicks
twice. One file per scenario in `docs/capstone/logic/`.

A scenario is finished when all sixteen of the craft file's rule
dimensions are answered, cited to an earlier scenario, or recorded
inapplicable with a reason. Not when nothing else comes to mind. The
dimensions generate the questions rather than being asked as
questions, so what does not apply is confirmed in one batch instead of
sixteen turns, and a rule nobody thought to ask about stops reading
exactly like a rule that does not exist.

## When to reach for it

`/capstone:logic` after `mockup`, or on its own once there is a
scenario list to work from. On a repository that already has code it
runs in reverse: it drafts each scenario from the observed behavior
and you confirm or correct.

Reach for `groom` instead when the rules are already recorded and you
want one new feature specified against them.

## Prerequisites

`mockup/README.md`'s Scenarios table and its `for: logic` threads are
what `logic` works from. Without them it can still run, but you will
be supplying the scenario list yourself.

## The dimensions that catch what you would not ask

Authority, money, concurrency, time, failure, what the system
deliberately hides, what it deliberately never says, and nine more.
These are the rules with no natural question behind them: who eats the
cost when a charge fails after the money moved, what the interface
shows a user who is not allowed to know. Each scenario file records
which dimensions it ruled out and why, so a later reader can tell "no
money here" from "nobody asked".

## Common questions

**How long does this take?** Budget an afternoon for a real app. The
depth is the entire point of the stage, and everything downstream
reads it.

**It asked about concurrency for a form with one user.** It asks once
and takes "not in play" for an answer, recorded with your reason.
Confirming a dimension away is cheap; discovering it was never
considered is not.

**My code already implements these rules.** Then run it on the
existing repository and it drafts from the code for you to confirm,
rather than interviewing from scratch.

## It's working if

`docs/capstone/logic/` holds one file per scenario, each carrying its
rules, its unhappy paths, and a `Dimensions not in play` record; the
checklist in `logic-interview.md` shows every scenario as `written` or
`dropped` with a reason; and the ledger carries one
`logic/<NN>-<scenario>@Q<n>` entry per scenario rather than one for
the stage.
