---
name: docs
description: Use when asked to generate, update, or refresh a codebase's architecture reference docs (DESIGN.md plus docs/design/ topic files), map the architecture, or document the data models, typing conventions, and module boundaries so AI sessions read docs instead of re-exploring the repo. Descriptive only; refreshes just the topics whose covered paths changed since their commit stamps.
---

# Capstone: Codebase Architecture Reference Generator

Generate or refresh a descriptive architecture reference for the current
project: a lean `DESIGN.md` index at the project root plus topic files in
`docs/design/`. The audience is future Claude sessions — they read these
docs instead of re-exploring the repository.

**Announce at start:** "I'm using the capstone skill to
generate/refresh the architecture reference."

## Phase 0 — Mode select and routing

0. Read `references/core.md` — the hard rules, voice rules, and user
   config. The config always lives at the fixed path
   `docs/design/capstone.json`, regardless of `docs_dir` (`docs_dir`
   relocates generated outputs only, never the config). Its keys
   override the defaults below; `docs_dir` and `index_file` must be
   relative paths inside the repository.
1. Routing. The reserved subcommand words (`check-docs`, `ask`,
   `changelog`, `review`, `guides`, `onboarding`, `mockup`, `logic`,
   `architecture`, `code-prefs`, `stack`, `build`, `start`) each route to
   `references/protocols/<name>.md` — read `references/core.md` plus
   that one protocol file and execute it; behaviors live there, not
   here. **Exception: when this skill was invoked as `docs`, topic
   names win over subcommand names** — the user already chose docs, so
   `docs architecture` regenerates `01-architecture.md` and never
   starts the architecture interview. On the `help` argument, run
   `scripts/help.sh` via bash (or `scripts\help.ps1` via powershell on
   Windows) and output its stdout verbatim; nothing else.
2. If a single topic argument was given → run Phase 1 recon, then
   Phases 2–4 for that topic only, regardless of staleness — a topic
   argument always regenerates its chapter.
3. Otherwise, check for `<docs_dir>/<index_file>` and stamped topic
   files. If they exist and the argument is not `rebuild` → **refresh
   path** (see Refresh protocol below).
4. Otherwise → full generation (Phases 1–4).

## Phase 1 — Inline recon

Do this in the main session with cheap reads only:

1. Read dependency manifests that exist: `pyproject.toml`,
   `package.json`, `Cargo.toml`, `go.mod`.
2. Read type and lint configs: `tsconfig.json`, pyright config
   (`pyrightconfig.json` or `[tool.pyright]`), `mypy.ini`, eslint config.
3. Read `README*`, `CLAUDE.md`, `AGENTS.md` if present.
4. List the directory tree two to three levels deep, ignoring
   `node_modules`, `dist`, `build`, `.git`, and caches.
5. Identify entry points: main modules, CLI entries, server startup,
   route/command registries.
6. Build the **module map**: every top-level module or package, its
   one-line purpose, and its key entry-point files. All later phases and
   every subagent treat this map as authoritative.
7. Decide applicable topics using each topic's **Applicable** test in
   `references/topics.md`. Record inapplicable topics with a one-line
   reason; they appear in the index as absent.
8. Measure size: count tracked source files (`git ls-files` filtered to
   source extensions; `find` outside git).
9. If that count is ~0 and no entry points or manifests were found,
   stop here. There is nothing to describe yet — generate nothing and
   point the user at `start` (or `architecture` directly), the
   greenfield path.

## Phase 2 — Deep-dive

- **At or below the subagent threshold (default 150 source files):**
  analyze each applicable topic inline yourself, against that topic's
  required sections and checklist in `references/topics.md`.
- **Above the threshold:** dispatch one read-only subagent per
  applicable topic, in parallel (if your harness has no subagent
  capability, analyze the topics sequentially inline instead). Each
  subagent prompt must contain:
  1. The topic's required sections and checklist, copied from
     `references/topics.md`.
  2. The full module map from Phase 1, marked authoritative:
     "Do not re-derive the module map."
  3. The rules: read-only — modify nothing; facts only; a `file:line`
     pointer for every claim; no recommendations; return raw markdown
     matching the required sections, no preamble.

## Phase 3 — Compose

1. Write each topic file **chapterized** — a numbered prefix in reading
   order so the folder itself reads like a table of contents:
   `01-architecture.md`, `02-models.md`, `03-conventions.md`,
   `04-data-flow.md`, `05-dependencies.md`, `06-testing.md`,
   `07-operations.md`, `08-glossary.md` (skip absent topics without
   renumbering). If unnumbered topic files exist from an earlier
   version, rename them to the chapter names during the run and update
   every cross-reference. Use the exact headings from
   `references/topics.md`, with this frontmatter:

