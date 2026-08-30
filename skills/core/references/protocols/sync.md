# sync - refresh the reference where reality moved

**Reads:** config → `<index_file>` → every stamped file's
frontmatter (stamps and globs; the full body only when regenerating
it) → `../topics.md` (template drift) → the `logic/` scenario list
against the code's entry points and the `uiux/screens/` list against
its surfaces (coverage) → for `check`
additionally: `changelog.md` (absorption drift), `05-dependencies.md`
plus the manifests and lockfile (re-vetting).

Brings the generated docs back in line with the code, rewriting only
what drifted: topic chapters and extraction-mode `logic/` and
`uiux/` files, every stamped file the plugin owns that carries
`paths_covered`. The business-logic map is part of the
reference, so a refresh also fills gaps in `logic/` and `uiux/`,
not only staleness. `sync check` is the read-only twin: it reports what a
refresh would touch, and whether the reference can be trusted,
without writing anything.

No stamped index on disk → say so in one line and execute
`generate.md` instead; there is nothing to sync yet. This is also what
core.md's Missing reference rule leans on when another protocol
delegates here, so the fallback must stay unconditional.

## Refresh

For each stamped file with `paths_covered`:

1. Read `generated_at_commit` and `paths_covered` from its
   frontmatter.
2. If the frontmatter has `mode: prescriptive` and any tracked source
   now exists, the file is **stale by definition**: the planned globs
   may not match where code actually landed. Re-run its deep-dive
   (generate.md Phase 2), rewrite it descriptively, drop
   `mode: prescriptive` and the banner, and record
   designed-vs-implemented divergences as facts ("designed as X
   (architecture-interview.md §Q7), implemented as Y (`file:line`)").
   When regenerating `05-dependencies.md` by ANY path (refresh,
   rebuild, or a topic argument): if `stack-interview.md` is
   formalized, also read it and record every user pick not yet
   present in the manifests as a fact ("picked (stack-interview.md
   §Q4), not yet installed"); the user's researched stack decisions
   must never vanish because the code hasn't caught up.
3. Otherwise check staleness against the **working tree**, not just
   commits: from the repo root, `git diff --stat <stamp> -- <globs>`
   (commit vs working tree) plus `git status --porcelain -- <globs>`
   for untracked files.
4. **No changes** → skip; leave the file and its stamp untouched.
   **Changes** → regenerate per the file's owning protocol: a topic
   chapter re-runs its generate.md Phase 2 deep-dive and Phase 3
   compose rules;
   a stale extraction-mode `logic/` or `uiux/` file regenerates per
   its protocol's extraction mode. Template drift overrides the skip:
   a chapter missing a required section that `../topics.md` now
   defines (the template changed after the chapter was stamped) is
   stale regardless of `git diff`; regenerate it against the current
   template. So does a **version gap**: a `capstone_version` older
   than the running plugin's marks a file written by an earlier
   template generation. Drift catches a section that went missing; it
   cannot catch one whose meaning moved under it, or a rename, which
   is what the version stamp is for. Re-read such a file against the
   current `../topics.md` and regenerate when they disagree in shape
   or meaning (not merely in wording). A file carrying no
   `capstone_version` predates the stamp: same treatment.
5. Re-run the **Applicable** test from `../topics.md` for every topic
   the index lists as absent; generate any newly applicable topic at
   its fixed chapter number and update its index row.
6. **Logic coverage.** Build the entry-point inventory per logic.md's
   extraction mode: every externally triggerable behavior (routes, UI
   actions, jobs and crons, queue consumers, CLI commands, webhooks)
   from the chapters' dispatch tables and the module map. Every entry
   point must be claimed by a scenario file in `logic/` (one scenario
   may span several entry points); `logic/` absent counts as every
   scenario missing. Run logic.md's extraction mode for the missing
   ones: full scenario files per its Phase B section list, every rule
   cited `file:line`, stamped with `paths_covered` so later refreshes
   keep them current. Interview-derived scenario files are not
   touched here; they absorb shipped features through `implement`.
7. **Design coverage.** Applicable when the repo has a frontend.
   Build the surface inventory per design.md's extraction mode: every
   route or view a user reaches, from the chapters' route tables and
   the module map. Every surface must be claimed by a chapter in
   `uiux/screens/` (one chapter may cover a surface family);
   `uiux/` absent counts as every surface missing. Run design.md's
   extraction mode for the missing ones, stamped with `paths_covered`
   so later refreshes keep them current. **Interview-derived `uiux/`
   files are never touched here**: a committed direction is the user's
   decision, and extraction must not quietly overwrite it with what
   the code happens to do. Where extraction and a committed chapter
   disagree, that is drift for `review` to judge, not for `sync` to
   resolve.
8. If any file was rewritten or created in this run, append the
   changelog entry per core.md's ledger, key `sync/<scope>@<the
   run's stamp>` (`<scope>` = the topic name for a single file, `all`
   otherwise); record the files regenerated or created and each one's
   trigger (covered paths changed, `mode: prescriptive` with code now
   present, template drift, newly applicable topic, logic or design
   coverage gap), the divergences recorded, and the files skipped as current.
   A run where every file was current writes nothing.
