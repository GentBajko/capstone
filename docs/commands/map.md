# `map`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#map).

## What it does

`map` writes the factual reference for a codebase that already exists:
`00-index.md`, the numbered chapters beside it, the `logic/` scenario
map and the `uiux/` surface map, every claim carrying a `file:line`
pointer.

It rewrites only the files whose covered paths moved. Each chapter
records the globs it covers and a
content hash of the tree under them, so a run after a one-file change
regenerates one chapter and leaves the other eight alone. That is also
why there is one verb instead of two: no index on disk means build,
an index on disk means refresh.

## When to reach for it

`/capstone:map` on a repo with code in it. `map rebuild` forces a full
rewrite when a reference looks current and you know it is not.
`map <topic>` targets one chapter. `map check` reports and writes
nothing at all.

Reach for `start` instead when the product does not exist yet: `map`
observes code, and there is nothing to observe. On a repo that already
has code and no reference, `start` asks once which of the two you
meant and records the answer in `docs/capstone/capstone.json`.

You rarely need to run `map` before another command. Anything that
consumes the reference and finds no index builds it first.

## The refresh, and what it fills

A refresh does two jobs. It rewrites what drifted, and it fills gaps:
entry points no `logic/` scenario claims, and surfaces no
`uiux/screens/` chapter claims, get extracted. Files written by the
`logic` or `uiux` interviews are never overwritten by that extraction,
so a designed scenario survives a mapping run.

## `map check`, in two halves

The script half is `skills/core/scripts/map-check.sh`. It runs with no
model and no API key, which is what makes it usable as a per-PR gate,
and it ends on one line: `MAP CHECK: current` or
`MAP CHECK: stale (<N> findings)`. Exit 0, 1 and 2 respectively for
current, stale and a usage error.

The model half covers what a script cannot decide: pointer drift,
absorption, dependency re-vetting, logic and design coverage. It ends
on its own line, `MAP REVIEW: clean` or `MAP REVIEW: <N> findings`,
which only the nightly workflow reads.

## Common questions

**I used to run `generate` and `sync`. Which one is `map`?** Both.
They merged in 4.x, and the CI verdict line changed from
`SYNC CHECK:` to `MAP CHECK:` at the same time. An old
`capstone-sync-check.yml` fails loudly with "no SYNC CHECK verdict
found" rather than passing silently.

**A chapter reported stale right after a squash merge.** The stamp
commit no longer exists, so the check falls back to the content hash.
Stamps written by 6.1 or earlier were hashed over a file set that
excluded wildcard matches, so such a chapter can report stale once;
the next `map` run rewrites it with the current recipe.

**Does `map check` write anything?** No. Not a chapter, not a ledger
entry. Unfolded `changelog.d/` fragments are reported and never folded
by it, because a read-only gate stays read-only.

**`09-interfaces.md` has no `To` or `From` values.** By design. `map`
writes `kind`, `name`, `site` and `schema` and never the far end of an
edge, because no repository holds another repository's name. Quarry
fills those in by joining every registered repo's rows on
`(kind, name)`; where the join finds several candidates you are asked
once, and no run edits your answer afterwards.

**It asked before mapping a large repo.** Above
`subagent_threshold` source files (150 by default) an unrequested full
build asks first, and the work fans out to subagents.

## It's working if

Every generated file carries `generated_at_commit`, `generated_date`,
`capstone_version`, `content_hash` and `paths_covered` in its
frontmatter, `00-index.md` has a row for each of them, and
`map check` ends `MAP CHECK: current`. Run the script directly to
confirm: `bash skills/core/scripts/map-check.sh docs/capstone`.
