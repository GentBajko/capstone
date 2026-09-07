# `start`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#start).

## What it does

`start` runs the greenfield pipeline one stage at a time:
`mockup → logic → uiux → architecture → standards → stack → build`.
It is also what a bare `capstone` with no argument triggers.

It reads which stages already finished off disk and resumes at the
first incomplete one, so running it again never re-asks a question you
have answered. Every answer is written to the stage's interview file
before the next question is asked, which is why a dead session costs
you the question in flight and nothing behind it.

## When to reach for it

`/capstone:start`, or just `capstone`, when the product does not exist
yet and you want the whole thing designed before any code is written.

Reach for `map` instead when the repository already has code: `map`
observes what is there, while the pipeline decides what should be. On
a repo that already has code, `start` asks once which of the two you
meant and records the answer as `pipeline` in
`docs/capstone/capstone.json`, so it never asks twice.

Reach for `feature` when the product is already designed and you want
one change taken to shipped code.

## The readback, between `stack` and `build`

Before `build`, the pipeline reads all six earlier stages' final
outputs in three passes. The first names what nobody asked: every item
of a stage's own inventory that no final output decides or rules out,
as one numbered digest. The second re-files what landed in the wrong
stage, a business rule sitting in an architecture chapter being the
usual case. The third raises what one final output says that
contradicts another.

The corrections land in the owning final outputs. Completed interview
bodies are not read or amended, because after formalization the
outputs are the source of truth and the interviews are only working
state.

## Common questions

**I typed `capstone` and it started interviewing me.** A bare
`capstone` with no argument routes to `start`. On a repo with code it
asks first which entry point you wanted.

**It skipped `uiux` entirely.** The mockup recorded no visual surface,
so there is nothing for the design stage to decide. Command-line and
API surfaces are recorded in the mockup and the stage skips itself.

**Can I run one stage on its own?** Yes. Every stage is individually
invocable and behaves the same way when entered mid-chain; `start`
only sequences them.

**Does `start` write a ledger entry?** Only for the readback pass,
which changes recorded decisions. Routing to a stage writes nothing;
the stage records itself.

## It's working if

Every stage's interview file reads `status: formalized` and its
outputs are on disk beside it, `docs/capstone/` holds `mockup/`,
`logic/`, `uiux/`, the numbered chapters, `standards.md` and
`05-dependencies.md`, and the ledger carries one entry per stage plus
a `readback/all@<stamp>` entry. The pipeline then stops at `build`'s
plan gate rather than writing code on its own.
