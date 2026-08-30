# map - build the reference, and keep it true

**Reads:** config → the existing `<index_file>` and every stamped
file's frontmatter (mode select, then stamps and globs; a full body
only when regenerating it) → `../topics.md` (required sections, and
template drift). A full build additionally reads Phase 1's recon set
(manifests, type/lint configs, README/CLAUDE/AGENTS, tree, entry
points); the deep-dive reads source per topic, and the extractions
read the composed chapters (per logic.md and uiux.md). For `check`
additionally: `changelog.md` (absorption drift), `05-dependencies.md`
plus the manifests and lockfile (re-vetting). Nothing else unprompted.

The descriptive reference for the current project: a lean
`00-index.md` index and chapterized topic files in `docs/capstone/`,
the `logic/` business-logic map, and the `uiux/` surface map. The
audience is future AI sessions; they read these docs instead of
re-exploring the repository.

**One verb, because the branch is readable off disk, not off intent.**
No stamped index → build it. Stamped index → rewrite only what
drifted. The user should never have to know which of those they
needed. The two things that are *not* inferable stay explicit words:
`rebuild` (rewrite a current reference anyway) and `check` (report,
write nothing).

**Announce at start**, naming the mode you selected: "I'm using the
capstone map skill to build the architecture reference" for a full
build, "...to refresh the reference where the code moved" for a
refresh.

## Phase 0 - mode select

0. Per core.md: read the config first. `docs_dir` and `index_file`
   must be relative paths inside the repository.
1. `check` → the read-only trust report at the end of this file.
   Writes nothing, not even a changelog entry.
2. A single topic argument → run Phase 1 recon, then Phases 2-4 for
   that topic only, regardless of staleness; a topic argument always
   regenerates its chapter (and skips the extractions).
3. `rebuild` → full build (Phases 1-4), overwriting what exists.
4. No stamped `<index_file>` on disk → full build (Phases 1-4).
   This branch is unconditional: core.md's Missing reference rule
   leans on it when another protocol delegates here, so it must never
   turn into a refusal or a pointer at another command.
5. A stamped `<index_file>` exists → **Refresh** (below): rewrite only
   what drifted. Never silently rewrite a current reference; a user
   who wants everything redone says `rebuild`.

## Phase 1 - inline recon

Do this in the main session with cheap reads only:

1. Read dependency manifests that exist: `pyproject.toml`,
   `package.json`, `Cargo.toml`, `go.mod`.
2. Read type and lint configs: `tsconfig.json`, pyright config
   (`pyrightconfig.json` or `[tool.pyright]`), `mypy.ini`, eslint
   config.
3. Read `README*`, `CLAUDE.md`, `AGENTS.md` if present.
4. List the directory tree two to three levels deep, ignoring
   `node_modules`, `dist`, `build`, `.git`, and caches.
5. Identify entry points: main modules, CLI entries, server startup,
   route/command registries.
6. Build the **module map**: every top-level module or package, its
   one-line purpose, and its key entry-point files. All later phases
   and every subagent treat this map as authoritative. (A Refresh does
   not re-derive it: it reads the module map the index already
   carries, and re-verifies it at the end.)
7. Decide applicable topics using each topic's **Applicable** test in
   `../topics.md`. Record inapplicable topics with a one-line reason;
   they appear in the index as absent.
8. Measure size: count tracked source files (`git ls-files` filtered
   to source extensions; `find` outside git). This is also the count
   core.md's Missing reference rule gates on before an unrequested
   full build.
9. If that count is ~0 and no entry points or manifests were found,
   stop here. There is nothing to describe yet; write nothing and
   point the user at `start` (or `architecture` directly), the
   greenfield path.

## Phase 2 - deep-dive

- **At or below the subagent threshold (default 150 source files):**
  analyze each applicable topic inline yourself, against that topic's
  required sections and checklist in `../topics.md`.
- **Above the threshold:** dispatch one read-only subagent per
  applicable topic, in parallel (if your harness has no subagent
  capability, analyze the topics sequentially inline instead). Each
  subagent prompt must contain:
  1. The topic's required sections and checklist, copied from
     `../topics.md`.
  2. The full module map from Phase 1, marked authoritative:
     "Do not re-derive the module map."
  3. The rules: read-only, modify nothing; facts only; a `file:line`
     pointer for every claim; no recommendations; return raw markdown
     matching the required sections, no preamble.

## Phase 3 - compose

