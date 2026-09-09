# `retro`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#retro).

## What it does

`retro` reads a finished session and proposes changes to the files the
agent worked from: `standards.md`, the reference chapters, the checks
a machine could run, and the project's `AGENTS.md` or `CLAUDE.md`.
`review` judges the code that came out; `retro` judges what went in.

Every finding has to cite something that happened in the session. A
category with no evidence behind it is reported clear in one line
rather than filled with a plausible-sounding suggestion, and a finding
is never carried forward from an earlier run. That single rule is what
keeps the output from becoming a list of best practices nobody asked
for.

## When to reach for it

`/capstone:retro` at the end of a working session, or
`/capstone:retro <session>` to read one the harness can resolve by
name. A harness that cannot open a past session says so and runs
against the session in progress.

Reach for `standards` instead when you want to decide the rules from
scratch through an interview; `retro` only proposes rules the session
gave it evidence for. Reach for `doctor` when the docs area is
inconsistent with itself, which is a different question entirely.

## The seven candidates

Navigation covers a fact the reference already held that the run
reached late. Automated checks cover a defect a linter, type rule or
test could have caught instead of a person. Standards rules cover a
rule to add, remove or sharpen, named to the domain that owns it.
Steering-file bloat covers a line in `AGENTS.md` that belongs in
`standards.md` or in a check. Tool economy covers repeated or
expensive calls a recorded command would replace. No-ops cover a
steering rule the session had occasion to apply and would have
satisfied without. Information access covers what the agent needed and
could not reach at all.

## Where a new rule lands

The implementing agent holds the plan, the diff, the tests and the
standards at once, and every sentence added to its instructions
competes with the work. A reviewer starts fresh and sees only a diff,
so a rule placed there costs nothing until it fires. `retro` puts a
new rule with the reviewer wherever a reviewer can check it, and says
so in the table when a candidate could have gone either way.

## Common questions

**Why won't it edit my `AGENTS.md` for me?** Capstone commands write
the configured docs area and nothing else. `standards.md` is inside
it, so approved rules land there directly; `AGENTS.md`, linter
configs, workflows and test files are outside it, so those edits come
back as exact text for you to place.

**It reported four of the seven categories clear.** That is the
expected shape of a short session. Padding a category with a
suggestion the session gave no evidence for would teach the next
reader nothing and cost them a real finding's attention.

## It's working if

You get one findings table ordered by severity, every row carrying
evidence you recognize from the session, and you approved or skipped
each row on its own rather than as a batch. Rules you approved are in
`docs/capstone/standards.md` under the domain that owns them. A run
whose findings you all declined leaves no ledger entry and says so;
one that changed `standards.md` leaves exactly one
`retro/<scope>@<stamp>` entry.
