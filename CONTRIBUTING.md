# Contributing to Capstone

## Keeping the surface in sync

Each subcommand = `references/protocols/<name>.md` + a
wrapper skill at `skills/<name>/`; update both when the surface
changes, plus the core skill's `scripts/help.sh` AND
`scripts/help.ps1` (same usage text, kept in sync: one per platform).
Every script in this plugin ships as .sh (Unix/Git Bash) and .ps1
(Windows) pairs; sole exception: `help-hook.sh` is bash-only because
`hooks.json` invokes bash explicitly. `scripts/lint-sync.sh` (same
directory; and `.ps1`) asserts every cross-file invariant; run it
after any surface change; CI runs it on every push.

## The shared rules are two files

`skills/core/references/core.md` holds what every run needs;
`core-authoring.md` holds what a run needs only to produce an output
(local-only outputs, the legacy migrations, artifact seeding,
delegation installs, index maintenance). Every wrapper reads both,
except `start` and `implementation`, which route rather than write and
read `core.md` alone. A rule added to the wrong file either costs every
command tokens it cannot use, or goes unread by a command that needs
it; `lint-sync` asserts the wiring, not the placement, so think about
which file a new rule belongs in.
