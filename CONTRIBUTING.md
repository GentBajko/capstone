# Contributing to Capstone

## Keeping the surface in sync

Each subcommand = `references/protocols/<name>.md` + a
wrapper skill at `skills/<name>/`; update both when the surface
changes, plus the core skill's `scripts/help.sh` AND
`scripts/help.ps1` (same usage text, kept in sync: one per platform).
Every script that runs on a *user's* machine ships as .sh (Unix/Git
Bash) and .ps1 (Windows) pairs. Two are bash-only: `help-hook.sh`,
because `hooks.json` invokes bash explicitly, and `lint-sync.sh`,
below.

## Running the lint

`scripts/lint-sync.sh` asserts every cross-file invariant. Run it
after any surface change; CI runs it on every push:

```sh
bash skills/core/scripts/lint-sync.sh
```

**It is bash-only, deliberately, and has no `.ps1` twin.** It never
runs on a user machine - only here and in CI - and Windows is covered
by Git Bash, which ships with Git for Windows and is therefore already
present on any machine that can clone this repo. The twin it used to
have was hand-mirrored, and every defect it ever had was a sync
defect rather than a logic one: checks silently absent, or appended
after the `exit` where they never ran. A lint that reports success
while skipping its own checks is worse than no lint, so there is one
implementation. `lint-sync` fails if the `.ps1` reappears.

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