9. Always re-verify the index's module map and rows.
10. Fall back to `generate` when the stamped commit is unreachable
   (rebase, shallow clone) or there is no git repo; the user asking
   for a from-scratch rebuild is `generate rebuild`'s job.

Config `workspaces` set → run the refresh per workspace (an argument
targets one) and re-verify the root index-of-indexes' workspace table.

## check - the read-only trust report

No writes, and no changelog entry: nothing was done, only read.
Six parts:

1. **Staleness**: for each stamped file with `paths_covered`, read
   its stamp and globs, then from the repo root run
   `git diff --stat <stamp> -- <globs>` (commit vs **working tree**,
   so uncommitted work counts) plus `git status --porcelain --
   <globs>` for untracked files. Report a table: file | stamp |
   capstone_version | files changed since | verdict (current / stale /
   stamp unreachable / written by an older capstone, for a
   `capstone_version` behind the running plugin's or absent /
   prescriptive, pending first observation, for any file whose
   frontmatter still has `mode: prescriptive` while tracked source
   exists).
2. **Pointer drift**: sample ≥5 `file:line` pointers across different
   topic files, check each against the source, and report hits and
   misses with the drifted lines' new locations when findable.
3. **Absorption drift**: interview-derived `logic/`, `mockup/`, and
   `uiux/` files carry no globs; their staleness signal is shipped
   features they never absorbed. From `changelog.md`, list
   `implement/*` keys newer than each folder's newest stamp whose
   entry's outputs name that folder; report "logic/ missed N absorbed
   features" (repair: `doctor`, which re-runs the absorb step
   feature by feature).
4. **Dependency re-vetting**: compare `05-dependencies.md`'s recorded
   picks against the manifests and lockfile (picked but absent,
   installed but unrecorded, version below the recorded floor) and
   flag any pick whose recorded research date is more than 6 months
   old as "re-vet suggested (`stack refresh`)".
5. **Logic coverage**: the Refresh step 6 inventory, read-only:
   entry points no `logic/` scenario claims. Report "logic/ missing
   N scenarios", naming the unclaimed entry points (repair: `sync`,
   which extracts them).
6. **Design coverage**: the Refresh step 7 inventory, read-only:
   surfaces no `uiux/screens/` chapter claims. Report "design/
   missing N surfaces", naming them (repair: `sync`, which extracts
   them). A repo with no frontend reports the section as not
   applicable rather than as a gap.

End with one sentence (whether the reference can be trusted as-is,
needs `sync`, or needs `generate rebuild`) followed by the machine
verdict line, exactly one of:

    SYNC CHECK: current
    SYNC CHECK: stale (<N> findings)

(CI templates parse that line; never omit or reword it.)
