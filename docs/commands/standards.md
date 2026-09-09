# `standards`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`standards` interviews out the rules code must follow in this project
and writes them to `docs/capstone/standards.md`: typing strictness,
what earns a dependency, error handling, testing style, branch and
commit discipline, and what an AI assistant must never do here.

The output is binding rather than descriptive. It records the rules
you decided, so it outranks generic best practice and never describes
what the code currently does; the observed conventions live in
`03-conventions.md`, written by `map`. The two files answer different
questions and disagreeing is a legitimate state, which `review` then
reports as a divergence.

## When to reach for it

`/capstone:standards` at any point, on greenfield or on an existing
repository. Nothing else in the pipeline blocks on it, and several
stages read it when it is there.

Reach for `map conventions` instead when you want to know what the
code does today. Reach for `retro` when a session has already given
you evidence that a specific rule is missing; `standards` decides the
rules from scratch, `retro` proposes them from what went wrong.

## The sweep, and why most items are never asked

The interview walks seventeen domains from an inventory: the nine it
always covered, plus security, logging and privacy, API conventions,
accessibility, performance budgets, documentation, versioning and
release, and CI gates. Each item carries the probe that turns it into
a question and the craft-file rule it defaults to, so most items are
settled by an earlier answer or by that default and are confirmed in a
batch rather than asked.

It finishes when every item is answered, cited to the craft file as
accepted unchanged, or written into `standards.md`'s closing
`## Not in play` with its reason.

## Common questions

**This used to be called `code-prefs`.** It was renamed to
`standards` when the output became normative rather than a list of
preferences.

**Isn't this what `03-conventions.md` already holds?**
`03-conventions.md` describes how the code is written today, observed
by `map`. `standards.md` states how it must be written, decided by
you. Where they disagree, the reference is the fact and the standards
are the target.

**Should I copy it into `CLAUDE.md`?** The stage suggests exactly that
and never does it unasked. `standards.md` stays the source and the
agent file mirrors it, so the precedence rule is worth writing down in
the Agent rules domain while you are there.

**A domain does not apply to my project.** Its heading is still
written, holding one sentence pointing at the `Not in play` line for
it, so a reader who opens the file for the API rules finds an answer
where they looked.

## It's working if

`docs/capstone/standards.md` carries one `## ` heading per domain in
the inventory's order plus a closing `## Not in play` that lists every
ruled-out item with its reason, the banner names the file as binding
rather than descriptive, `standards-interview.md` reads
`status: formalized`, and the ledger carries one `standards/all@Q<n>`
entry.
