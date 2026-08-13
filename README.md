# Capstone

AI coding agents have no memory. Every session starts with your agent
poking around the repo, guessing at module boundaries, and rebuilding
a mental model it throws away an hour later. You pay for that in
tokens and minutes, every day, and the model still gets things subtly
wrong.

Capstone is the fix. It writes architecture docs meant for an AI
reader, stamps them with the git commit they came from, and on later
runs rewrites only the parts the code actually changed. Your agent
opens one index and eight chapters and already knows the codebase. No
exploration phase, no guessing.

For new projects it works in the other direction: a pipeline of
interviews that pulls the product, the rules, the design, the
architecture, and your coding taste out of your head, then builds the
thing.

It runs in Claude Code, Copilot CLI, Gemini CLI, Antigravity, and
OpenCode, plus any of the 70+ agents the skills.sh CLI installs into
(`npx skills add GentBajko/capstone`).

## The docs

`/capstone:generate` on an existing repo produces a `DESIGN.md` index
and eight numbered chapters in `docs/capstone/`:

```
01-architecture.md   layers, boundaries, entry points, dispatch tables
02-models.md         entities, relationships, schema DDL, validation
03-conventions.md    paradigm, typing level, error handling, DI
04-data-flow.md      lifecycles hop by hop, state ownership, failure paths
05-dependencies.md   every package, what it's for, where it's wired
06-testing.md        layout, test doubles, coverage shape
07-operations.md     how to run it, env vars, infra, deploy
08-glossary.md       the domain words your codebase invented
```

Everything is facts with `file:line` citations, never advice.
`/capstone:sync` refreshes only what drifted; `sync check` reports
staleness, citation drift, and unabsorbed features without writing a
byte. `/capstone:ask` answers questions from the docs instead of
re-reading your source. `/capstone:doctor` repairs the docs area's own
wounds. And every command declares exactly what it reads before
acting, so re-runs don't burn tokens re-exploring what the docs
already know.

## The pipeline

Type `capstone` and it runs the stages in order, resuming wherever you
stopped. Every answer is written to disk before the next question, so
a dead session loses nothing. Each interview takes an optional
artifact (a PRD, screenshots) and pre-fills what it answers. On
existing codebases, `logic` and `design` run in reverse: they draft
from the observed code and you confirm.

### mockup

Product discovery. Three fixed questions, then every question after
that is generated from your answers until nothing is left to invent.
One file per screen: ASCII wireframe, exact copy and behavior, the
empty/error/success states, each traced to the answer it implements.
No visual UI? It records your surfaces (api, cli) and the design stage
skips itself.

### logic

One scenario at a time, walked until a developer could implement it
without inventing a single rule: exact steps, real formulas, what
happens when the payment fails or the user clicks twice. This is the
part of a spec everyone skips and then pays for.

### design

How it looks and feels: a design read, the visual world, the tokens,
each screen's composition and states. Runs the `impeccable` and
`design-taste-frontend` skills when installed, vendored distillations
of both otherwise. Output: a direction contract, a design-system
chapter `stack` honors, one file per screen for `build` to implement.

### architecture

The big interview. Done only when every section of the future docs is
answerable from your recorded decisions. Writes the same eight
chapters, marked prescriptive; once code exists, `sync` replaces
intent with observation and records the divergences.

### code-prefs

How you want code written: typing strictness, library versus
hand-rolled, error handling, what an AI must never do in your repo.
Also a decent starting point for a CLAUDE.md.

### stack, then build

`stack` researches real options per capability, licenses and prices
included; you pick, and `stack refresh` re-vets the picks months
later. `build` writes an implementation plan, stops for your
approval, then writes the code, via superpowers when installed.

## The feature chain

`/capstone:implementation add CSV export` grows a finished project one
feature at a time: `groom` interviews a spec out of you against the
reference, `plan` turns it into a task-by-task TDD plan (a vendored
TDD + YAGNI ladder trims every task; your code-prefs outrank it), and
`implement` executes, reviews the diff until two consecutive rounds
find nothing new, then absorbs the shipped behavior back into the
scenario docs. A dead session resumes mid-chain.

## The reviews

Two commands are allowed opinions, only when invoked. `fe-review`
judges the UI against your own design docs first, then a vendored
craft floor, then each screen's mode, screenshotting the live app when
it can. `be-review` covers architecture and backend: shallow modules
by the deletion test, change-smells in the git hot paths, security,
stack currency. Both delegate to installed skills (impeccable,
design-taste-frontend, mattpocock/skills, security-review) and carry
vendored fallbacks. One rule binds every source: your recorded
decisions outrank generic best practice.

## Who it's for

Vibe coders: set `expertise: 1` and everything happens in plain
language, with capstone narrating what it's doing and why as it works
(level 2 adds the proper term for each concept, so you learn the craft
along the way). The output stays rigorous either way.

Engineers: set `expertise: 5` for terse questions and trade-off
tables. The value is the maintained reference: agents stop re-deriving
your layering every session.

## Settings

First run creates `docs/capstone/capstone.json`:

