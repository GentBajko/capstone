# Version notes and less obvious behaviors

This appendix records practical details that are easy to miss in a normal walkthrough. They describe inspected source behavior, including limitations and inconsistencies; they are not recommendations to bypass approval or erase working state.

## Version baseline and installing the documented behavior

This manual targets **7.0.0**, tag `v7.0.0`, source commit `a21d9401800b81692556fe434024777d61e43b55`. The documented changes and manual were merged into `main` on 19 September 2026 in [PR #22](https://github.com/GentBajko/capstone/pull/22), and `v7.0.0` was tagged from that merge.

Default-branch installations now include the documented 7.0.0 changes. Existing installations still need an update through their original installer, and 7.0.0 changes how commands are invoked, so an unupdated installation keeps the old seventeen-command surface. Check the version in the installed plugin manifest or the generated files' `capstone_version`; do not infer it from this manual or from the existence of a tag.

A GitHub Release entry for `v7.0.0` was not created. This repository publishes tags without Release entries, as it did for 6.4.1, 6.5.0 and 6.6.0. A tag and a GitHub Release are different publication artifacts.

To inspect this exact source version independently:

```sh
git clone --branch v7.0.0 https://github.com/GentBajko/capstone capstone-7.0.0
```

This clones source; it does not install the skills into every agent. Use your harness's supported installation mechanism for a selected checkout/version. The per-PR template explicitly clones the tag; the nightly model-review template installs from the marketplace without a version pin.

These three commits introduced the changes since the previously published 6.4.1 source:

| Commit | Version | User-visible changes |
| --- | --- | --- |
| `bd2b7fa` | 6.5.0 | Makes completed feature-folder cleanup configurable through `delete_feature_folders` (default `false`, retaining folders as ignored local history). The `implement/<id>` ledger key, not the folder's presence, becomes the done marker |
| `fb7ce6a` | 6.6.0 | Adds uiux review artifacts: a first-pass SVG logo and a self-contained HTML page mockup in `uiux/assets/references/`, presented for explicit approval before `architecture`, with accepted files listed in `02-system.md`'s Assets table |
| `a21d940` | 7.0.0 | Reduces the command surface from seventeen to nine. The seven pipeline stages become `start <stage>` subcommands and the session review becomes `review retro`; the protocol behavior of each is unchanged |

### 7.0.0 is a breaking change to invocation only

`/capstone:mockup`, `:logic`, `:uiux`, `:architecture`, `:standards`, `:stack`, `:build` and `:retro` are no longer commands and no longer resolve. Replace them:

| Before 7.0.0 | From 7.0.0 |
| --- | --- |
| `/capstone:mockup`, `:logic`, `:uiux`, `:architecture`, `:standards`, `:stack`, `:build` | `/capstone:start <stage>` |
| `/capstone:stack refresh` | `/capstone:start stack refresh` |
| `/capstone:retro [session]` | `/capstone:review retro [session]` |

No generated file, schema, ledger key, config key, or protocol behavior changed. A repository whose docs were produced by 6.x needs no migration; only the words you type change. A stage entered directly still runs exactly what the pipeline runs at that point and then stops, including its own execution-mode question and its own formalization gate.

`retro` moved to `review` rather than `start` because its trigger is a finished session, which happens under every command. A repository that was mapped rather than designed never runs the pipeline at all, so under `start` the session review would have been unreachable in practice. It is an argument rather than a side: it writes `standards.md`, not `review.md`, and does not touch either review side's stamp.

The earlier 6.4.x notes remain accurate for their versions. The default branch already included the 6.4.0 schema machinery, payload tables, UI preview/assets, inventory completion checks, and cross-stage readback work. Do not describe all 6.4 features as new in 6.4.1.

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

Sources: [7.0.0 commit](https://github.com/GentBajko/capstone/commit/a21d9401800b81692556fe434024777d61e43b55), [6.6.0 commit](https://github.com/GentBajko/capstone/commit/fb7ce6a), [6.5.0 commit](https://github.com/GentBajko/capstone/commit/bd2b7fa), [6.4.1 commit](https://github.com/GentBajko/capstone/commit/4210f6cab09dc5c3b742147d8714795b026e1cd9), [checker implementation](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/scripts/map-check.sh), [initializer implementation](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/scripts/init-config.sh), [shared lifecycle](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/core.md), [interfaces source](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/topics.md), [build](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/protocols/build.md), [doctor](https://github.com/GentBajko/capstone/blob/a21d9401800b81692556fe434024777d61e43b55/skills/core/references/protocols/doctor.md).
