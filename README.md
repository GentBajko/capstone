# Capstone

Architecture docs your AI agent reads instead of re-exploring the repo
every session. Stamped to commits, refreshed only where the code
moved. For new projects, an interview pipeline that designs the whole
thing before building it.

```text
existing repo ──▶ generate ──▶ docs/capstone/ index + 8 chapters ──▶ sync keeps them current
                                                            ▲
new project ──▶ mockup → logic → uiux → architecture → code-prefs → stack → build
                                                                              │
feature idea ──▶ groom → plan → implement ──▶ shipped code, absorbed into docs ◀┘
```

## Install

### Claude Code

```text
/plugin marketplace add GentBajko/capstone
/plugin install capstone@capstone-marketplace
```

### GitHub Copilot

```bash
gh skill install GentBajko/capstone --all --agent github-copilot
```

### Any other agent

70+ editors and CLIs via the skills CLI:

```bash
npx skills add GentBajko/capstone
```

Works in Claude Code, Copilot CLI, Gemini CLI, Antigravity, and
OpenCode. Plain `SKILL.md` files, MIT. Per-agent commands and the
bare-`/capstone` alias are under "Installing on other agents" below.

## Update

No reinstall needed. Update in place:

| Installed with | Update with |
| --- | --- |
| Claude Code plugin | `claude plugin marketplace update capstone-marketplace`<br>then `claude plugin update capstone@capstone-marketplace` |
| `gh skill` | `gh skill update capstone` |
| `npx skills` | `npx skills update` |

The Claude Code pair is two steps on purpose: the first refreshes the
marketplace clone, the second moves your install onto it. Restart to
apply. To skip it entirely, turn on auto-update: `/plugin` →
Marketplaces → capstone-marketplace → Enable auto-update.

> [!IMPORTANT]
> **Updates are additive.** `gh skill update` and `npx skills update`
> refresh files but never delete a skill that capstone has retired, so
> a removed command lingers on disk and keeps being offered to your
> agent. After any release that drops commands, compare
> `gh skill list` or `npx skills list` against the command table below
> and remove whatever is no longer there.

<details>
<summary>All commands</summary>

| Command | What it does |
| --- | --- |
| `/capstone:start` | The pipeline: mockup → logic → uiux → architecture → code-prefs → stack → build, resuming at the first unfinished stage |
| `/capstone:generate` | Build the reference from scratch (`rebuild` forces, a topic name targets one chapter) |
| `/capstone:sync` | Refresh what drifted and extract the `logic/` scenarios and `uiux/` surfaces the map is missing; `sync check` is the read-only trust report |
| `/capstone:doctor` | Diagnose and repair the docs area: torn writes, index drift, voided approvals, absorption gaps |
| `docs/capstone/changelog.md` | Not a command: the append-only ledger every writing command records itself in, before it sets its done marker |
| `/capstone:review [be\|fe]` | The opt-in judgment, into one `review.md`: no argument reviews both sides, `backend` takes architecture and `frontend` grades the UI against your own design docs |
| `/capstone:mockup` | Interview 1, standalone |
| `/capstone:logic` | Interview 2, standalone |
| `/capstone:uiux` | Interview 3, standalone: the frontend design (direction, tokens, per-screen chapters) |
| `/capstone:architecture` | Interview 4, standalone |
| `/capstone:code-prefs` | Interview 5, standalone |
| `/capstone:stack` | Research libraries and services per capability, with pros/cons and pricing; you pick (`refresh` re-vets recorded picks) |
| `/capstone:build` | Implementation plan (backend, then frontend), your approval, then working code in subagents or inline (you pick) |
| `/capstone:groom <feature>` | Doc-grounded feature interview → a traceable spec in `docs/capstone/features/` |
| `/capstone:plan <feature>` | Task-by-task TDD plan from the groomed spec; you approve before any code |
| `/capstone:implement <feature>` | Execute the approved plan into code, review until dry, then refresh the affected chapters |
| `/capstone:feature <desc>` | The feature chain: groom → plan → implement, resuming at the first unfinished stage |
| `/capstone:help` | Usage. In Claude Code a hook answers this before the model is invoked, so it costs zero tokens |

