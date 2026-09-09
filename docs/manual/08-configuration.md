# Configure Capstone and monorepos

Capstone reads a personal global configuration and an optional shared project configuration. Both allow `//` line comments, so the default file is JSON with comments rather than strict JSON for an arbitrary parser. Missing keys use the defaults below.

The global configuration belongs to the user. The Claude hook writes `~/.claude/capstone.json`, or the directory selected by environment. The initializer and checker resolve **`CAPSTONE_GLOBAL_DIR` → `CLAUDE_CONFIG_DIR` → `$HOME/.claude`**. Set the first explicitly for direct script use with another agent.

The shared project file is always **`docs/capstone/capstone.json`**, even when generated output moves elsewhere. It is optional, created when there is project state/settings to record, and committed. Project values override global values except `expertise` and `teaching_mode`, which are personal and ignored if placed in the project file.

## Supported keys and defaults

| Key | Default | Meaning |
| --- | --- | --- |
| `expertise` | `null` | Ask once in an interactive task; levels 1–5 change conversational vocabulary/detail, not document rigor; null behaves as level 3 until answered |
| `teaching_mode` | `false` | Narrate meaningful steps and concepts while working; personal/global only |
| `docs_dir` | `"docs/capstone"` | Generated docs directory, relative and inside the repository |
| `index_file` | `"docs/capstone/00-index.md"` | Index path, relative and inside the repository |
| `subagent_threshold` | `150` | Source-file count above which standalone map uses topic subagents if available and an unrequested initial map asks first |
| `docs_in_git` | `"ask"` | `"commit"`, `"ignore"`, or `"ask"` for factual reference tracking; local-only files and committed exceptions have separate rules |
| `language` | `"en"` | Language of generated documentation |
| `non_interactive` | `false` | Resolve prompts that have defaults using those defaults; required decisions without defaults still stop |
| `extract` | `["logic", "uiux"]` | Automatic map extraction/coverage passes; `["logic"]` skips UI extraction; `[]` skips both |
| `interfaces` | `"auto"` | `"auto"` writes an interfaces chapter when sibling-repo communication exists; `"off"` skips that pass |
| `interfaces_frontmatter` | `false` | Add legacy top-level produces/consumes mirrors; canonical `edges:` and `known_as` are always written when the chapter exists |
| `cross_repo` | `"auto"` | Permit relevant protocols to consult Quarry when installed; `"off"` disables those calls |
| `redact` | `["*_SECRET", "*_TOKEN", "*_PASSWORD", "*_KEY"]` | Case-insensitive environment-variable name patterns whose values must not appear in generated reference text |
| `pipeline` | absent/null | Project-only remembered choice between start and map for an existing-code repository; true/false records the answer |
| `workspaces` | absent/null | Project-only list of `{ "name", "path" }` entries; each gets its own reference |

Expertise levels are 1: plain-language guidance, 2: explanations with introduced terminology, 3: normal technical vocabulary and recommended options, 4: terse engineering discussion with explicit numbers, 5: compact architectural tradeoffs. Teaching mode is independent of expertise.

## Useful project examples

A backend-only service that should commit its reference and skip automatic UI extraction:

```json
{
  "docs_in_git": "commit",
  "extract": ["logic"],
  "cross_repo": "auto"
}
```

A custom docs location:

```json
{
  "docs_dir": "docs/reference",
  "index_file": "docs/reference/00-index.md"
}
```

Keep that configuration at `docs/capstone/capstone.json`. Setting both paths avoids leaving the index at an unintended default. When running the Bash check directly, pass `docs/reference` explicitly; it does not use the model's complete configuration-resolution logic. The script has a custom-index caveat described in [edge cases](12-version-and-edge-cases.md).

Extending redaction replaces the whole list; repeat defaults you still need:

```json
{
  "redact": ["*_SECRET", "*_TOKEN", "*_PASSWORD", "*_KEY", "DATABASE_URL", "INTERNAL_CREDENTIAL"]
}
```

Patterns match names, not arbitrary secret values. `*_KEY` covers names ending in `_KEY`; `AWS_*` covers a prefix. A matching variable's Default cell becomes `<redacted>`, and its value must not appear in surrounding prose or configuration excerpts. This is distinct from the checker's six credential-shaped text patterns and does not amount to a full secrets audit.

## Monorepos

Example project configuration:

```json
{
  "workspaces": [
    {"name": "billing", "path": "services/billing"},
    {"name": "portal", "path": "apps/portal"}
  ]
}
```

Each workspace gets `<path>/docs/capstone/`; the root index becomes an index of workspace indexes. Root project settings inherit into the workspaces, then global defaults apply. A workspace manifest detected during mapping can be offered as configuration, but is not silently accepted.

```text
/capstone:map
/capstone:map billing
```

The first maps/refreshes all configured workspaces; the second targets that workspace. Other commands choose the workspace touched by the request and ask if ambiguous. Avoid ambiguous workspace names that are also map topic names.

The workspace name is also the Quarry target name:

```sh
quarry init --url <docs-repo-url> --name billing --docs-dir services/billing/docs/capstone
quarry init --name portal --docs-dir apps/portal/docs/capstone
```

Replace the URL before running. The reference must be committed on the source default branch before importing. Capstone's cross-repository lookups use `billing` or `portal`, not the parent monorepo name, when the feature touches those workspaces.

Run the mechanical gate over explicit workspace directories in one invocation:

```sh
bash /absolute/path/to/capstone/skills/core/scripts/map-check.sh services/billing/docs/capstone apps/portal/docs/capstone
```

The result has one final verdict for the supplied docs areas.

## Headless runs and unavailable capabilities

`non_interactive: true` can select an offered default, such as a defaulted confirmation. It cannot approve a spec/plan, answer an unprovided interview decision, consent to writing main, or choose inline/subagents. Those decisions have no default, so the run reports the missing answer and stops. Headless configuration is appropriate for `map check`; it is not permission to run an unattended product interview to completion.

No Quarry CLI, `cross_repo: "off"`, or missing applicable interfaces chapter causes groom/plan to skip cross-repo calls. Missing browser capability makes frontend review source-based; missing image generation is reported during UI design. Neither creates evidence of a completed live check.

Sources: [configuration contract](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md), [actual initializer defaults](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/init-config.sh), [actual checker config lookup](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/map-check.sh), [workspace mapping](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/map.md#workspaces).
