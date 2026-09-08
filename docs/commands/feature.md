# `feature`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#feature-description).

## What it does

`feature` takes one idea to shipped code by running the feature chain
`groom → plan → implement` consecutively, stopping at each stage's own
gate.

It detects which stage a feature is at from what is on disk and
resumes at the first unfinished one, so the same command works for a
new idea, a spec you approved yesterday, and a plan half executed.
`feature` routes rather than writes: it owns no output of its own, and
every artifact and ledger entry belongs to the stage that produced it.

## When to reach for it

`/capstone:feature add CSV export` for a new feature, or with a slug
for one already in flight. With no argument it lists the features in
flight and asks which you meant.

Reach for `groom` when you want the spec and nothing further; that is
the same first stage without the chain behind it. Reach for `start`
when the whole product is what needs designing, since the greenfield
pipeline is a different chain entirely.

## Prerequisites

Capstone docs for the project, since `groom` interviews against them.
Where there is no index, `groom` builds the reference first rather
than refusing, so this resolves itself at the cost of a `map` run.

## Execution choice and approvals

Every new or resumed run first asks **inline or subagents** and waits
for your answer. Inline avoids extra agent usage; subagents use fresh
contexts and can consume your allowance faster. Your choice covers
the whole chain, including reference setup, planning, reviews and
refreshes. It is carried between stages, with no automatic default.

The stage approvals remain separate. `groom` stops for
spec approval. `plan` stops for plan approval, recorded with a
checksum of the spec, and no code is written before it. `implement`
runs to completion after that, reviewing its own diff until two
consecutive rounds find nothing new.

## Common questions

**This used to be called `implementation`.** The chain runner was
renamed to `feature`, which is what it actually operates on. Old
`implementation` keys in `changelog.md` are history and nothing reads
them.

**My session died mid-chain.** Run the same command again. It reads
the feature's state off disk and resumes at the first unfinished
stage, and interview answers are written before the next question.
You choose inline or subagents again for the resumed run; saved
progress and plan approvals still stand.

**Can two features run in parallel?** Their ids are derived from the
groom date and slug rather than allocated from a counter, so two
branches cannot mint the same one, and each ledger entry lands as its
own `changelog.d/` fragment. The docs area itself is still
single-writer: two capstone runs writing it at once will interleave.

## It's working if

The feature reached `implement` and finished it: the code is in the
source tree, `features/<date>-<slug>/` is gone, and the ledger carries
`groom/<id>`, `plan/<id>` and `implement/<id>` entries at the same id.
A chain stopped at a gate is waiting on you, and re-running the same
command resumes there.
