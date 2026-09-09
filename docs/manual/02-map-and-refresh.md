# Map an existing repository and refresh it

Run this inside a repository that already has code:

```text
/capstone:map
```

The agent reads manifests, lint and typing configuration, project instructions, directories, and entry points. It builds a module map, studies each applicable topic, and writes a reference under `docs/capstone/` by default. An empty repository with no source, entry points, or manifests has nothing to describe: the run stops without writing a map and points to `start` or `architecture`.

The smallest useful follow-up is a question grounded in the new index:

```text
Read docs/capstone/00-index.md. Where is authentication enforced?
Explain the request flow and cite the source files that enforce it.
```

This prompt is illustrative, not another Capstone command. Open the cited source to verify the answer. The reference is intended to reduce repeated exploration, not replace source inspection when exact behavior matters.

## What map writes

The index links to applicable numbered chapters from `01-architecture.md` through `09-interfaces.md`, descriptive business scenarios in `logic/`, and observed frontend documentation in `uiux/`. Absent topics keep their chapter numbers and receive an index row explaining why they do not apply; the next chapter is not renumbered to fill the gap. See [the file catalog](03-files-and-lifecycle.md).

Map writes observations with source citations. It does not change source code, settle coding preferences, or silently redesign the application. `standards.md` records binding choices; `review` judges divergences. A vendor dependency alone does not make `09-interfaces.md` applicable: that chapter describes relationships with sibling codebases. Stripe or object storage belongs in the dependencies chapter.

Map also creates the docs area's ignore rules through the initializer. If the factual reference is untracked and the project has not chosen a policy, `docs_in_git: "ask"` prompts whether to track or ignore it. Local interview/feature files remain ignored; the ledger and project config have separate tracking rules.

## Select the right map operation

| Invocation | Behavior |
| --- | --- |
| `/capstone:map` with no index | Full initial map |
| `/capstone:map` with an index and topic files | Refresh affected files and fill coverage gaps |
| `/capstone:map check` | Read-only script and model report; no refresh or ledger write |
| `/capstone:map models` | Regenerate the models topic; no scenario or UI extraction passes |
| `/capstone:map interfaces` | Regenerate contracts and aliases from code while preserving existing confirmed far ends |
| `/capstone:map rebuild` | Confirm and rewrite the full reference, including observed scenario/UI files |

Allowed topics are `architecture`, `models`, `conventions`, `data-flow`, `dependencies`, `testing`, `operations`, `glossary`, and `interfaces`. A topic run asks before overwriting a current chapter. `rebuild` asks once before replacing everything it owns. Even rebuild does not overwrite interview-derived logic or design files.

## How refresh decides what changed

Each observed chapter records source coverage globs, a generation commit, a content hash, a date, and the Capstone version. The index itself has no freshness stamps. Map compares covered paths against the working tree, including uncommitted changes and untracked files in those paths.

If a squash or rebase makes the commit unreachable, it compares the stored hash with current Git index entries and also checks whether the working tree is dirty. This avoids making every lost commit stamp trigger a whole-repository rewrite. The hash is not a summary of prose and not a semantic comparison of code: it is derived from Git's tracked entries under the covered globs.

Source drift is not the only trigger. Refresh also checks missing required sections, older or absent `capstone_version`, newly applicable topics, missing scenario or surface coverage, and final documents improperly referring readers to private interview files. A file can therefore need refresh even when its covered source did not change. Conversely, a change outside a chapter's declared coverage does not automatically make that chapter stale; accurate globs matter.

Prescriptive architecture becomes observed documentation when tracked source exists. Map records design-versus-implementation differences and keeps the design rationale. In the dependencies chapter, a researched choice not yet installed remains recorded as **picked but not yet installed**; refresh does not erase it simply because the manifest lacks it.

When every file is current, map leaves the files and stamps unchanged and does not fold pending changelog fragments. A writing run adds a `map/<scope>@<stamp>` ledger entry and folds fragments only on the default branch. Without Git, there is no commit-based freshness calculation: map warns that it is doing a full build on subsequent runs too.

## Size, extraction, and existing decisions

At or below `subagent_threshold` (150 tracked source files by default), a standalone map studies topics inline. Above it, the protocol uses parallel read-only topic subagents when available; otherwise it works sequentially inline. An explicit inline choice inherited from `feature` or `start` overrides that threshold for the entire run.

When another command needs a missing reference, it can map first and continue. Above the threshold, an unrequested initial map requires confirmation. Declining does not authorize the dependent command to proceed with invented context. Map retries this bootstrap at most once.

`extract` controls automatic `logic` and `uiux` extraction. Map's extraction writes descriptions directly; a standalone `logic` or `uiux` interview has its own confirmation behavior. Files derived from interviews do not gain observed-code ownership merely because map ran. Use `implement` to absorb shipped feature behavior into those files, or `review` to report drift from a chosen design.

Sources: [map protocol](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/map.md), [topic applicability](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/topics.md), [shared execution and bootstrap rules](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md).
