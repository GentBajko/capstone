# `architecture`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`architecture` is the big design interview for a project that does not
exist yet. It produces the same numbered chapters `map` writes, marked
`mode: prescriptive`, so the design is recorded in the shape the
reference will keep once code replaces intent.

The interview is done only when every section of those future chapters
is answerable from your recorded decisions. That criterion is why it
asks for things a chapter could otherwise infer, entity fields and
cross-repo payload shapes among them: an inferred field table is a
guess, and a guess is what the next contract check would compare
against.

## When to reach for it

`/capstone:architecture` on a greenfield project, normally as the
fourth stage of the pipeline after `mockup`, `logic` and `uiux`.

Reach for `map` instead the moment code exists. `map` observes and
replaces intent with what the code actually does; running the
interview over a built system records a design nobody has to follow.

## Prerequisites

Nothing is required, but the interview is much shorter with the
earlier stages in place: it pre-fills conventions answers from
`standards.md` and never re-asks them, and it draws on `logic/` and
`mockup/README.md` as questions touch them.

## Entities, payloads, and the far end of an edge

`02-models.md` gets one `### <Entity>` field table per entity, so the
interview asks for fields, types, optionality and accepted values
rather than inferring them. `09-interfaces.md` gets a row per planned
cross-repo edge with a `schema` resolving through those entity
sections. Where the design will talk to a system that already exists
and quarry is available, the interview looks that system up and writes
the planned edge from its recorded contract instead of from memory.

## Common questions

**Should I run this on a repository that already has code?** No, run
`map`. Once code exists, observation outranks intent, and `map`
rewrites the same chapters from what is actually there.

**Why is it asking for every field of every entity?** Because
`09-interfaces.md`'s payload sections resolve through them, and
`quarry check` compares a consumer's field list against exactly those
tables. A field the chapter inferred is a field nobody agreed to.

**Can I stop halfway?** Yes. Every answer is on disk before the next
question, and the run resumes at the first unanswered one.

## It's working if

The numbered chapters exist under `docs/capstone/` carrying
`mode: prescriptive`, `02-models.md` has a `### <Entity>` section per
entity with its field table, every open question in
`architecture-interview.md` is answered or recorded as deferred,
`status: formalized` is set, and the ledger carries one
`architecture/all@Q<n>` entry naming the one-way-door choices.
