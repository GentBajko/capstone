# Version notes and less obvious behaviors

This appendix records practical details that are easy to miss in a normal walkthrough. They describe inspected source behavior, including limitations and inconsistencies; they are not recommendations to bypass approval or erase working state.

## Version baseline and installing the documented behavior

This manual targets **6.4.1**, tag `v6.4.1`, source commit `4210f6cab09dc5c3b742147d8714795b026e1cd9`. The documented changes and manual were merged into `main` on 9 September 2026 in [PR #19](https://github.com/GentBajko/capstone/pull/19). The earlier research check found the default branch at `82094d42c4bfa9d6ffdeb569e3b971394765e6fc` with a **6.4.0** manifest; that branch difference is now resolved. The 6.4.1 tag existed at that check, but a GitHub Release entry for it was not found. A tag and a GitHub Release are different publication artifacts.

Default-branch installations now include the documented 6.4.1 changes. Existing installations still need an update through their original installer. Check the version in the installed plugin manifest or the generated files' `capstone_version`; do not infer it from this manual or from the existence of a tag. To inspect this exact source version independently, a terminal command is:

```sh
git clone --branch v6.4.1 https://github.com/GentBajko/capstone capstone-6.4.1
```

This clones source; it does not install the skills into every agent. Use your harness's supported installation mechanism for a selected checkout/version. The per-PR template explicitly clones the tag; the nightly model-review template installs from the marketplace without a version pin.

These two commits introduced the changes since the previously published 6.4.0 source:

| Commit | User-visible changes |
| --- | --- |
| `257b64f` | Adds retro and questionnaires, strengthens final-output/documentation guidance, moves full standards enforcement to the implementation reviewer while copying executor constraints into plans, and adds per-command documentation |
| `4210f6c` | Requires a fresh explicit inline/subagents choice for every new/resumed start or feature run and standalone build/implement, covering prerequisite work through wrap |

The default branch already included the 6.4.0 schema machinery, payload tables, UI preview/assets, inventory completion checks, and cross-stage readback work. Do not describe all 6.4 features as new in 6.4.1.

## Output authority and ownership traps

- **The index is unstamped.** Some older/general prose still refers to a “stamped index” or suggests every generated file carries stamps. Current map mode selection checks index presence; the machine schema and authoring rules explicitly waive all index stamps. Freshness is in topic files.
- **No index plus no source is not a loop.** A consuming command may bootstrap map once; if map finds nothing to document and produces no index, the consuming command stops.
- **Current map is not read-only in general.** It can fill coverage gaps or repair outdated output shape even with no changed source. Use `map check` when writing nothing matters.
- **Generated prose is owned by the skills.** A hand edit to a mapped chapter can disappear on regeneration. Confirmed `to`/`from` cells and ledger history have explicit preservation rules; ordinary paragraphs do not.
- **Final interview decisions must be in final files.** Completed interview bodies are opened only for a proven missing decision, not used as hidden authority for every later stage.
- **One writer at a time.** Capstone does not lock its reference. Two live sessions can interleave chapter writes or folds. Ledger fragments reduce Git conflicts but are not a concurrency-control mechanism.

## Git, hashes, branches, and cleanup

- Coverage globs use Git's `:(top)` pathspec so checks work from another working directory. Overly broad globs cause needless refresh; missing globs hide relevant drift.
- `content_hash` hashes `git ls-files -s --full-name -- <globs>` through `git hash-object --stdin`, truncated to 12 characters. It includes tracked index entries, while working-tree dirtiness is checked separately. It is not an embedding or a textual similarity score.
- Older recipes could write the empty-input hash `e69de29bb2d1` when wildcard globs were not expanded. The checker treats that value as missing. A one-time refresh after upgrading/squashing can be expected even when the source seems unchanged.
- Missing/unreachable generation commits do not automatically force a whole map: a valid hash can establish per-file freshness. Without Git, refresh is a full build and commit freshness is unknowable.
- Ignored feature files survive a branch switch unchanged. Task checkboxes do not prove that the currently checked-out source includes those tasks. Check the branch context before resume.
- The saved execution field uses the literal values `execution: subagent` or `execution: inline` (singular `subagent`). It records the last answer; it never skips the next invocation's execution-choice gate.
- `base_commit` is a diff checkpoint, not an independently stored branch name. The protocol asks the agent to verify the right branch; users should not treat that SHA alone as an automatic branch-identification system.
- Source commits from implement deliberately exclude the docs area. Review and commit the refreshed reference/ledger through your repository's intended flow; otherwise a fresh clone or Quarry will not receive them.
- Fold only on the default branch. Read-only runs and no-op map refreshes do not fold. A feature branch carrying a fragment should pass that part of the gate.
- Rotation moves keys with their entry bodies: past 200 entries, retain the newest 100 and move the rest into year files. Deleting old keys instead can make a shipped feature appear never started.
- Feature IDs are date-plus-slug, avoiding the older next-number allocation across branches. This is not a promise of globally unique identifiers for identical requests made on the same date. Existing numeric IDs remain valid; shipped identifiers are never reused.

## Direct Bash checker details

- Bash 3.2 is the stated floor. The script normalizes CRLF when reading frontmatter/headings/table rows and uses stable sorted ordering; it does not print fresh timestamps into an otherwise identical mechanical report.
- It reads index-linked Markdown first, then additional Markdown under the docs area, deduplicating and applying its skip list. An orphaned Markdown file can still be schema-checked; this is not a substitute for doctor's index repair.
- An existing docs folder without its index is a stale finding. A nonexistent folder is a usage error (exit 2). Neither is equivalent to a clean empty reference.
- A missing schema is a reported degraded check, not necessarily a failing verdict. Keep the script with its sibling schema and manifest.
- The non-Markdown secret sweep inside Git uses tracked files and handles spaces, Unicode, pipes, quotes, backslashes, and newlines in tracked names. Outside Git it relies on newline-delimited discovery; a filename containing a newline is a known limitation.
- **Custom-index lookup differs from the model's config contract.** The model reads the fixed root `docs/capstone/capstone.json`, but the Bash `resolve_index` function looks for `capstone.json` inside the supplied docs directory, then the global file, then `<docs_dir>/00-index.md`. With a relocated docs area and a specially named/nested index, a setting recorded only at the fixed project path may not be discovered by the direct script. Default `00-index.md` in the supplied directory avoids that lookup difference; do not assume custom configuration was read merely because the script ran.
- A global index override is used by the script only when it resolves directly inside the current docs directory. A project override found there can point deeper inside that directory. Outside-directory candidates are not accepted by that resolver.
- The supported secret patterns are narrow and the skip list excludes configuration, ledger, interview, feature, review, and preview files. No matched string is printed. A clean verdict cannot be used as evidence that those excluded files contain no secrets.

## Interface details that affect joins and checks

- Canonical `edges:` and `known_as` exist independently of `interfaces_frontmatter`; that option adds only legacy mirrors.
- `known_as: []` is a valid, required empty observation. `known_as: records.internal` is a scalar and a finding.
- New observed edges do not receive guessed `to`, `from`, or `unknown` values. The narrow confirmation flow is for ambiguity reported by Quarry, not every interface with no known partner.
- A confirmed name missing from the registry can still be recorded: your knowledge may precede registration. The unresolved lookup stays visible instead of being overwritten.
- `skip` and `unknown` differ: skip records no decision; unknown records a deliberate absence of a sibling partner and suppresses joining/re-asking.
- The merge key includes direction, kind, and name. A site may move while the confirmed far end stays; a contract rename does not inherit a different key's confirmation by magic.
- `site` is one source file. Directories and globs are not valid substitutes; line suffixes are accepted only for backward compatibility and stripped for checking.
- Model references resolve in the same docs area's `02-models.md`, not in a sibling repository or a split-model filename inferred from prose. Keep interface payload entities discoverable at that expected file/heading.
- An inline table alongside `Model:` takes precedence and produces a warning in the contract reader; document one authoritative field source.
- `Entity[]` names the same field schema as `Entity`; it is not a recursive compatibility specification. Notes/default values and business semantics are not the type-string comparison.

## Upgrade and repair details

`init-config.sh --global` only creates a missing global file. A normal per-project initializer can make more changes: it migrates `docs/design` to `docs/capstone`, the old root `DESIGN.md` to the docs index, `design/` to `uiux/`, and `code-prefs` outputs to standards; rewrites relevant references; repairs ignore entries; and untracks already-tracked files now covered by ignore rules while keeping their working copies.

When both legacy and current locations exist, it reports the conflict and merges nothing. Do not delete either based only on the preferred name. Untracking is a staged Git change worth reviewing, not deletion of the local files.

Old `generate` and `sync` commands became map in 4.x. Old CI looking for `SYNC CHECK:` must move to `MAP CHECK:`. Older model-based per-PR templates can still incur model usage even when a current Bash gate needs no API key. Install updates can leave retired skill files; remove them through the original installer.

`doctor`'s asset wording expects present assets under `uiux/assets/`, whereas build explicitly moves SVGs to the application and updates their table paths. If an asset is reported missing after build, inspect the table's current File destination before accepting a downgrade to awaited; a deliberate move is not a lost file.

Build's completion marker means its walking skeleton runs, and its protocol does not specify the feature executor's two-dry-round diff loop. Feature `status: formalized` means only its spec is complete; `plan_approved` is another checkpoint, and `implemented` is written after documentation wrap. Read the marker appropriate to the stage rather than treating all “formalized” files as shipped software.

Sources: [6.4.1 commit](https://github.com/GentBajko/capstone/commit/4210f6cab09dc5c3b742147d8714795b026e1cd9), [preceding feature commit](https://github.com/GentBajko/capstone/commit/257b64f4845c9a65f3dfc0c54a9f51076e29bc57), [compared 6.4.0 manifest](https://github.com/GentBajko/capstone/blob/82094d42c4bfa9d6ffdeb569e3b971394765e6fc/.claude-plugin/plugin.json), [checker implementation](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/map-check.sh), [initializer implementation](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/init-config.sh), [shared lifecycle](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md), [interfaces source](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/topics.md), [build](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/build.md), [doctor](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/doctor.md).
