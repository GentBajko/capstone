# `stack`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`stack` picks the concrete libraries, packages and paid services, one
capability at a time, and records the picks with their rationale into
`docs/capstone/05-dependencies.md`.

The capability list is derived from your own documents rather than
from a stock checklist: every External services row, every
Communication channel, every store and queue in the data-flow chapter,
every process and environment variable in the operations chapter,
every logic scenario that reaches outside the process, and the design
system's commitments. Each row is shown with the source that produced
it, and you add or strike before any research starts.

## When to reach for it

`/capstone:stack` once the architecture chapters exist, and
`stack refresh` months later to re-vet what you picked.

Reach for `map dependencies` instead when you want the packages that
are actually installed written up; `stack` decides what to install,
`map` reports what is there.

## Prerequisites

The chapters the capability list is derived from: `01-architecture.md`,
`04-data-flow.md`, `07-operations.md`, plus `logic/` and
`standards.md` where they exist. Without them there is nothing to
derive the list from and you would be picking against a stock list,
which is the thing this stage exists to avoid.

## Options, including writing it yourselves

Every capability reaches you as two to four researched options with
licenses and pricing, plus one more in every list: write it ourselves,
priced in code and in what the project then maintains. The craft
file's ladder recommends a rung and names it; you pick. The research
is written into the chapter whether or not you pick that option, so it
does not vanish because the code has not been written yet.

## Common questions

**Where does the capability list come from?** Your own chapters, row
by row, each shown with the source that produced it. That is why a
capability your design does not imply never appears, and why one it
does imply cannot be quietly skipped.

**My picks are a year old.** `stack refresh` re-vets them:
maintenance, license and pricing deltas against the recorded research
dates, written back into the same chapter under the
`stack/refresh@Q<n>` key.

**Building it ourselves isn't offered.** It always is. If a list
reached you without it, that is a defect in the run.

## It's working if

`docs/capstone/05-dependencies.md` names one pick per derived
capability with its license, its price and the rationale inline,
including the options rejected; `stack-interview.md` reads
`status: formalized`; and the ledger carries a `stack/all@Q<n>` entry
recording the capability list and the rejections.
