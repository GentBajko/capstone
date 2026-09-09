# Capstone user manual

Capstone is a collection of coding-agent skills. It can document an existing repository, guide a new product through design and implementation, or take one feature through specification, planning, code, and documentation updates. The agent reads the source and writes the documents; Capstone is not a background indexing service.

This manual describes **6.4.1**, from source commit `4210f6cab09dc5c3b742147d8714795b026e1cd9`. The remote default branch was still **6.4.0** as of 9 September 2026, so unpinned installs may omit newer behavior described here. The 6.4.1 tag exists; it is not a GitHub Release entry. See [version details and less obvious behaviors](12-version-and-edge-cases.md).

Commands prefixed `/capstone:` are instructions to your coding agent, not shell executables. Bash, Git, installer, and `quarry` examples are terminal commands. Product names, repository names, feature identifiers, paths, and payloads in examples are illustrative; only explicitly labeled script output is literal.

## Choose a starting point

| What you need | Start here |
| --- | --- |
| Understand code that already exists | [Install](01-install-and-invoke.md), then [map the repository](02-map-and-refresh.md) |
| Find out what generated files mean | [Files, schemas, and their lifecycle](03-files-and-lifecycle.md) |
| Make one change to an existing product | [Feature workflow](04-feature-workflow.md) |
| Design a product before code exists | [Discovery and business logic](05-new-product-discovery.md), then [design decisions](06-design-and-stack.md) and [build](07-build.md) |
| Change defaults or use a monorepo | [Configuration](08-configuration.md) |
| Plan changes that affect other repositories | [Interfaces and Quarry](09-interfaces-and-quarry.md) |
| Check whether docs can be trusted or add CI | [Checks and CI](10-checks-and-ci.md) |
| Review code, repair docs, or learn from a session | [Review, doctor, and retro](11-review-repair-and-retro.md) |
| Diagnose an unusual result or upgrade | [Version and edge cases](12-version-and-edge-cases.md) |

## Every user command

| Command | Practical example | Result |
| --- | --- | --- |
| `map` | `/capstone:map` | Existing-code reference; refreshes on later runs |
| `doctor` | `/capstone:doctor fix` | Consistency report; approved repairs |
| `review` | `/capstone:review frontend` | Findings in `review.md` |
| `retro` | `/capstone:retro` | Evidence-backed instruction proposals; approved standards edits |
| `start` | `/capstone:start` | New-product chain, resuming its first incomplete stage |
| `mockup` | `/capstone:mockup product-brief.md` | Product brief and screen or surface descriptions |
| `logic` | `/capstone:logic` | Scenario-by-scenario rules |
| `uiux` | `/capstone:uiux brand-guide.md` | Visual direction, system, experience, screens |
| `architecture` | `/capstone:architecture constraints.md` | Prescriptive architecture reference |
| `standards` | `/capstone:standards team-style-guide.md` | Binding coding rules |
| `stack` | `/capstone:stack refresh` | Researched dependency decisions or re-vetting |
| `build` | `/capstone:build` | Whole-product implementation plan, then code after approval |
| `feature` | `/capstone:feature add CSV export` | `groom` → `plan` → `implement` |
| `groom` | `/capstone:groom add CSV export` | Feature specification |
| `plan` | `/capstone:plan 2026-09-09-csv-export` | Task plan with verification and an approval gate |
| `implement` | `/capstone:implement 2026-09-09-csv-export` | Executes an approved feature plan |
| `help` | `/capstone:help` | Installed command usage |

`core` is an installed support skill containing shared rules, schemas, and scripts. Install it with the other skills; it is not another workflow stage. A direct invocation of `core` displays help.

The source protocols define expected agent behavior. They do not make the model deterministic or guarantee that every source fact, implementation, or review is correct. Use the cited code and the supplied verification steps to assess results.

Sources: [6.4.1 manifest](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/.claude-plugin/plugin.json), [dispatcher](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/dispatcher.md), [literal help implementation](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/help.sh).
