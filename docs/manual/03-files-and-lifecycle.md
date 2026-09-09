# Generated files, schemas, and lifecycle

Paths below use the default docs directory. Most relocate with `docs_dir`; the project configuration remains at the fixed `docs/capstone/capstone.json` path. Capstone's final documents are meant to stand on their own: decisions and their rationale belong in these outputs, not only in a local interview transcript.

## Reference chapters

| File | What it tells a reader | Exact required `##` headings, in order |
| --- | --- | --- |
| `00-index.md` | Project orientation, module map, topic links, companion links | No required heading sequence or stamps; Topic/File and File/What it is tables are authoring conventions |
| `01-architecture.md` | Layers, boundaries, processes, messages, composition, client structure | Layers; Module boundaries; Entry points; Communication; Composition; Frontend |
| `02-models.md` | Entities, field tables, transformations, validation, migration-defined schema | Entities; Fields and types; Relationships; Boundaries; Validation; Schema |
| `03-conventions.md` | Observed coding practices, including exceptions and violations | Paradigm; Typing; Error handling; Dependency injection |
| `04-data-flow.md` | Lifecycles, state ownership, I/O boundaries, failure handling | Lifecycles; State; Side-effect boundaries; Failure paths |
| `05-dependencies.md` | Packages and services, wiring, researched picks and pending choices | Dev and tooling; External services |
| `06-testing.md` | Test locations, verified commands, doubles, observed coverage | Layout; Doubles; Coverage shape |
| `07-operations.md` | How to run/deploy, configuration, infrastructure, developer workflow | Processes; Configuration; Infrastructure; Developer workflow |
| `08-glossary.md` | Project-specific terms | Concepts |
| `09-interfaces.md` | Contracts produced/consumed by sibling repositories | Produces; Consumes |

`02-models.md` places each entity under `### <Entity>` in Fields and types. Every entity section needs a table with `Field`, `Type`, and `Required`; `Default` and `Notes` are optional. Names are lookup keys, not decorative titles. Enum values belong in Notes, for example `accepted: draft, published`.

The index does **not** carry a second copy of chapter freshness. Absent topics receive explanatory rows. Large subsystems may split a topic while preserving its number, such as `01-architecture-api.md` and `01-architecture-worker.md`.

## Observed file frontmatter

This is an illustrative shape, not a captured file:

```yaml
---
generated_at_commit: 0123456789ab
generated_date: 2026-09-09
capstone_version: 6.4.1
content_hash: abcdef012345
paths_covered:
  - ":(top)src/auth/**"
  - ":(top)src/routes/**"
---
```

`generated_at_commit` and `content_hash` are 12-character Git values. The date is when the file was generated; `capstone_version` identifies the writer's template generation. `paths_covered` is the set of source paths used for refresh, anchored at the repository root. If the manifest cannot be read, the writer omits the version rather than inventing one. Outside Git, commit/hash requirements are waived. Prescriptive design uses `mode: prescriptive`; interview outputs without coverage globs have different freshness rules.

The machine schema requires `generated_date` on generated Markdown other than the index. Git-specific keys are waived for prescriptive and non-Git outputs; scenario/UI records waive coverage keys when they have no `paths_covered`. The checker handles an absent or older version in its freshness pass, not as a duplicate schema finding.

## Product and design outputs

| Path | Purpose and main consumers | Lifecycle |
| --- | --- | --- |
| `mockup/README.md` | Product brief, surfaces, commercial model, Screens/Journeys/Scenarios tables; consumed by logic, uiux, architecture | Final reference; amended when product decisions change |
| `mockup/NN-screen.md` | Layout, Elements, States; consumed by uiux and build | Final reference; rule questions are handed to logic |
| `logic/NN-scenario.md` | Exact rules, branches, failures, transitions, invariants; consumed by architecture, groom, plan, build | Observed files refresh from code; interview decisions absorb shipped features |
| `uiux/README.md` | Links design chapters to mockup screens and logic scenarios | Final folder index |
| `uiux/01-direction.md` | Chosen visual direction or observed incumbent design | Final reference |
| `uiux/02-system.md` | Tokens, components, Implementation constraints, Assets table; consumed by stack/build/review | Final reference |
| `uiux/03-experience.md` | Navigation, feedback, recovery, input, accessibility; consumed by build/review | Final reference |
| `uiux/screens/NN-screen.md` | Mode & job, Composition, States, Motion, Copy, Not in play | Final reference; numbering mirrors mockup screens |
| `uiux/preview.html` | Self-contained first viewport/style tile for steering decisions | Local, ignored, regenerated; not the design authority |
| `uiux/assets/*.svg` | Source brand marks | Kept in Git; build moves them into the app |
| `uiux/assets/*.{png,jpg,jpeg,webp}` and `uiux/assets/references/` | Raster exports and inspiration/reference material | Local and ignored |
| `standards.md` | User-chosen binding coding rules; used in planning and review | No coverage globs; map never regenerates it from code |
| `implementation.md` | Whole-product build plan and verification steps | Indexed instructional output retained by build |

