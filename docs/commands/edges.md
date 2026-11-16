# `edges`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#edges).

## What it does

`edges` fills in which repo each consumed contract comes from. `map`
cannot: it reads one repo, and a repo holds the address it calls,
never the name of the repo that answers. With every repo of a system
cloned into one folder the answer is on disk, so `edges` reads the
folder once and writes the missing `from` into each consumer's
`09-interfaces.md`.

For each consumes row with no `from` it opens the code at the row's
`site`, finds the address the call goes to, follows it through env
vars and deploy config across the clones, and matches it against each
repo's name and `known_as`. Where the code holds no address, as with
a queue or a topic, it takes the only repo in the folder that
produces the contract. It writes a row only when exactly one repo is
left.

## When to reach for it

`/capstone:edges` from the folder that holds the clones, after `map`
has run in each one. `/capstone:edges <folder>` from anywhere else.
Run it again when a repo joins the folder or a `map` run adds a
consumes row.

Reach for `map interfaces` instead when the question is what one repo
produces and consumes: `edges` adds no rows, it only answers where
existing ones lead. And it does not replace quarry, which joins the
same rows by name across every registered repo; `edges` settles what
a name alone cannot, and puts the answer in the docs.

## Prerequisites

Two or more clones in one folder, each with a reference `map` has
built. A clone needs an origin remote to be named as a far end. An
unmapped clone is reported and skipped, never mapped on the spot.
Quarry is not needed.

## Common questions

**It left a row empty.** Then the evidence did not leave exactly one
repo. The report says which case it was: an address no clone answers
to, several candidates, or no producer in the folder. Clone the
missing repo and run it again, or write the cell yourself.

**Why does the producer's page not list its consumers?** Because
`edges` never writes `to`. Quarry builds a producer's edges from the
consumers that name it, and a written `to` would take the row out of
its name join, so a consumer the folder does not hold would find no
producer and nothing would say so. `quarry docs deps <repo>
--downstream` lists them.

**It wrote the wrong repo.** Correct the cell by hand; the value is
yours from then on and no run changes it. The ledger entry in that
repo says what the choice rested on.

**It says a `from` I wrote disagrees with the code.** It reports and
leaves the cell alone. An answer already in the block is never
edited, by `edges` or by `map`.

**It changed several repos.** One `09-interfaces.md` and one ledger
fragment in each repo where it filled something. Nothing is
committed; each repo needs its own commit before quarry can import
the result.

## It's working if

Every consumes row whose far end sits in the folder carries its
`from`, the `From` cell in the table says the same, and each changed
repo has an `edges/09-interfaces.md@<rev>` entry naming the evidence
for every row. A second run over the same folder writes nothing and
says so.
