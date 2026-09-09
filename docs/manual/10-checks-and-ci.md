# Freshness checks, schema checks, and CI

There are two halves of `map check`. The Bash script handles mechanical evidence without a model or API key. The agent adds pointer, absorption, dependency, and coverage review. They have different verdicts and different limitations.

To run both through the agent:

```text
/capstone:map check
```

To run only the mechanical half from your project root, using an installed/source copy of the same Capstone version:

```sh
bash /absolute/path/to/capstone/skills/core/scripts/map-check.sh docs/capstone
```

The full Capstone tree matters: the script reads the neighboring `references/schema.txt` and the plugin manifest. Copying only the script omits the schema/version information it expects.

## Mechanical report

| Part | Evidence checked |
| --- | --- |
| 1. Staleness | Covered-source changes, unreachable stamps/hash fallback, writer version, prescriptive files pending observation |
| 7. Ledger fragments | Existing `changelog.d/` files and their keys; informational, not a failing condition |
| 8. Schema | Required metadata/headings/order/table columns, interface sites/payload/model references, six secret-shaped text patterns |

These final verdict forms are literal script contracts:

```text
MAP CHECK: current
MAP CHECK: stale (<N> findings)
```

`<N>` is replaced by the finding count. Exit code 0 means current, 1 means findings, and 2 means invalid usage such as an unknown flag or a supplied path that is not a directory. An existing docs directory without its index is a finding and reaches the stale verdict; a nonexistent directory exits as usage failure.

Informational commands are also literal supported shell options:

```sh
bash /absolute/path/to/capstone/skills/core/scripts/map-check.sh --help
bash /absolute/path/to/capstone/skills/core/scripts/map-check.sh --schema
bash /absolute/path/to/capstone/skills/core/scripts/map-check.sh --headings
bash /absolute/path/to/capstone/skills/core/scripts/map-check.sh --patterns
```

`--schema` prints the resolved file and record count; the inspected 6.4.1 source contains 23 records. `--headings` prints each topic's ordered headings. `--patterns` prints pattern names and regular expressions. These flags do not run the full report.

The schema uses first-match file patterns. Extra headings and columns are allowed, but required headings must appear in order. A required section may honestly say no applicable content was found. Entity subtables under Fields and types require `Field`, `Type`, and `Required`; an empty entity section is not excused the way an inapplicable general section can be.

On interfaces, a site must name one tracked file, not a directory or wildcard. Legacy `:line` suffixes are stripped. Prescriptive planned sites and non-Git projects skip tracked-site verification, but payload/model text checks still apply. `known_as` must be a YAML list, even when empty. The script does not resolve `to`/`from` repository names; Quarry handles that.

## The model's report

The agent first includes the script output, then adds:

| Part | Scope |
| --- | --- |
| 2. Pointer drift | First five source citations from stale files in index order; if none are stale, first five from the first chapter |
| 3. Absorption | Shipped feature ledger entries not absorbed into interview-derived logic/mockup/UI docs |
| 4. Dependency re-vetting | Recorded versus installed picks/floors, and research older than six months |
| 5. Logic coverage | Externally triggerable behavior lacking a scenario |
| 6. Design coverage | Frontend surfaces lacking a screen chapter |

Its final forms are:

```text
MAP REVIEW: clean
MAP REVIEW: <N> findings
```

These are model protocol outputs rather than a shell process's independent semantic proof. The count covers parts 2–6. Disabled extraction passes report disabled, not missing; no frontend reports design coverage not applicable. Outside Git, the model side falls back to pointer drift.

Both halves are read-only. They do not regenerate files, fold fragments, record ledger entries, or fix findings. Run map for stale observed material, stack refresh for outdated research, or doctor for documentation-state repair.

## Add the supplied GitHub Actions templates

First generate and commit the reference. Then copy the source version's `templates/capstone-map-check.yml` to your repository's `.github/workflows/` directory through your normal review process. The 6.4.1 template:

- Runs on pull requests with an Ubuntu runner.
- Checks out full Git history.
- Clones Capstone's `v6.4.1` tag into the runner temporary directory.
- Runs the Bash script for `docs/capstone` and fails unless the last `MAP CHECK:` line is exactly current.

Adjust the docs-directory argument for custom paths or pass all workspace docs directories in the single script call. Keep the version pin deliberate: upgrading the checker can reveal documents written against older semantics even when their code did not change.

For the model half, use `templates/capstone-map-review.yml` and provide the `ANTHROPIC_API_KEY` repository secret. That template runs at `03:17 UTC` daily and on manual dispatch. It installs Claude Code and the marketplace plugin, writes a headless global config, invokes `/capstone:map check`, and fails unless its last `MAP REVIEW:` line is clean. This template's plugin install is **not pinned to 6.4.1**; account for that when coordinating it with the pinned mechanical gate. The jobs deliberately consume different verdict lines.

For repositories connected to Quarry, run `quarry init` and `quarry check` alongside the freshness check on pull requests. Ensure the shared docs snapshot is sufficiently fresh; `quarry check --sync` requests a pull first. Capstone's template does not configure your Quarry registry or publish references for you.

## Boundaries of the checks

The secret scan recognizes six patterns: AWS access keys, GitHub tokens in the supported prefix shape, Slack tokens, Stripe secret keys, Google API keys, and private-key headers. It prints the pattern name, not the matched value. It skips ledger files/fragments, interviews, feature working files, reviews, configuration, ignore rules, and the UI preview. Tracked non-Markdown files in the docs area are scanned too; untracked non-Markdown scratch files inside Git are not. Therefore “schema: clean” is not a whole-repository secrets audit.

If the schema cannot be read, the script reports that headings/tables were not checked, applies its fallback checks, and can still print current. Missing semantic evidence, inaccurate coverage globs, and model mistakes are also outside a blanket guarantee. Read the report body as well as its last line.

Sources: [actual checker](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/map-check.sh), [schema](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/schema.txt), [model-half protocol](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/map.md), [PR template](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/templates/capstone-map-check.yml), [nightly template](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/templates/capstone-map-review.yml).
