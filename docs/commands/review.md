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

`review retro` is the third axis and the one argument that is not a
side: reach for it when the thing you want improved is the agent's
instructions rather than the code.

Reach for `map check` instead when you want to know whether the docs
are still true; that is a fact question and writes no judgment.

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

## `review retro`

Not a stage. `review` judges the code; `retro` judges what the agent
had to work with. It reads a finished session for evidence and walks
seven candidates - reference navigation, checks a machine could run
instead of a human, standards rules to add or sharpen, steering-file
lines that belong elsewhere, repeated calls a recorded command would
replace, rules that changed no behavior, and facts the agent needed
and could not reach - each needing evidence from that session. A
candidate with no evidence is reported clear rather than filled in.

You approve findings one row at a time. Approved rules land in
`standards.md` under the domain that owns them; anything outside the
docs area comes back as text to paste, because no capstone command
writes there.

It lives under `review` because `review` is the opt-in judgment
command and this is its third axis, and because a session ends under
every command: a project that was mapped rather than designed never
runs the pipeline at all. Nothing runs it on your behalf - `start`,
`feature` and `implement` each name it when they finish, and stop.

It writes `retro/<scope>@<stamp>` only when it actually changed
`standards.md`. A run whose findings are all declined writes nothing.

It is not a side, so it never rewrites `review.md` or touches either
side's stamp. `review retro` and `review backend` share a command,
not an output.

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
