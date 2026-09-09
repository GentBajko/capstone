# Design a new product: start, mockup, and logic

Use `/capstone:start` when you want the whole product defined before implementation:

```text
/capstone:start
```

The stages are `mockup` → `logic` → `uiux` → `architecture` → `standards` → `stack` → readback → `build`. Readback is an internal pass, not a separately invocable command. On entry, choose inline or subagents for this run. Each stage retains its own decision gate, and the chain announces completed stages before continuing. Say stop to pause; a later start reopens the first incomplete stage after a fresh execution-choice question.

If code exists but you have not already chosen mapping or started a pipeline, start asks once whether you meant a new-product interview or map. It records this in the project-only `pipeline` setting. Do not use bare `capstone` as an ambiguous shortcut when you specifically want an existing-code map.

## Mockup: define the product and its surfaces

```text
/capstone:mockup product-brief.md
```

An optional artifact seeds answers for confirmation. Otherwise the three seed questions ask what the product is and why it exists, who it serves and their current alternative, and what success means a year after launch. Later questions follow from the answers rather than a fixed questionnaire.

Mockup records purpose, audience, commercial model, journeys, screens or other interaction surfaces, constraints, and non-goals. It identifies behaviors the product must decide, while leaving the rules themselves to logic. It can decide prices and allowances; logic decides when balances are reserved, debited, refunded, or expired. That division prevents a wireframe from accidentally settling an unexamined business rule.

At the gate, review the summary and unresolved items. After formalization it writes `mockup/README.md` and `mockup/NN-screen.md`. Each screen has Layout, Elements, and States. The layout is an ASCII wireframe plus containment structure, not a screenshot or HTML prototype. Elements identify actions and destinations; States inventory what appears and name triggers without inventing their thresholds. `rule: logic` marks a trigger or behavior that still needs the logic stage.

The README contains the final brief plus Screens, Journeys, and Scenarios for logic tables. Every `rule: logic` marker must have one owning scenario. Screen assumptions are marked inline and in `assumed:` frontmatter and collected in the README; they must not look like confirmed choices.

`surfaces` records any combination of `web`, `mobile`, `cli`, `api`, and `none`. For API/CLI products, the numbered “screens” describe commands, endpoints, or message flows using interaction transcripts. A product with only nonvisual surfaces skips the UI design stage with `skipped: no-ui`; the rest of the pipeline continues.

## Logic: define the behavior precisely

```text
/capstone:logic
```

Logic takes the scenario inventory from the formalized mockup and confirms it in priority order. If there is no usable inventory, it asks for one. It finishes one scenario before the next, recording every answer immediately in `logic-interview.md`.

For an invitation feature, a scenario might cover who may invite, which addresses are accepted, when invitations expire, what a repeated invitation does, and what happens when the invitation is accepted concurrently with revocation. Those are sample concerns; your recorded answers determine the rules.

Each scenario is checked against 16 dimensions: authority; eligibility/preconditions; input; computation; money; limits; time; sequencing/concurrency; lifecycle; failure/recovery; termination; visibility/disclosure; notification; effects on others; records/audit; invariants. Eligibility, concurrency, disclosure, and invariants apply to every scenario. Invariants are evaluated last against the other answers.

The scenario file contains Trigger & preconditions, Steps, Branches, Unhappy paths, State transitions, Invariants, Outcomes & side effects, and Dimensions not in play. A ruled-out dimension has a reason. An unanswered dimension remains open; it is not recategorized as irrelevant to satisfy a completion checklist.

The user confirms each scenario, which is written immediately to `logic/NN-scenario.md` with its own ledger entry. The interview remains `interviewing` until all scenarios are `written` or `dropped`; it does not use the overall `awaiting-formalization` state. A deliberate drop has a recorded reason and ledger key. Stopping halfway retains the written scenarios and the pending list.

## Existing code and extraction

A standalone logic run can offer extraction when there is existing code and a reference but no mockup. It inventories externally triggerable behavior—routes, handlers, actions, jobs, queue consumers, commands, webhooks—and drafts rules with source citations. User confirmation/correction makes the standalone result normative. Extraction files have `paths_covered` so later map runs can refresh observed behavior.

When map invokes extraction, it writes descriptive files without a per-scenario approval gate and without creating `logic-interview.md`. Its map ledger entry covers those files. Existing interview-derived rules are not replaced by that extraction.

## Questions another person must answer

When you cannot answer a material question, the 6.4.1 protocol can offer a questionnaire. It asks who can answer and whether there is a deadline or needed context, then writes `questionnaires/YYYY-MM-DD-recipient.md`. Questions already waiting on the same recipient can share a document.

The sections are Purpose, Context, How to answer, Questions, and Anything else?. This is a file for you to send, not an automatic message to another person. The owning stage records the item as open and can formalize with that gap visible. When answers arrive, resume the owning stage and update its final output. The questionnaire remains in Git as the record of the request.

## What survives a restart

Unfinished stages resume from local interview files. Completed stages are recognized from complete final outputs and matching ledger entries; a fresh clone does not need completed interview bodies to continue to a later stage. If a completed stage's output is lost and the local interview is also unavailable, Capstone must report the lost decision record rather than invent it. See [lifecycle](03-files-and-lifecycle.md) and [recovery](11-review-repair-and-retro.md).

Sources: [start](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/start.md), [mockup](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/mockup.md), [logic](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/logic.md), [logic dimensions](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/logic-craft.md), [questionnaires](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/core.md#questionnaires-what-the-user-cannot-answer-alone).
