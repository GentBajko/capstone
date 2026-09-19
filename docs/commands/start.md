# `start`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#start).

## What it does

`start` runs the greenfield pipeline one stage at a time:
`mockup → logic → uiux → architecture → standards → stack → build`.
It is also what a bare `capstone` with no argument triggers.

It reads which stages already finished off disk and resumes at the
first incomplete one, preserving the design answers you have already
given. Every answer is written to the stage's interview file
before the next question is asked, which is why a dead session costs
you the question in flight and nothing behind it.

Every new or resumed run first asks **inline or subagents** and waits
for your answer. Inline avoids extra agent usage; subagents use fresh
contexts and can consume your allowance faster. The answer covers
all stages, research, readback, build and any reviews or reference
refreshes. Stage handoffs keep that choice; a later invocation asks
again instead of treating the previous run's choice as permission.

## When to reach for it

`/capstone:start`, or just `capstone`, when the product does not exist
yet and you want the whole thing designed before any code is written.

`/capstone:start <stage>` when you want one stage and not the chain.
The stage words are `mockup`, `logic`, `uiux`, `architecture`,
`standards`, `stack` and `build`. None of them is a command of its
own: capstone has nine commands, and running a stage outside its chain
is the exception rather than the entry point, which is what the second
word says. (`retro` is not among them - it is
[`review retro`](review.md#review-retro), because a session ends under
every command, not just the pipeline.)

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


## The stages

Each one runs exactly what the pipeline would have run at that point,
then stops: it reads its own prerequisites, runs its own formalization
gate, writes its own changelog entry, and does not run the stage after
it or the readback pass. Entering a stage whose prerequisite is
missing gets you the name of the stage that owns the missing input,
not an interview for it. Interview stages take an optional artifact
argument - a PRD, notes, screenshots - and pre-fill every answer that
artifact settles, for you to confirm rather than to trust silently.

**`start mockup`** is product discovery. Three fixed questions, then
every question after that is generated from your answers until nothing
is left to invent. One file per screen in `docs/capstone/mockup/`: an
ASCII wireframe, the elements and where they lead, the states that
screen has. It depicts rather than decides - the moment an answer
would be a rule (a threshold, a formula, what happens when the payment
fails) it names the behavior, logs the question `for: logic`, and
moves on, because a number invented here would outrank nothing and be
contradicted later. Its `README.md` hands `logic` a scenario list
written at `logic`'s own unit, which is what makes the next stage
fast. A product with no screens records its surfaces (api, cli)
instead, and `uiux` then skips itself.

**`start logic`** pins down one scenario at a time, depth first, until
a developer could implement it without inventing a rule. Every
scenario is swept against sixteen rule dimensions and is finished only
when each is answered, cited to an earlier scenario, or recorded
inapplicable with its reason - which is what catches the rules with no
natural question behind them.

**`start uiux`** needs a formalized `mockup`. Visual direction, the
design system and tokens, then per-screen composition and states. On a
repo that already has a frontend it runs in extraction mode instead,
documenting the design that exists. Before its gate it writes
`uiux/preview.html` and asks you to approve a first-pass logo and page
mockup.

**`start architecture`** is the big design interview, done only when
every section of the future docs is answerable from your recorded
decisions. It writes the numbered chapters marked `mode:
prescriptive`. Note that `map architecture` is a different thing: there
the topic name wins and it regenerates `01-architecture.md` from the
code.

**`start standards`** sweeps seventeen domains and produces the
normative `standards.md`: binding rules you decided, which outrank
generic best practice. Not a description of what the code currently
does - that is the reference's own conventions chapter.

**`start stack`** derives the capability list from your own documents
rather than a stock list, then brings each capability back as two to
four researched options with licenses and pricing, plus writing it
yourselves priced in code and maintenance. You pick.
**`start stack refresh`** re-vets the recorded picks later:
maintenance, license and pricing deltas.

**`start build`** needs a formalized `stack`. It writes
`implementation.md`, stops for your approval, then writes code. With
`implement`, one of the only two commands allowed to write source.

## Common questions

**I typed `capstone` and it started interviewing me.** A bare
`capstone` with no argument routes to `start`. On a repo with code it
asks first which entry point you wanted.

**It skipped `uiux` entirely.** The mockup recorded no visual surface,
so there is nothing for the design stage to decide. Command-line and
API surfaces are recorded in the mockup and the stage skips itself.

**Can I run one stage on its own?** Yes: `start <stage>`. It behaves
the same way entered mid-chain; `start` only sequences them. There is
no `/capstone:mockup` - a bare stage word is not a command, and the
harness routes it here.

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