1. Write each topic file **chapterized**: a numbered prefix in
   reading order so the folder itself reads like a table of contents:
   `01-architecture.md`, `02-models.md`, `03-conventions.md`,
   `04-data-flow.md`, `05-dependencies.md`, `06-testing.md`,
   `07-operations.md`, `08-glossary.md` (skip absent topics without
   renumbering). If unnumbered topic files exist from an earlier
   version, rename them to the chapter names during the run and
   update every cross-reference. Use the exact headings from
   `../topics.md`, with this frontmatter:

```yaml
---
generated_at_commit: <12-char sha of HEAD>   # omit outside git
generated_date: <YYYY-MM-DD>
capstone_version: <this plugin's manifest version>  # omit if unreadable
paths_covered:
  - "<glob>"
---
```

2. Choose `paths_covered` globs deliberately; they drive the Refresh's
   staleness. Cover every directory the topic's content was derived
   from, but prefer the tightest globs that still do: package-level
   over repo-level, so unrelated commits don't mark the topic stale.
   Some topics (architecture, conventions) are legitimately
   repo-wide. Anchor every glob at the repository root with the
   `:(top)` magic pathspec (e.g. `:(top)src/api/**`) so staleness
   checks work from any cwd.
3. Ensure the global config and the docs area's `.gitignore` exist by
   running the platform-appropriate initializer from the `core`
   skill's `scripts/` directory (idempotent, never overwrites
   either):
   `init-config.sh <docs_dir>` via bash on macOS/Linux/Git Bash, or
   `init-config.ps1 <docs_dir>` via powershell on Windows. If neither
   shell is available, write the global JSON template from core.md and
   the ignore list from core-authoring.md yourself.
4. **Logic extraction**: build `docs/capstone/logic/` per logic.md's
   extraction mode, invoked as its "Invoked by `map`" rules say: the
   entry-point inventory from the module map and the just-written
   chapters, one descriptive scenario file per scenario covering
   logic.md's full Phase B section list, every rule cited
   `file:line`, stamped with `paths_covered`. Above the subagent
   threshold, dispatch extraction per scenario like Phase 2's
   per-topic dispatch, same rules. A repo with no observable entry
   points records `logic` absent in the topic index with that reason.
   Existing `logic/` files are left alone; extraction fills only the
   scenarios the map is missing.