```yaml
---
generated_at_commit: <12-char sha of HEAD>   # omit outside git
generated_date: <YYYY-MM-DD>
paths_covered:
  - "<glob>"
---
```

2. Choose `paths_covered` globs deliberately — they drive refresh
   staleness. Cover every directory the topic's content was derived
   from, but prefer the tightest globs that still do: package-level
   over repo-level, so unrelated commits don't mark the topic stale.
   Some topics (architecture, conventions) are legitimately repo-wide.
   Anchor every glob at the repository root with the `:(top)` magic
   pathspec (e.g. `:(top)src/api/**`) so staleness checks work from
   any cwd.
3. Ensure the config file exists by running the platform-appropriate
   initializer from this skill's `scripts/` directory (idempotent —
   never overwrites): `bash scripts/init-config.sh` on
   macOS/Linux/Git Bash, or `powershell -ExecutionPolicy Bypass -File
   scripts\init-config.ps1` on Windows. If neither shell is available,
   write the JSON template from `references/core.md` yourself.
4. Write `<index_file>` **last**, so the index reflects what was
   actually generated. Structure:
   - Project one-liner, tech stack, and paradigm summary in a few lines.
   - Module map with `file:line` entry-point pointers.
   - Index table `| Topic | File | Commit | Generated |`, plus absent
     topics with their reasons.
   - If companion docs exist (`review.md`, `changelog.md`,
     `onboarding.md`, `code-prefs.md`, `implementation.md`, `guides/`,
     `logic/`, `mockup/`, `features/`),
     list them in a separate "Companion docs" table below the topic
     index —
     the factual reference and the opinionated/instructional outputs
     stay visibly distinct. Interview Q&A files are never indexed.
5. Monorepos: split a topic per subsystem while keeping the parent
   chapter's number (`01-architecture-frontend.md`,
   `01-architecture-backend.md`) when one file would be unwieldy; the
   index shows the split.

## Phase 4 — Verify

1. Re-read the index: every topic link resolves to an existing file;
   every listed stamp matches that file's frontmatter.
2. Spot-check three `file:line` pointers across topic files against the
   actual source.
3. Report to the user: files written, topics skipped or absent and why.
4. If the generated files are untracked and not covered by `.gitignore`:
   honor the `docs_in_git` config key when set (`commit` or `ignore`);
   when it is `ask` or unset, ask the user whether to commit them or add
   `/DESIGN.md` and `/docs/design/` to `.gitignore` — never decide
   unilaterally. On later runs, respect whichever choice is in place.

## Refresh protocol

For each stamped file the plugin owns — topic chapters AND stamped
guides under `guides/`:

1. Read `generated_at_commit` and `paths_covered` from its frontmatter.
2. If the frontmatter has `mode: prescriptive` and any tracked source
   now exists, the file is **stale by definition** — the planned globs
   may not match where code actually landed. Re-run its deep-dive,
   rewrite it descriptively, drop `mode: prescriptive` and the banner,
   and record designed-vs-implemented divergences as facts ("designed
   as X (architecture-interview.md §Q7), implemented as Y
   (`file:line`)"). When regenerating `05-dependencies.md` by ANY path
   (refresh, rebuild, or a topic argument): if `stack-interview.md` is
   formalized, also read it and record every user pick not yet present
   in the manifests as a fact ("picked (stack-interview.md §Q4), not
   yet installed") — the user's researched stack decisions must never
   vanish just because the code hasn't caught up.
3. Otherwise check staleness against the **working tree**, not just
   commits: from the repo root, `git diff --stat <stamp> -- <globs>`
   (commit vs working tree) plus `git status --porcelain -- <globs>`
   for untracked files.
4. **No changes** → skip; leave the file and its stamp untouched.
   **Changes** → for a topic chapter, re-run its Phase 2 deep-dive and
   rewrite it; for a stale guide, regenerate it per
   `references/protocols/guides.md`'s format instead.
5. Re-run the **Applicable** test from `references/topics.md` for every
   topic the index lists as absent; generate any newly applicable topic
   at its fixed chapter number and update its index row.
6. Always re-verify the index's module map and rows.
7. Fall back to a full rebuild when the stamped commit is unreachable
   (rebase, shallow clone), there is no git repo, or the user passed
   `rebuild`.

## Non-git projects

Use `generated_date` only (no commit stamps). Every run is a full
generation.
