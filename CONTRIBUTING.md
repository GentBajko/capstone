# Contributing to Capstone

## Keeping the surface in sync

Each subcommand = `references/protocols/<name>.md` + a
wrapper skill at `skills/<name>/`; update both when the surface
changes, plus the core skill's `scripts/help.sh` and
`docs/commands.md`. Check 5c fails when a command is missing from
the reference: a command doc that silently omits a command is worse
than none, because it reads as complete.

A new command also owes a page at `docs/commands/<name>.md`, which
check 26 requires along with its four fixed headings in order
(`## What it does`, `## When to reach for it`, `## Common questions`,
`## It's working if`). `docs/commands.md` answers what a command's
arguments are; the page answers which command to reach for and how to
tell a run worked. Source the questions from `docs/commands.md`, the
README's caveats and upgrade notes, and the commit history for
anything renamed or removed - a question nobody has asked teaches
nobody, so a thin command earns one or two and never gets padded to
match a busier one. Installation lives in `README.md` alone; check 26
fails a page that repeats it.

## Running the lint

`scripts/lint-sync.sh` asserts every cross-file invariant. Run it
after any surface change; CI runs it on every push:

```sh
bash skills/core/scripts/lint-sync.sh
```

## The output schema

`skills/core/references/schema.txt` is the machine-readable form of the
format rules `references/topics.md` and the protocol files teach.
`map-check.sh` reads it at runtime. Change the schema and the prose in
the same commit: checks 15, 20 and 21 fail when a heading, a column or a
required key reads one way in the prose and another in the schema.

## Releasing

Bump the version in all six manifests (check 2), then in
`templates/capstone-map-check.yml`'s `--branch v<version>` (check 12g
ties the two), and tag the release commit `v<version>`: the CI gate
template clones that tag to get `map-check.sh`, so an untagged release
breaks every downstream gate with "no MAP CHECK verdict found". Lint
check 16 runs `map-check.sh` through a throwaway git repo on every
lint run; before tagging, run it once on a macOS machine as well,
since bash 3.2 is the floor the script promises.

## Every script is bash

There are no PowerShell twins, and check 8 fails if one reappears.
Windows is covered by Git Bash, which ships with Git for Windows and
is therefore present on any machine that can clone this repo - and
which `hooks.json` has always required anyway, since its SessionStart
command is an unconditional `bash`.

The twins were hand-mirrored, and every defect they ever had was a
sync defect rather than a logic one: checks silently absent, a block
appended after the `exit` where it could never run, unguarded `git`
calls. A lint that reports success while skipping its own checks is
worse than no lint. One implementation cannot drift.

## The shared rules are two files

`skills/core/references/core.md` holds what every run needs;
`core-authoring.md` holds what a run needs only to produce an output
(local-only outputs, the two legacy migrations, artifact seeding,
index maintenance). Every wrapper reads both, except `start` and
`feature`, which route rather than write and read `core.md` alone.
A rule added to the wrong file either costs every
command tokens it cannot use, or goes unread by a command that needs
it; `lint-sync` asserts the wiring, not the placement, so think about
which file a new rule belongs in.
