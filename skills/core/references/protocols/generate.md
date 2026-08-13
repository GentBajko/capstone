# generate — build the architecture reference

**Reads:** config → the existing `<index_file>` and stamps (mode
select) → Phase 1's recon set (manifests, type/lint configs,
README/CLAUDE/AGENTS, tree, entry points) → `../topics.md`. The
deep-dive reads source per topic; nothing else unprompted.

Builds the descriptive reference for the current project: a lean
`DESIGN.md` index at the project root plus chapterized topic files in
`docs/capstone/`. The audience is future AI sessions — they read these
docs instead of re-exploring the repository. Incremental upkeep is
`sync`'s job; `generate` is the from-scratch verb.

**Announce at start:** "I'm using the capstone generate skill to build
the architecture reference."

## Phase 0 — mode select

0. Per core.md: read the config first. `docs_dir` and `index_file`
   must be relative paths inside the repository.
1. A single topic argument → run Phase 1 recon, then Phases 2–4 for
   that topic only, regardless of staleness — a topic argument always
   regenerates its chapter.
2. `rebuild` → full generation (Phases 1–4), overwriting what exists.
3. Bare `generate` with no stamped index → full generation.
4. Bare `generate` when `<docs_dir>/<index_file>` and stamped topics
   already exist → confirm once before proceeding: a full rebuild
   rewrites every chapter; `sync` refreshes only what drifted. Never
   silently rewrite a current reference.

## Phase 1 — inline recon

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
   stop here. There is nothing to describe yet — generate nothing and
   point the user at `start` (or `architecture` directly), the
   greenfield path.

## Phase 2 — deep-dive

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
  3. The rules: read-only — modify nothing; facts only; a `file:line`
     pointer for every claim; no recommendations; return raw markdown
     matching the required sections, no preamble.

## Phase 3 — compose

1. Write each topic file **chapterized** — a numbered prefix in
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
paths_covered:
  - "<glob>"
---
```

2. Choose `paths_covered` globs deliberately — they drive `sync`'s
   staleness. Cover every directory the topic's content was derived
   from, but prefer the tightest globs that still do: package-level
   over repo-level, so unrelated commits don't mark the topic stale.
   Some topics (architecture, conventions) are legitimately
   repo-wide. Anchor every glob at the repository root with the
   `:(top)` magic pathspec (e.g. `:(top)src/api/**`) so staleness
   checks work from any cwd.
3. Ensure the config file and the docs area's `.gitignore` exist by
   running the platform-appropriate initializer from the `core`
   skill's `scripts/` directory (idempotent — never overwrites
   either):
   `init-config.sh <docs_dir>` via bash on macOS/Linux/Git Bash, or
   `init-config.ps1 <docs_dir>` via powershell on Windows. If neither
   shell is available, write the JSON template and the ignore list
   from core.md yourself.
4. Append the changelog entry per core.md's Changelog ledger — key
   `generate/<topic|all>@<the run's stamp>`; one bullet per chapter
   written **this run** (every one, never only those you judge
   materially changed — that judgment is the escape hatch), the
   topics recorded absent with their reasons, and whether the index
   was created or refreshed. Nothing written (Phase 1 step 9's
   empty-repo stop) → no entry.
5. Write `<index_file>` **last**, so the index reflects what was
   actually generated. Structure:
   - Project one-liner, tech stack, and paradigm summary in a few
     lines.
   - Module map with `file:line` entry-point pointers.
   - Index table `| Topic | File | Commit | Generated |`, plus absent
     topics with their reasons.
   - If companion docs exist (`be-review.md`, `fe-review.md`, `changelog.md`,
     `onboarding.md`, `code-prefs.md`, `implementation.md`,
     `guides/`, `logic/`, `mockup/`, `design/`, `features/`), list
     them in a separate "Companion docs" table below the topic
     index — the factual reference and the opinionated/instructional
     outputs stay visibly distinct. Interview Q&A files are never
     indexed.
6. Monorepos: split a topic per subsystem while keeping the parent
   chapter's number (`01-architecture-frontend.md`,
   `01-architecture-backend.md`) when one file would be unwieldy; the
   index shows the split.

## Phase 4 — verify

1. Re-read the index: every topic link resolves to an existing file;
   every listed stamp matches that file's frontmatter.
2. Spot-check three `file:line` pointers across topic files against
   the actual source.
3. Report to the user: files written, topics skipped or absent and
   why.
4. The local-only outputs (`features/`, interviews, `be-review.md`,
   `fe-review.md`,
   `changelog.md`, `capstone.json`) are already covered by
   `<docs_dir>/.gitignore` — this question is only about the factual
   reference. If those generated files are untracked and not covered
   by `.gitignore`: honor the `docs_in_git` config key when set
   (`commit` or `ignore`); when it is `ask` or unset, ask the user
   whether to commit them or add `/DESIGN.md` and `/docs/capstone/`
   to `.gitignore` — never decide unilaterally. On later runs,
   respect whichever choice is in place.

## Workspaces

When config `workspaces` is set, run Phases 1–4 once per workspace
with `<path>/docs/capstone/` as its docs area (a workspace name as
argument targets just that one), then write the root `<index_file>`
as an index-of-indexes: project one-liner, a workspace table (name ·
path · index link · newest stamp), and cross-cutting notes. When
Phase 1 recon detects workspace manifests (`pnpm-workspace.yaml`,
`go.work`, a Cargo, uv, or poetry workspace) and `workspaces` is
unset, offer to record them in the config — never silently.

## Non-git projects

Use `generated_date` only (no commit stamps). Every run is a full
generation.
