# Authoring Rules (read by every subcommand that writes an output)

The companion to `core.md`: how a stage seeds itself, delegates
method to an installed skill, and lands its output in the docs area.
`start` and `implementation` route rather than write, so they read
only `core.md`; everything else reads both.

## Local-only outputs: `<docs_dir>/.gitignore`

Some outputs are personal working state and are **never committed**,
whatever `docs_in_git` says: `features/` (the whole feature chain:
interviews, specs, plans, review ledgers), every `*-interview.md`,
`capstone.json`, `be-review.md`, and `fe-review.md` (plus any legacy
`review.md`). `changelog.md` is NOT on this list: it is part of the
reference and follows `docs_in_git` like the chapters. The
initializer's per-project run writes `<docs_dir>/.gitignore` listing
exactly those, and deletes the `changelog.md` line older versions
wrote; whenever you write into `<docs_dir>` and that file is absent,
create it: the same idempotent initializer without the global flag
(`init-config.sh [docs_dir]` / `init-config.ps1 [docs_dir]`) does
that, the legacy migration below, and the retroactive untracking. The
`.gitignore` itself is committed, so the rules travel with the repo.

**`groom`, `plan`, and `implement` never commit the docs area.** They
commit source code only: `implement`'s per-task commits name the paths
the task touched and never `git add` `<docs_dir>` or `<index_file>`.
Reference chapters that `implement`'s wrap refreshes are left staged
or dirty for the repo's normal flow to handle, per `docs_in_git`.

## Legacy path: `docs/design`

Capstone used to default to `docs/design`. The
initializer (its per-project run, per Local-only outputs above)
migrates that layout automatically and idempotently: when
`docs/design` exists and `docs/capstone` does not, it moves the tree
(`git mv` when tracked, so history follows), repoints the moved docs'
cross-references, the index, and a `docs_dir` that named the old
default (a custom one is left alone), then untracks whatever the
ignore list below now covers. Say what it reported. If both
directories exist it merges nothing and `docs/capstone` wins; resolve
that with the user.

## Artifact seeding

Every interview stage accepts an optional
artifact argument: a PRD, a notes file, screenshots, an export. Read
it first; pre-fill every question it answers as `§Q` entries marked
`source: artifact`, quoting the artifact's own words; present ONE
digest ("the PRD answers Q1-Q9; confirm or correct") whose
confirmation turns them into decisions; then interview only what
remains. One-way doors (irreversible decisions per `interview.md`'s
conduct rules) are never taken from an artifact silently: each is
re-confirmed individually.

## Delegation installs

When a protocol names an optional
method-source skill that is not installed, offer (once per run,
interactive runs only) to install it before falling back: name the
skill, the one-line gain, and the exact command; on yes, run it,
confirm the skill list picks it up, and proceed delegated. On no (or
non-interactive), take the protocol's fallback without comment.
Verified installers:

- `impeccable`: `npx skills add pbakaus/impeccable`
- `design-taste-frontend`: `npx skills add Leonxlnx/taste-skill`
- `improve-codebase-architecture` / `codebase-design` /
  `code-review`: `npx skills add mattpocock/skills -s <skill> -g -y`
- superpowers (a plugin, not a skill):
  `claude plugin marketplace add obra/superpowers-marketplace`, then
  `claude plugin install superpowers@superpowers-marketplace`
- anything else: resolve the source via `npx skills find <name>` or
  the skill's documented installer and show the user what was found.
  Never guess an install command; a wrong source runs someone else's
  code.

## Index maintenance

The index is `<index_file>`, default
`docs/capstone/00-index.md`: chapter zero, living beside the chapters
it indexes rather than at the repository root. Every file this plugin
writes under `<docs_dir>` must be listed there:

- **Topic index**, a `| Topic | File |` table: the chapterized
  filenames (`01-architecture.md` ... `08-glossary.md`, so the folder
  reads in order even without the index), plus `logic/`'s per-scenario
  files, one row per file under the `logic` topic name (the same
  split-topic mechanic generate.md uses for a monorepo's per-subsystem
  chapters). Topics that do not apply get a row naming the reason:
  an absence is a fact, and no file can record it.
- **Companion docs**, a `| File | What it is |` table: everything else
  (be-review, fe-review, changelog, code-prefs, implementation,
  mockup/, design/, features/).

**The index carries no stamps.** Freshness lives in each file's own
frontmatter (`generated_at_commit`, `generated_date`,
`paths_covered`), which is what `sync` reads; copying it into the
index would only create a second copy to drift. The index answers what
exists and where, never how fresh it is.

The index does not list itself, and is never a topic. All indexes and
outputs are markdown; never generate HTML, for anything. Never
indexed: the interview Q&A files (`architecture-interview.md`,
`mockup-interview.md`, `code-prefs-interview.md`,
`logic-interview.md`, `design-interview.md`, `stack-interview.md`,
`build-interview.md`, `features/*/feature-interview.md`,
`features/*/review-ledger.md`) and `capstone.json`.

After writing your output, append your changelog entry (Changelog
ledger in `core.md`), then add or refresh your row; if `<index_file>` does
not exist yet, create a minimal one (title + the two tables) rather
than leaving the output orphaned.

**Legacy index:** capstone used to write `DESIGN.md` at the repository
root. A root `DESIGN.md` present with no `<index_file>` in the docs
area is that layout: move it (`git mv` when tracked), repoint the
moved docs' cross-references, drop its stamp columns per the rule
above, and say what you did. Both present → the docs-area index wins;
resolve the root file with the user.