Every logic scenario has these exact sections: Trigger & preconditions; Steps; Branches; Unhappy paths; State transitions; Invariants; Outcomes & side effects; Dimensions not in play. The final section distinguishes ruled-out dimensions from unanswered ones.

`standards.md` contains 17 domain headings and Not in play; the [design chapter](06-design-and-stack.md) lists them. `uiux/02-system.md` has an Assets table with `Asset | File | Source | Status`, and the code build stops for `awaited` assets.

## Working files and durable history

| Path | Meaning | Who reads it next; retention |
| --- | --- | --- |
| `*-interview.md` | Questions, answers, open items, lifecycle frontmatter | The unfinished stage; ignored, never indexed |
| `features/<date>-<slug>/feature-interview.md` | Feature lifecycle, approval checksum, execution choice, base commit | Groom/plan/implement resume; ignored |
| `features/<id>/spec.md` | What and why, requirements, approach, behavior, reference impact, exclusions | Plan and implement; ignored, later absorbed and deleted |
| `features/<id>/plan.md` | Constraints, file map, ordered tasks, checkboxes, coverage | Implement; ignored, later deleted |
| `features/<id>/review-ledger.md` | Confirmed/refuted findings and dry-round state | Implement's review resume; ignored, later summarized and deleted |
| `review.md` | Opt-in backend/frontend findings with separate side stamps | Human review; ignored and regenerated per side |
| `questionnaires/YYYY-MM-DD-recipient.md` | Questions for someone outside the interview | Recipient and owning stage; kept in Git after answers arrive |
| `changelog.d/YYYY-MM-DD-stage-target.md` | One complete event entry, keyed to a stage and revision | All lifecycle checks; committed until folded on the default branch |
| `changelog.md` | Folded decision/event ledger, newest first | Resume, check, doctor, later features; always committed |
| `changelog-YYYY.md` | Rotated older entries with keys intact | Same ledger readers; always committed |
| `capstone.json` at the fixed project path | Shared settings, pipeline fork, workspace state | Every command; always committed, never indexed |
| `.gitignore` in the docs area | Local-only output rules | Git; committed |

The factual reference follows `docs_in_git`; interviews, feature files, previews, rasters, and review reports remain local regardless of that choice. Ledger, project configuration, and questionnaires are committed exceptions. A fresh clone can consume completed reference outputs and their ledger without the interviews. It cannot recover unfinished local Q&A, feature plans, or checked task state that were never copied there.

Each writing stage records its ledger entry before its done marker. New entries are fragments; a later writing run on the default branch folds them. Past 200 folded entries, all but the newest 100 move into year files. Keys remain searchable in fragments and rotation files. A shipped feature's folder is deleted only after its wrap; its `implement/<id>` key then tells later runs it is done.

## Find the event that completed a stage

Ledger keys are internal durable identifiers, not commands. Search `changelog.md`, year files, and pending fragments together. `<id>` is a feature identifier; `<stamp>` is the run's source/date stamp; `Q<n>` is the highest incorporated interview entry. Question numbers may appear in these keys, but final chapters should not send readers back to the interview.

| Event | Key form |
| --- | --- |
| Map write | `map/<topic-or-all>@<stamp>` |
| Doctor repair | `doctor/<scope>@<stamp>` |
| Codebase review | `review/<backend-or-frontend-or-all>@<stamp>`; repeat events at one stamp receive a suffix |
| Retro standards edit | `retro/<all-or-domain>@<stamp>` |
| Mockup formalization | `mockup/all@Q<n>` |
| Logic scenario written or deliberately dropped | `logic/<NN-scenario>@Q<n>` |
| UI interview formalization | `uiux/all@Q<n>` |
| Standalone observed UI extraction | `uiux/all@<stamp>` |
| No visual UI | `uiux/skipped@<stamp>` |
| Architecture formalization | `architecture/all@Q<n>` |
| Standards formalization | `standards/all@Q<n>` |
| Initial stack selection | `stack/all@Q<n>` |
| Stack re-vetting | `stack/refresh@Q<n>` |
| Cross-stage readback | `readback/all@<stamp>`; corrections also get their owning stage's entries |
| Whole-product plan approval / code completion | `build/plan@Q<n>` / `build/code@Q<n>` |
| Feature spec / plan / completed wrap | `groom/<id>@Q<n>` / `plan/<id>@Q<n>` / `implement/<id>@Q<n>` |

`start` and `feature` normally route rather than create an event of their own; their writing stages record the work. Readback is start's named exception. `help`, `core`'s help route, and `map check` write no event. A no-op map or report-only doctor/retro also has no repair/write entry.

Generated sections may be rewritten. Manual prose edits are not generally preserved. The explicit protected exceptions are ledger history and previously confirmed `to`/`from` values on still-existing interface rows. Keep durable design decisions in their owning final files and let the relevant command record changes.

Sources: [machine schema](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/schema.txt), [topic definitions](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/topics.md), [index and ignore rules](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core-authoring.md), [ledger and lifecycle](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md).
