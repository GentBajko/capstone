# Contributing to Capstone

## Keeping the surface in sync

Each subcommand = `references/protocols/<name>.md` + a
wrapper skill at `skills/<name>/`; update both when the surface
changes, plus the core skill's `scripts/help.sh` and
`docs/commands.md`. Check 5c fails when a command is missing from
the reference: a command doc that silently omits a command is worse
than none, because it reads as complete.

## Running the lint

`scripts/lint-sync.sh` asserts every cross-file invariant. Run it
after any surface change; CI runs it on every push:

```sh
bash skills/core/scripts/lint-sync.sh
```

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
