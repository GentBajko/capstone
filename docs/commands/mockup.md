# `mockup`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`mockup` is product discovery. Three fixed questions, then every
question after that is generated from your answers until nothing is
left to invent. It writes one file per screen into
`docs/capstone/mockup/`: an ASCII wireframe, the elements and where
they lead, and the states that screen has.

It depicts rather than decides. The moment an answer would be a rule
(a threshold, a formula, what happens when the payment fails) it names
the behavior, logs the question as `for: logic`, and moves on. A
number invented here would outrank nothing and be contradicted by
`logic` later, so the state is marked `rule: logic` and left open on
purpose.

## When to reach for it

`/capstone:mockup` as the first stage of the greenfield pipeline, or
on its own when you want the product described before deciding
anything else. It takes an optional artifact argument: a PRD, notes,
screenshots, whatever you have, and it pre-fills every answer that
artifact settles for you to confirm.

Reach for `groom` instead when the product already has capstone docs
and you want one feature specified against them. `mockup` is
whole-product discovery, `groom` is one change.

## What it hands to `logic`

`mockup/README.md` indexes the screens and the journeys, and carries a
Scenarios table written at the unit `logic` works in. That list, plus
every `for: logic` thread it logged, is what makes the next stage
fast: `logic` starts from a list of things the product has to decide
rather than from a blank page.

## Common questions

**It refused to pick a number for me.** By design. A threshold or a
formula is a rule, and rules belong to `logic`. The mockup names the
behavior and hands the question on.

**I have a PRD already.** Pass it as the argument. The interview
pre-fills whatever the document answers and asks you to confirm each
one rather than trusting it silently.

**My product has no screens.** It records your surfaces instead (api,
cli), and the `uiux` stage then skips itself.

## It's working if

`docs/capstone/mockup/` holds one file per screen plus a `README.md`
indexing the screens, the journeys and the scenario list, every state
whose rule is unsettled is marked `rule: logic` rather than filled in,
and `mockup-interview.md` reads `status: formalized`. The ledger
carries one `mockup/all@Q<n>` entry.
