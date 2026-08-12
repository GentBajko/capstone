# check-docs — read-only trust report

No writes — and no changelog entry: nothing was done, only read. Two parts:

1. **Staleness**: for each stamped file (topic chapters and stamped
   guides), read its stamp and `paths_covered`, then from the repo root
   run `git diff --stat <stamp> -- <globs>` (commit vs **working
   tree**, so uncommitted work counts) plus `git status --porcelain --
   <globs>` for untracked files. Report a table: topic | stamp | files
   changed since | verdict (current / stale / stamp unreachable /
   prescriptive — pending first observation, for any file whose
   frontmatter still has `mode: prescriptive` while tracked source
   exists).
2. **Pointer drift**: sample ≥5 `file:line` pointers across different
   topic files, check each against the source, and report hits/misses
   with the drifted lines' new locations when findable.

End with one sentence: whether the reference can be trusted as-is, needs
a refresh (the `docs` skill), or a full `rebuild`.
