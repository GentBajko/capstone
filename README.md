# Capstone

AI coding agents have no memory. Every session starts with your agent
poking around the repo, guessing at module boundaries, and rebuilding a
mental model it throws away an hour later. You pay for that in tokens
and minutes, every day, and the model still gets things subtly wrong.

Capstone is the fix. It writes architecture docs meant for an AI
reader, stamps them with the git commit they came from, and on later
runs rewrites only the parts the code actually changed. Your agent
opens one index and eight chapters and already knows the codebase. No
exploration phase, no guessing.

For new projects it works in the other direction: five interviews that
pull the product, the business rules, the frontend design, the
architecture, and your coding taste out of your head before any code
exists — then a research pass that picks your actual stack with you,
and a build stage that turns all of it into running code.

It runs in Claude Code, Copilot CLI, Gemini CLI, Antigravity, and
OpenCode today. Codex, Cursor, and Kimi manifests ship in the repo but
those stores need a listing first. The skills are plain `SKILL.md`
files, so wherever skills work, this works.

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

Everything is facts with `file:line` citations. No advice, no grades,
no "consider refactoring". The one exception is `/capstone:review`,
which judges only because you asked it to.

Refreshes are cheap: `/capstone:sync` rewrites only the chapters whose
listed paths changed since their stamped commit — untouched chapters
are never touched. `/capstone:sync check` reports staleness without
writing anything, and `/capstone:ask` answers
questions from the docs with citations instead of re-reading your
source.

## The five interviews

Type `capstone` with nothing else and it runs them in order, resuming
wherever you stopped last time. Or run any one directly. Every answer
is written to a file before the next question, so a dead session loses
nothing.

### mockup

Product discovery. Three fixed questions (what is it, who's it for,
what does success look like in numbers), then every question after that
is generated from your answers. The driving rule: "if I had to build
the mockup right now, what would I have to invent?" It keeps asking
until the answer is nothing, or you tell it to stop. You get one
markdown file per screen — an ASCII wireframe, every element with its
exact copy and behavior, the empty/error/success states — each
annotated with the interview answers it implements. Anything it had to
assume is flagged for you to check.

### logic

A mockup shows what screens exist; `logic` pins down what actually
happens. It takes one scenario at a time and walks it until a developer
could implement it without inventing a single rule: the exact steps,
the formulas with real numbers, what happens when the payment fails,
when the user clicks twice, when two people edit at once. One markdown
file per scenario. This is the part of a spec that everyone skips and
then pays for.

### design

The mockup says what's on each screen; `design` decides how it looks
and feels. It reads the screens and the logic, proposes a design read
(what kind of surface, for whom, in what language), then interviews
you through the visual world, the tokens (type, color, spacing,
motion), and each screen's composition and states. If you have the
`impeccable` or `design-taste-frontend` skills installed it runs their
actual flows — concept candidates, the anti-convergence roll, the
craft floor — and records the outcome; without them a vendored
distillation of both carries the same method. The output is a design
folder `build` implements: a direction contract, a design-system
chapter `stack` honors, and one design file per mockup screen.

### architecture

The big interview. It isn't done until every section of the future docs
is answerable from your recorded decisions. One question at a time. It
reads the mockup and logic files first and never re-asks what they
already answer. At the end you approve the summary, and it writes the
same eight chapters as `generate`, marked prescriptive. Once real code
exists, refresh runs replace intent with observation and note where the
implementation diverged from the plan.

### code-prefs

How you want code written: strict typing or loose, a library or
hand-rolled, exceptions or result types, what an AI assistant must
never do in your repo. If a codebase already exists it reads the
conventions chapter first and asks "the code does X everywhere, is that
a preference or an accident?" The output is a normative doc that the
architecture interview and `review` both consume. It's also a decent
starting point for a CLAUDE.md.

### then: stack, then build

After the interviews, `stack` does the shopping: for every capability
the design needs (database, auth, payments, hosting, UI kit, ...), it
researches what's actually out there — OSS and paid, with licenses and
real pricing — filters by your code-prefs, and shows you two to four
options with pros and cons. You pick; the picks land in the
dependencies chapter with the reasoning attached.

`build` closes the loop. It researches how your chosen pieces connect,
writes an implementation plan — module layout, the load-bearing wiring
as real code sketches, backend first, then frontend, walking-skeleton
slice up front — and stops for your approval. Then it writes the code.
If the superpowers plugin is installed it hands the plan to
superpowers' execution flow; otherwise it executes step by step
itself. It's one of the two capstone commands allowed to touch your source
tree, and only after you've seen the plan.

## After build: the feature chain

The pipeline ends with a running project; the feature chain is how it
grows. `/capstone:implementation add CSV export` takes one feature
from idea to code in three gated stages — and each stage is also a
command of its own:

`groom` is brainstorming with the reference open. It reads the
chapters the feature touches (refreshing stale ones first), the logic
scenarios it extends, and your code-prefs, then interviews you one
question at a time — competing approaches with trade-offs, unhappy
paths, scope cuts — and writes a spec where every requirement traces
to an answer you gave. A feature that contradicts a recorded design
decision becomes a question, never a silent override.

`plan` turns the spec into a task-by-task TDD plan an engineer with
zero context could follow: exact paths, complete code in every step,
run-and-verify commands, backend before frontend. You approve the
plan before anything executes.