</details>

<details>
<summary>What do the generated docs look like?</summary>

`/capstone:generate` produces a `00-index.md`, eight numbered chapters
beside it in `docs/capstone/`, and a `logic/` folder mapping the
observed business logic scenario by scenario:

```text
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
`/capstone:sync` refreshes only what drifted and extracts any
business-logic scenarios the map is missing; `sync check` reports
staleness, citation drift, logic-coverage gaps, and unabsorbed
features without writing a byte. `/capstone:doctor` repairs the docs
area's own wounds. Every command declares exactly what it reads before
acting, so re-runs don't burn tokens re-exploring what the docs
already know, and a command that needs the reference and finds none
builds it first instead of sending you off to run `generate`.

</details>

<details>
<summary>How does the pipeline work, stage by stage?</summary>

Type `capstone` and it runs the stages in order, resuming wherever you
stopped. Every answer is written to disk before the next question, so
a dead session loses nothing. Each interview takes an optional
artifact (a PRD, screenshots) and pre-fills what it answers. On
existing codebases, `logic` and `uiux` run in reverse: they draft
from the observed code and you confirm.

**mockup**. Product discovery. Three fixed questions, then every
question after that is generated from your answers until nothing is
left to invent. One file per screen: ASCII wireframe, exact copy and
behavior, the empty/error/success states. No visual UI? It records
your surfaces (api, cli) and the uiux stage skips itself.

**logic**. One scenario at a time, walked until a developer could
implement it without inventing a single rule: exact steps, real
formulas, what happens when the payment fails or the user clicks
twice. The part of a spec everyone skips and then pays for.

**uiux**. How it looks and feels: a design read, the visual world,
the tokens, each screen's composition and states. The method is
vendored, distilled from `impeccable` (Apache-2.0) and
`design-taste-frontend` (MIT), so the same product designs the same
way on any machine. Output: a direction contract, a design-system
chapter `stack` honors, one file per screen for `build` to implement.

**architecture**. The big interview. Done only when every section of
the future docs is answerable from your recorded decisions. Writes
the same eight chapters, marked prescriptive; once code exists,
`sync` replaces intent with observation.

**code-prefs**. How you want code written: typing strictness,
library versus hand-rolled, error handling, what an AI must never do
in your repo. Also a decent starting point for a CLAUDE.md.

**stack, then build**. `stack` researches real options per
capability, licenses and prices included; you pick, and
`stack refresh` re-vets the picks months later. `build` writes an
implementation plan, stops for your approval, then writes the code:
one subagent per step with fresh context, or inline in the session,
whichever you pick when it starts.

</details>

<details>
<summary>How do features get added after v1?</summary>

`/capstone:feature add CSV export` grows a finished project one
feature at a time. `groom` interviews a spec out of you against the
reference. `plan` turns it into a task-by-task TDD plan; a vendored
TDD + YAGNI ladder trims every task, and your code-prefs outrank the
ladder on conflict. `implement` executes, reviews the diff until two
consecutive rounds find nothing new, then absorbs the shipped
behavior back into the scenario docs. A dead session resumes
mid-chain.

</details>

<details>
<summary>What is review?</summary>

The one command allowed opinions, only when invoked. It has two
sides and writes both into a single `docs/capstone/review.md`, each
section carrying its own stamp so you can tell how old each half is.

The **frontend** side judges the UI against your own design docs
first, then a vendored craft floor, then each screen's mode,
screenshotting the live app when it can. The **backend** side covers
architecture and backend: shallow modules by the deletion test,
change-smells in the git hot paths, security, stack currency.

Bare `review` runs both. `review backend` or `review frontend` runs
one and rewrites only that section, leaving the other untouched.
Both sides judge by capstone's own vendored craft files, so the same
codebase is judged the same way on any machine. A security-review
command or a live browser, where the harness has them, supply extra
evidence but never change the standard. One rule outranks the craft
baseline: your recorded decisions beat generic best practice. The file
is gitignored by default: it is judgment, not reference.

</details>

<details>
<summary>I'm not technical. Can I use this?</summary>

Yes. Set `expertise: 1` and everything happens in plain language:
capstone asks how many people might use the thing rather than what
your p99 latency budget is, derives the technical targets itself, and
confirms them in words you can sanity-check. Set
`teaching_mode: true` and it also narrates what it's doing and why as
it works, naming the proper term for each concept, one per step, so
you learn the craft along the way. The output stays
rigorous either way. Engineers set `expertise: 5` for terse questions
and trade-off tables.

</details>

<details>
<summary>Settings</summary>

Installing creates `~/.claude/capstone.json` (the first session after
install runs the plugin's SessionStart hook): one config for the
user, shared by every project:

```json
{
  "expertise": null,
  "teaching_mode": false,
  "docs_dir": "docs/capstone",
  "index_file": "docs/capstone/00-index.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en"
}
```

`expertise` (1 to 5) is asked once and saved. `teaching_mode: true`
makes capstone narrate and teach as it works, at any expertise level.
`docs_in_git` governs
the factual reference; interviews, `features/`, and the two reviews
stay local via a generated `.gitignore`. `changelog.md` is the one
exception and is always committed: `implement` deletes a feature's
folder once its ledger entry is written, so the ledger is the only
surviving record of why the feature was built that way.
`subagent_threshold` is the source-file count above which `generate`
fans out subagents. Project-scoped state lives in an optional
`docs/capstone/capstone.json`, created only when there is something to
record; any global key set there overrides the global file for that
repo, `pipeline` records the one-time
pipeline-or-generate choice on repos that already have code, and
`workspaces` gives each monorepo workspace its own docs area with the
root project's `00-index.md` as an index-of-indexes.

</details>

<details>
<summary>Installing on other agents</summary>

Whichever installer you use, take **all** capstone skills: `core`
carries the shared rules every other command reads, so a partial
install fails at the first command that needs it. `--all` and
`--skill '*'` do that; so does accepting the default.

**GitHub Copilot**, via the GitHub CLI:

```bash
gh skill install GentBajko/capstone --all --agent github-copilot
```

`gh skill` also installs to Claude, Cursor, Gemini, Antigravity and
others — swap `--agent`, or drop the flag to be asked. Copilot CLI's
own marketplace format works too:

```bash
copilot plugin marketplace add GentBajko/capstone
copilot plugin install capstone@capstone-marketplace
```

**The skills CLI**, covering 70+ agents:

```bash
npx skills add GentBajko/capstone
```

**Gemini CLI**: `gemini extensions install https://github.com/GentBajko/capstone`

**Antigravity**: `agy plugin install https://github.com/GentBajko/capstone`

**OpenCode**, in `opencode.json`:

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
matches a capstone skill (generate, sync, doctor, review,
mockup, logic, uiux, architecture, code-prefs,
stack, build, groom, plan, implement, feature, start, help),
invoke capstone:<that skill> with the remaining arguments.

ARGUMENTS: $ARGUMENTS
```

</details>

<details>
<summary>CI and rough edges</summary>

Copy `templates/capstone-sync-check.yml` into `.github/workflows/`,
add an `ANTHROPIC_API_KEY` secret, and every PR fails when the
reference is stale.

The zero-token help trick is Claude Code only. The PowerShell twins
are syntax-checked in CI but never executed there, and Windows
field-testing is thin: that is the softest spot in the project. Budget an afternoon for the `logic` interview on a real app;
the depth is the point. Retrieval is grep over eight markdown files,
plenty at this scale and unproven on giant monorepos.

</details>

MIT. Issues and PRs welcome.
