# generate - build the architecture reference

**Reads:** config → the existing `<index_file>` and stamps (mode
select) → Phase 1's recon set (manifests, type/lint configs,
README/CLAUDE/AGENTS, tree, entry points) → `../topics.md`. The
deep-dive reads source per topic, and the logic extraction reads the
composed chapters (per logic.md); nothing else unprompted.

Builds the descriptive reference for the current project: a lean
`00-index.md` index and chapterized topic files in
`docs/capstone/`, and the `logic/` business-logic map. The audience is
future AI sessions; they read these docs instead of re-exploring the
repository. Incremental upkeep is `sync`'s job; `generate` is the
from-scratch verb.

**Announce at start:** "I'm using the capstone generate skill to build
the architecture reference."

## Phase 0 - mode select

0. Per core.md: read the config first. `docs_dir` and `index_file`
   must be relative paths inside the repository.
1. A single topic argument → run Phase 1 recon, then Phases 2-4 for
   that topic only, regardless of staleness; a topic argument always
   regenerates its chapter (and skips the logic extraction).
2. `rebuild` → full generation (Phases 1-4), overwriting what exists.
3. Bare `generate` with no stamped index → full generation.
4. Bare `generate` when `<docs_dir>/<index_file>` and stamped topics
   already exist → confirm once before proceeding: a full rebuild
   rewrites every chapter; `sync` refreshes only what drifted. Never
   silently rewrite a current reference.

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
   and every subagent treat this map as authoritative.
7. Decide applicable topics using each topic's **Applicable** test in
   `../topics.md`. Record inapplicable topics with a one-line reason;
   they appear in the index as absent.
8. Measure size: count tracked source files (`git ls-files` filtered
   to source extensions; `find` outside git).
9. If that count is ~0 and no entry points or manifests were found,
   stop here. There is nothing to describe yet; generate nothing and
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

2. Choose `paths_covered` globs deliberately; they drive `sync`'s
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
   extraction mode, invoked as its "Invoked by `generate` or `sync`"
   rules say: the entry-point inventory from the module map and the
   just-written chapters, one descriptive scenario file per scenario
   covering logic.md's full Phase B section list, every rule cited
   `file:line`, stamped with `paths_covered`. Above the subagent
   threshold, dispatch extraction per scenario like Phase 2's
   per-topic dispatch, same rules. A repo with no observable entry
   points records `logic` absent in the topic index with that reason.
   Existing `logic/` files are left alone; extraction fills only the
   scenarios the map is missing.
5. **Design extraction**: applicable when the repo has a frontend
   (client entry points, routes or views, or token/theme files: the
   same evidence `01-architecture.md`'s Frontend section reports).
   Build `docs/capstone/uiux/` per design.md's extraction mode,
   invoked as its "Invoked by `generate` or `sync`" rules say: the
   surface inventory from the module map and the route table, one
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
   `generate/<topic|all>@<the run's stamp>`; one bullet per chapter
   and logic scenario written **this run** (every one, never only
   those you judge materially changed; that judgment is the escape
   hatch), the topics recorded absent with their reasons, and whether
   the index was created or refreshed. Nothing written (Phase 1 step
   9's empty-repo stop) → no entry.
7. Write `<index_file>` **last**, so the index reflects what was
   actually generated. It is chapter zero of the docs area
   (`docs/capstone/00-index.md` by default), and it carries no stamps:
   freshness lives in each file's own frontmatter, which is what
   `sync` reads (core-authoring.md's Index maintenance). Four parts, nothing
   else:
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

Use `generated_date` only (no commit stamps). Every run is a full
generation.
