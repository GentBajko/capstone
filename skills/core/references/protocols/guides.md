# guides [<task>] - how-to guides

**Reads:** config → the operations and architecture chapters →
manifests, compose files, README (command verification) → existing
`guides/*.md` stamps before regenerating.

Output: `docs/capstone/guides/<slug>.md`, one file per guide,
frontmatter with stamps and `paths_covered` (the guide participates in
the normal refresh protocol).

With no argument, generate the applicable standard set:
- `run-locally` and `deploy` (from the operations topic's facts),
- plus 2-4 workflows derived from the project's own extension patterns:
  read the architecture topic and pick the seams a contributor most
  likely extends (e.g. for a command-dispatch engine: add a command +
  handler + test; for a migration-managed DB: add a migration; for a
  registry-driven domain: add a registry entry).

With an argument, generate that one guide.

Guide format: goal (one line) → prerequisites → numbered steps, each
citing the file it touches and quoting exact commands → how to verify it
worked. Commands must come from verified sources (manifests, compose
files, README, or tested patterns in the repo), never invented. If a
step cannot be verified, mark it "unverified" inline.

Record: with every guide file on disk, append ONE changelog entry for
the run per core.md's ledger: key `guides/<sorted slugs>@<stamp>`;
list the slugs this run wrote (a refresh regenerates a subset), their
paths, and the count of steps marked "unverified". Then add or refresh
the `guides/` Companion docs row. Before regenerating a guide that
already exists, check its stamp is recorded and append the catch-up
entry if not.