5. **Design extraction**: applicable when the repo has a frontend
   (client entry points, routes or views, or token/theme files: the
   same evidence `01-architecture.md`'s Frontend section reports).
   Build `docs/capstone/uiux/` per uiux.md's extraction mode,
   invoked as its "Invoked by `map`" rules say: the surface inventory
   from the module map and the route table, one
   `screens/NN-<route>.md` per surface covering what the code actually
   renders, `02-system.md` from the observed tokens and component
   language with `file:line` cites, and `01-direction.md` only where a
   direction is genuinely observable (uiux-craft §9). Every file
   stamped with `paths_covered` over the frontend globs it was read
   from. Above the subagent threshold, dispatch per surface like
   Phase 2's per-topic dispatch, same rules. A repo with no frontend
   records `uiux` absent in the Companion docs table with that
   reason. Existing `uiux/` files are left alone: extraction fills
   only the surfaces the map is missing, and never overwrites a
   committed design the `uiux` interview produced.
6. Append the changelog entry per core.md's Changelog ledger, key
   `map/<topic|all>@<the run's stamp>`; one bullet per chapter
   and logic scenario written **this run** (every one, never only
   those you judge materially changed; that judgment is the escape
   hatch), the topics recorded absent with their reasons, and whether
   the index was created or refreshed. Nothing written (Phase 1 step
   9's empty-repo stop) → no entry.
7. Write `<index_file>` **last**, so the index reflects what was
   actually written. It is chapter zero of the docs area
   (`docs/capstone/00-index.md` by default), and it carries no stamps:
   freshness lives in each file's own frontmatter, which is what the
   Refresh reads (core-authoring.md's Index maintenance). Four parts,
   nothing else:
   - Project one-liner, tech stack, and paradigm summary in a few
     lines.
   - Module map with `file:line` entry-point pointers.
   - Topic table `| Topic | File |`, plus absent topics with their
     reasons in place of a file. `logic/` gets one row per scenario
     file in this same table, `Topic` reading `logic` for every row
     (the monorepo split mechanic below, applied to a subfolder
     instead of the root); a repo with no scenarios yet records
     `logic` absent here with its reason instead.
   - If companion docs exist (`review.md`, `changelog.md`,
     `code-prefs.md`, `implementation.md`, `mockup/`,
     `uiux/`, `features/`), a `| File | What it is |` table below
     the topic table; the factual reference and the
     opinionated/instructional outputs stay visibly distinct.
     Interview Q&A files are never indexed, and the index never lists
     itself.
8. Monorepos: split a topic per subsystem while keeping the parent
   chapter's number (`01-architecture-frontend.md`,
   `01-architecture-backend.md`) when one file would be unwieldy; the
   index shows the split.

## Phase 4 - verify

1. Re-read the index: every topic link resolves to an existing file,
   and every file written this run has a row.
2. Spot-check three `file:line` pointers across topic and logic files
   against the actual source.
3. Report to the user: files written, topics skipped or absent and
   why.
4. The local-only outputs (`features/`, interviews, `review.md`,
   `capstone.json`) are already covered by
   `<docs_dir>/.gitignore`; this question is only about the factual
   reference (`changelog.md` included). If those generated files are
   untracked and not covered by `.gitignore`: honor the `docs_in_git`
   config key when set (`commit` or `ignore`); when it is `ask` or
   unset, ask the user whether to commit them or add
   `/docs/capstone/` to `.gitignore`; never decide unilaterally. On
   later runs, respect whichever choice is in place.

## Refresh - rewrite only what drifted

Selected by Phase 0 branch 5. This is the selector; Phases 2-3 remain
the writer, applied per file rather than to everything. A refresh also
fills gaps in `logic/` and `uiux/`, not only staleness: the maps are
part of the reference, and a missing scenario is as wrong as a stale
one.

For each stamped file with `paths_covered`:

1. Read `generated_at_commit`, `capstone_version`, and
   `paths_covered` from its frontmatter.
2. If the frontmatter has `mode: prescriptive` and any tracked source
   now exists, the file is **stale by definition**: the planned globs
   may not match where code actually landed. Re-run its Phase 2
   deep-dive, rewrite it descriptively, drop
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
   **Changes** → regenerate it through Phases 2-3; a stale
   extraction-mode `logic/` or `uiux/` file regenerates per its own
   protocol's extraction mode instead. Template drift overrides the
   skip: a chapter missing a required section that `../topics.md` now
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
   the index lists as absent; write any newly applicable topic at
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
   Build the surface inventory per uiux.md's extraction mode: every
   route or view a user reaches, from the chapters' route tables and
   the module map. Every surface must be claimed by a chapter in
   `uiux/screens/` (one chapter may cover a surface family);
   `uiux/` absent counts as every surface missing. Run uiux.md's
   extraction mode for the missing ones, stamped with `paths_covered`
   so later refreshes keep them current. **Interview-derived `uiux/`
   files are never touched here**: a committed direction is the user's
   decision, and extraction must not quietly overwrite it with what
   the code happens to do. Where extraction and a committed chapter
   disagree, that is drift for `review` to judge, not for `map` to
   resolve.
8. If any file was rewritten or created in this run, append the
   changelog entry per core.md's ledger, key `map/<scope>@<the
   run's stamp>` (`<scope>` = the topic name for a single file, `all`
   otherwise); record the files regenerated or created and each one's
   trigger (covered paths changed, `mode: prescriptive` with code now
   present, template drift, version gap, newly applicable topic,
   logic or design coverage gap), the divergences recorded, and the
   files skipped as current.
   A run where every file was current writes nothing.
9. Always re-verify the index's module map and rows.
10. Fall back to a full build (Phases 1-4) when the stamped commit is
   unreachable (rebase, shallow clone) or there is no git repo. Say
   so before doing it: the user asked to refresh and is getting a
   rewrite.

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
   N scenarios", naming the unclaimed entry points (repair: `map`,
   which extracts them).
6. **Design coverage**: the Refresh step 7 inventory, read-only:
   surfaces no `uiux/screens/` chapter claims. Report "uiux/
   missing N surfaces", naming them (repair: `map`, which extracts
   them). A repo with no frontend reports the section as not
   applicable rather than as a gap.

End with one sentence (whether the reference can be trusted as-is,
needs `map`, or needs `map rebuild`) followed by the machine
verdict line, exactly one of:

    MAP CHECK: current
    MAP CHECK: stale (<N> findings)

(CI templates parse that line; never omit or reword it.)

## Workspaces

When config `workspaces` is set, run Phases 1-4 once per workspace
with `<path>/docs/capstone/` as its docs area (a workspace name as
argument targets just that one), then write the root `<index_file>`
as an index-of-indexes: project one-liner, a workspace table (name ·
path · index link · newest stamp), and cross-cutting notes. When
Phase 1 recon detects workspace manifests (`pnpm-workspace.yaml`,
`go.work`, a Cargo, uv, or poetry workspace) and `workspaces` is
unset, offer to record them in the project config (per core.md,
creating it holding just that key if absent); never silently.

## Non-git projects

Use `generated_date` only (no commit stamps). There are no stamps to
diff, so every run is a full build; `check` reports staleness as
unknowable and falls back to pointer drift alone.
