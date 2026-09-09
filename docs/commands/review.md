# `review`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#review).

## What it does

`review` is the one capstone command allowed to have opinions about
your code, and it has them only because you asked. It writes
severity-ranked findings with evidence into
`docs/capstone/review.md`, one section per side, each carrying its own
stamp.

Your recorded decisions outrank the craft baseline it judges by. A
divergence from that baseline is a finding only when the reference and
`standards.md` do not already justify the choice; where they do,
`review` shows both and lets you rule. That is what stops it turning
into a generic linter with prose.

## When to reach for it

`/capstone:review` runs both sides, backend first. `review backend`
(or `be`) takes architecture and backend alone; `review frontend`
(or `fe`) grades the UI against your own design docs. A one-sided run
rewrites only its own section and leaves the other side's stamp
untouched.

Reach for `map check` instead when you want to know whether the docs
are still true; that is a fact question and writes no judgment. Reach
for `retro` when the thing you want improved is the agent's
instructions rather than the code.

A project with no visual surface skips the frontend side on a bare run
and records the section as not applicable.

## Prerequisites

The backend side needs a current reference, and refreshes it first if
it is stale, because judgment resting on stale facts is worse than no
judgment. The frontend side works better with `docs/capstone/uiux/` in
place: without it the findings rest on the craft floor alone, and the
run says so rather than blocking.

## The three bars, in confidence order

The frontend side judges each surface first against your own
commitments (the tokens, interaction rules and screen chapters you
signed off), then against the vendored craft floor, then against the
surface's mode. Highest confidence sits with the first bar, because
you already decided that standard and the critique only holds the code
to it. One claim gets one bar, its strongest.

## Common questions

**Why isn't `review.md` in git?** It is gitignored by default. It is
judgment, and a regenerable one; the factual reference is what gets
committed.

**I have `be-review.md` and `fe-review.md` from an older version.**
They are superseded. The two commands merged into one two-sided
`review`, nothing is carried over from the old files, and the run
offers to delete them rather than deleting them for you.

**Does it edit code?** Never. An accepted finding becomes a change by
entering the feature chain, which gates and traces it.

**It flagged something my standards explicitly allow.** Report it: on
the backend side that is a defect in the run, since the rule is that a
recorded decision beats generic best practice, and the run is meant to
show both rather than rule for the craft file.

## It's working if

`docs/capstone/review.md` opens with the judgment banner, every
section you asked for carries a fresh stamp line, and the sides you
did not run still show their old stamps rather than vanishing. Every
finding names its evidence as a `file:line` or a screenshot, and the
ledger carries one `review/<side>@<stamp>` entry with the counts per
severity band.
