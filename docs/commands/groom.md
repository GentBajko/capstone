# `groom`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-feature-chain).

## What it does

`groom` interviews one feature into a spec and writes it to
`docs/capstone/features/<date>-<slug>/spec.md`, with every requirement
traced to the recorded decision it rests on.

It interviews against the docs you already have, so it never asks what
a chapter answers. The reference tells it where the code lives and how
this project does things; the interview spends its questions on what
only you can decide. That is why the same feature takes far fewer
turns here than in a blank-page conversation, and why the spec can
cite a chapter instead of restating it.

## When to reach for it

`/capstone:groom add CSV export`, or with a slug to resume an existing
feature. It is the first stage of the feature chain.

Reach for `feature` instead when you want the whole chain in one run:
`feature` chains `groom → plan → implement` and resumes at whichever
stage is unfinished, while `groom` stops at the spec. Reach for
`mockup` when the product itself is not defined yet, since `groom`
grooms one change to something that already exists.

## Prerequisites

A stamped `00-index.md`. Without one, `groom` builds the reference
first rather than refusing, so the missing prerequisite costs a `map`
run and not an error message.

## The staleness pass, before the first question

`groom` checks the chapters the feature touches against the working
tree before it interviews, so the questions rest on facts rather than
on a stale chapter. Chapters that drifted get refreshed first.

With `cross_repo: "auto"` and quarry installed, it also asks quarry
what consumes this repository and reads each consumer's contract
section, so a feature that changes a shared endpoint reaches the
interview with its downstream constraints already known.

## Common questions

**It went and built the whole reference first.** That is the missing
reference rule: a command that needs the reference and finds none
builds it rather than sending you off to run something else.

**It never asked me about the database.** Because `02-models.md`
already answers it. Anything the docs settle is read, not asked.

**Which repository name does it send to quarry?** The origin's last
segment, unless `workspaces` is configured, in which case it is the
workspace whose path contains the files the feature touches. That
workspace name is also its target name in the quarry docs repo.

**The whole `features/` folder is gitignored.** Deliberately. It is
working state; once `implement` finishes, the ledger entry is the
surviving record, which is why the ledger is always committed.

## It's working if

`docs/capstone/features/<date>-<slug>/spec.md` exists, every
requirement in it cites the chapter, scenario or screen it rests on,
the out-of-scope rulings are written down rather than implied, and the
ledger carries a `groom/<id>@Q<n>` entry naming the chosen approach
and the alternatives rejected.