`implement` writes the code. With superpowers installed it hands your
spec and plan to superpowers' execution flow; without it, it executes
inline, checking off tasks as their verifications pass. Then it
reviews the full diff recursively — a different lens each round,
every finding adversarially verified, fixes fed back into the next
round — until two consecutive rounds find nothing new. Only then does
it refresh the affected chapters, so the reference records what was
actually built.

Everything persists under `docs/capstone/features/<NN>-<slug>/`, so a
dead session resumes mid-chain exactly where it stopped.

## Who it's for

If you vibe-code: set `expertise: 1` and the interviews switch to plain
language. It asks how many people might use the thing, not what your
p99 latency budget is, then derives the technical targets itself and
confirms them in words you can sanity-check. You end up with real specs
and real docs anyway, because expertise changes the conversation, never
the output.

If you're a seasoned engineer: set `expertise: 5`, get terse questions
and trade-off tables, and skip the hand-holding. The value for you is
the maintained reference: agents stop re-deriving your layering every
session, and stop guessing wrong about it.

## Settings

First run creates `docs/capstone/capstone.json` with every key spelled
out:

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

`expertise` is 1 to 5 as above. It starts `null` so the first
interactive command asks once, saves your answer, and never asks again.
`docs_in_git` set to `"commit"` or `"ignore"` skips the question about
whether the generated docs belong in version control, which also makes
headless runs possible — it governs the factual reference only. Some
outputs are personal working state and are never committed whatever it
says: `features/` (the whole `groom` → `plan` → `implement` chain),
every `*-interview.md`, `capstone.json`, `review.md`, and
`changelog.md`. Capstone writes `docs/capstone/.gitignore` listing
exactly those, and the feature chain never commits the docs area at all
— it commits source code only. `subagent_threshold` is the source-file count
above which `generate` fans out parallel subagents instead of reading
everything itself. `pipeline` records the answer to the one-time
question `start` asks on repos that already have code: pipeline or
generate. `workspaces`, when set, gives each workspace its own docs
area under its path, with the root `DESIGN.md` as an
index-of-indexes.

## Install

Any agent, via the skills CLI's interactive installer (it detects
your installed agents and offers a per-agent selection; pick ALL
capstone skills — `core` carries the shared rules the others read):

```bash
npx skills add GentBajko/capstone
```

Claude Code:

```
/plugin marketplace add GentBajko/capstone
/plugin install capstone@capstone-marketplace
```

To get updates automatically: `/plugin` → Marketplaces →
capstone-marketplace → Enable auto-update. Claude Code then pulls new
versions in the background and prompts `/reload-plugins` when one
lands. (Or set `"autoUpdate": true` on the marketplace entry in
`~/.claude/settings.json`.)

Copilot CLI uses the same marketplace format:

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

Commands come out namespaced (`/capstone:generate`). If you want a bare
`/capstone` in Claude Code, drop this in `~/.claude/commands/capstone.md`:

```markdown
---
description: Capstone entry - no args runs the pipeline; args route to the matching skill
argument-hint: [command] [args...]
---

No arguments: invoke the capstone:start skill. If the first argument
matches a capstone skill (generate, sync, doctor, ask, changelog, review,
guides, onboarding, mockup, logic, design, architecture, code-prefs,
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
| `/capstone:changelog [<ref>]` | Architecture-level change history since a ref — and the append-only ledger every writing command records itself in |
| `/capstone:review` | The opt-in judgment: ranked findings with evidence |
| `/capstone:guides [<task>]` | Runbooks: run locally, deploy, plus workflows mined from your repo's patterns |
| `/capstone:onboarding` | A reading path for someone's first day in the codebase |
| `/capstone:mockup` | Interview 1, standalone |
| `/capstone:logic` | Interview 2, standalone |
| `/capstone:design` | Interview 3, standalone: the frontend design — direction, tokens, per-screen chapters |
| `/capstone:architecture` | Interview 4, standalone |
| `/capstone:code-prefs` | Interview 5, standalone |
| `/capstone:stack` | Research libraries and services per capability, with pros/cons and pricing; you pick |
| `/capstone:build` | Implementation plan (backend, then frontend), your approval, then working code — via superpowers when installed |
| `/capstone:groom <feature>` | Doc-grounded feature interview → a traceable spec in `docs/capstone/features/` |
| `/capstone:plan <feature>` | Task-by-task TDD plan from the groomed spec; you approve before any code |
| `/capstone:implement <feature>` | Execute the approved plan into code, review until dry, then refresh the affected chapters |
| `/capstone:implementation <desc>` | The feature chain: groom → plan → implement, resuming at the first unfinished stage |
| `/capstone:help` | Usage. In Claude Code a hook answers this before the model is invoked, so it costs zero tokens |

Renamed in 3.0: `docs` split into `generate` (from scratch) and
`sync` (incremental refresh); `check-docs` became `sync check`.

## CI

Copy `templates/capstone-sync-check.yml` into your repo's
`.github/workflows/` and add an `ANTHROPIC_API_KEY` secret: every PR
then runs `sync check` headlessly and fails when the reference is
stale (the job parses the report's final `SYNC CHECK:` line).

## Rough edges

The zero-token help trick is Claude Code only; other harnesses spend one
small model turn on it. The PowerShell twins run in CI on a real
Windows runner (both shells); broader Windows field-testing is thin. The `logic` interview on a real
app is an afternoon, not ten minutes, and that's by design. Retrieval
is grep over eight markdown files, which is plenty at this scale and
unproven on giant monorepos.

MIT. Issues and PRs welcome.
