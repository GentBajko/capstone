# changelog [<ref>] — architectural change history

**Reads:** config → `<docs_dir>/changelog.md` (newest ranged entry
for the base ref) → topic-file stamps (fallback base) → the files
`git diff <base>..HEAD` names, at architecture level only.

`<docs_dir>/changelog.md` is this plugin's append-only ledger. This
command writes the ranged architecture-delta entries; every protocol
that writes a durable output appends its own rangeless stage entry per
core.md's Changelog ledger. No run rewrites, reorders, condenses, or
prunes an existing entry, and the file has no length cap.

1. Base ref: the argument if given; else the `<head>` of the newest
   entry **whose heading carries a `(<base>..<head>)` range** — stage
   entries carry none and are skipped (so successive runs continue the
   history instead of re-describing it); else, when the file is absent
   or holds no ranged entry, the oldest `generated_at_commit` across
   topic files — say so out loud. If the chosen ref is unreachable
   (rebase, squash-merge, shallow clone), say so and fall back to the
   oldest reachable stamp — never silently diff from the wrong base.
   Record refs as 12-char SHAs. Outside git there are no refs: say so,
   write nothing, and leave the stage entries as the history.
2. If `<base>` resolves to HEAD, nothing changed since the newest ranged
   entry: say so and write nothing — never an empty entry.
3. `git diff --stat <base>..HEAD`, then read enough of the changed files
   to describe changes at architecture level only: modules added/removed,
   dependency-direction changes, new/removed routes, commands, events,
   tables, workers, external dependencies, config keys. Ignore
   implementation-detail churn.
4. Insert the entry directly below the frontmatter, above the current
   newest entry — never at end of file; entries are newest-first and
   step 1 reads from the top. Heading `## <date> (<base>..<head>)`.
   Factual voice; cite files. Create the file on first write with
   frontmatter stamps only (no `paths_covered`) and add its Companion
   docs row per core.md.
5. Suggest a refresh (the `sync` skill) if the diff shows stale topics.

**Merges:** every entry inserts at the same offset, so branches conflict
there routinely. Keep both sides and re-sort the conflicted block by
date, newest first — resolving by picking a side drops a recorded event.