```json
{
  "expertise": null,
  "docs_dir": "docs/capstone",
  "index_file": "DESIGN.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en",
  "pipeline": null,
  "workspaces": null
}
```

`expertise` (1 to 5) is asked once and saved. `docs_in_git` governs
the factual reference only; interviews, `features/`, the reviews, and
the changelog stay local via a generated `.gitignore`.
`subagent_threshold` is the source-file count above which `generate`
fans out subagents. `pipeline` records the one-time pipeline-or-
generate choice on repos that already have code. `workspaces` gives
each monorepo workspace its own docs area with the root `DESIGN.md`
as an index-of-indexes.

## Install

Any agent, via the skills CLI (install ALL capstone skills; `core`
carries the shared rules the others read):

```bash
npx skills add GentBajko/capstone
```

Claude Code:

```
/plugin marketplace add GentBajko/capstone
/plugin install capstone@capstone-marketplace
```

Auto-updates: `/plugin` → Marketplaces → capstone-marketplace →
Enable auto-update.

Copilot CLI:

```bash
copilot plugin marketplace add GentBajko/capstone
copilot plugin install capstone@capstone-marketplace
```

Gemini CLI: `gemini extensions install https://github.com/GentBajko/capstone`

Antigravity: `agy plugin install https://github.com/GentBajko/capstone`

OpenCode, in `opencode.json`:

```json
{ "plugin": ["capstone@git+https://github.com/GentBajko/capstone.git"] }
```

Commands come out namespaced (`/capstone:generate`). For a bare
`/capstone` in Claude Code, drop this in `~/.claude/commands/capstone.md`:

```markdown
---
description: Capstone entry - no args runs the pipeline; args route to the matching skill
argument-hint: [command] [args...]
---

No arguments: invoke the capstone:start skill. If the first argument
matches a capstone skill (generate, sync, doctor, ask, changelog,
be-review, fe-review, guides, onboarding, mockup, logic, design, architecture, code-prefs,
stack, build, groom, plan, implement, implementation, start, help),
invoke capstone:<that skill> with the remaining arguments.

ARGUMENTS: $ARGUMENTS
```

## Commands

| Command | What it does |
| --- | --- |
| `/capstone:start` | The pipeline: mockup → logic → design → architecture → code-prefs → stack → build, resuming at the first unfinished stage |
| `/capstone:generate` | Build the reference from scratch (`rebuild` forces, a topic name targets one chapter) |
| `/capstone:sync` | Refresh what drifted; `sync check` is the read-only trust report |
| `/capstone:doctor` | Diagnose and repair the docs area: torn writes, index drift, voided approvals, absorption gaps |
| `/capstone:ask <question>` | Answer from the docs, with citations |
| `/capstone:changelog [<ref>]` | Architecture-level change history since a ref, plus the append-only ledger every writing command records itself in |
| `/capstone:be-review` | The opt-in judgment: architecture and backend findings, ranked with evidence |
| `/capstone:fe-review` | The opt-in UI judgment: improvements graded against your own design docs, via impeccable/design-taste when installed |
| `/capstone:guides [<task>]` | Runbooks: run locally, deploy, plus workflows mined from your repo's patterns |
| `/capstone:onboarding` | A reading path for someone's first day in the codebase |
| `/capstone:mockup` | Interview 1, standalone |
| `/capstone:logic` | Interview 2, standalone |
| `/capstone:design` | Interview 3, standalone: the frontend design (direction, tokens, per-screen chapters) |
| `/capstone:architecture` | Interview 4, standalone |
| `/capstone:code-prefs` | Interview 5, standalone |
| `/capstone:stack` | Research libraries and services per capability, with pros/cons and pricing; you pick (`refresh` re-vets recorded picks) |
| `/capstone:build` | Implementation plan (backend, then frontend), your approval, then working code, via superpowers when installed |
| `/capstone:groom <feature>` | Doc-grounded feature interview → a traceable spec in `docs/capstone/features/` |
| `/capstone:plan <feature>` | Task-by-task TDD plan from the groomed spec; you approve before any code |
| `/capstone:implement <feature>` | Execute the approved plan into code, review until dry, then refresh the affected chapters |
| `/capstone:implementation <desc>` | The feature chain: groom → plan → implement, resuming at the first unfinished stage |
| `/capstone:help` | Usage. In Claude Code a hook answers this before the model is invoked, so it costs zero tokens |

Renamed in 3.0: `docs` split into `generate` and `sync`; `check-docs`
became `sync check`. In 3.1, `review` became `be-review` and
`fe-review` joined it.

## CI

Copy `templates/capstone-sync-check.yml` into `.github/workflows/`,
add an `ANTHROPIC_API_KEY` secret, and every PR fails when the
reference is stale.

## Rough edges

The zero-token help trick is Claude Code only. The PowerShell twins
run in CI on a real Windows runner, but broader Windows field-testing
is thin. Budget an afternoon for the `logic` interview on a real app;
the depth is the point. Retrieval is grep over eight markdown files,
plenty at this scale and unproven on giant monorepos.

MIT. Issues and PRs welcome.
