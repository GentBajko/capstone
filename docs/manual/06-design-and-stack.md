# Choose the design, architecture, standards, and stack

These four stages settle different questions. `uiux` decides appearance and interaction; `architecture` decides structure; `standards` records how code must be written; `stack` selects packages and services. Each has a local interview record and a formalization gate. Running one directly stops at its own output; `start` continues through them.

## uiux: appearance, interaction, and design assets

```text
/capstone:uiux brand-guide.md
```

The stage reads the mockup, logic, and any existing design output. Without a formalized mockup or existing frontend code, it points to mockup/start rather than inventing screens. Nonvisual mockup surfaces cause a recorded no-UI skip. Missing logic does not prevent styling the mockup's states, but their unsettled conditions remain visible gaps.

The design interview covers the surface mode map, visual direction, typography, color/themes, spacing, shape, icons, motion, component system, navigation, feedback, recovery, and each screen's composition and states. It asks whether you supply the brand assets or want them generated before producing marks. Image generation and live browser capabilities are optional; their absence is reported rather than silently changing the recorded design.

The durable outputs are `uiux/01-direction.md`, `02-system.md`, `03-experience.md`, `screens/NN-screen.md`, and README. The direction records four contract blocks: THESIS, OWN-WORLD, STORY, and FIRST VIEWPORT. The system records reusable tokens and build constraints. The experience chapter supplies shared interaction rules that screens reference rather than restate. Screen numbers mirror the mockup.

Once direction and system decisions are settled, the stage writes `uiux/preview.html`: one self-contained first viewport plus a style tile, with no network requests or CDN. It uses system fonts and names the chosen fonts in a comment; it is not a faithful installed-font rendering. Correcting the design updates the interview and preview before approval. The Markdown design remains authoritative; the preview is ignored working state.

The Assets table has `Asset`, `File`, `Source`, and `Status`. Source is `supplied`, `generated`, or `placeholder`; Status is `present` or `awaited`. An awaited row remains in the table. Build stops on it rather than quietly inventing a substitute. SVG sources stay in Git; preview/raster/reference material remains local. Build later moves SVGs to the application's public/static directory and updates the table paths.

For an existing frontend with no mockup, uiux can document the incumbent design from tokens, components, routes, and source. It confirms the surface inventory, writes observed files with coverage globs, and does not invent a direction contract where the application has no coherent visual system. Map can invoke the same extraction for missing surfaces. Use review to judge drift from an already committed design.

## architecture: system boundaries and quality targets

```text
/capstone:architecture operating-constraints.md
```

The architecture interview reuses mockup, logic, and existing standards decisions. It walks framing, irreversible structural choices, topic checklists, measurable quality attributes, applicable modules, and a final risk/deferred-decision sweep. The macro-structure question offers 2–3 candidates with tradeoffs. Defaults are explicit proposals; they are not silently accepted architecture.

The gate includes the first walking-skeleton slice, unresolved assumptions, deferred decisions with triggers, and accepted risks. Every planned payload must have answerable fields: a model name without an entity table is not a complete contract.

On approval, architecture writes the index and applicable numbered chapters with `mode: prescriptive`, planned `paths_covered`, and a design-intent banner. Citations point to final decisions and planned paths because implementation does not yet exist. If the design joins existing systems and Quarry is configured, architecture searches and reads their contracts before follow-up questions. It can write user-confirmed `to`/`from` values at generation time.

After code appears, map replaces prescriptive chapters with observations while retaining design rationale and noting divergences. Architecture is not the command for documenting an already implemented repository; use map for that.

## standards: binding rules, distinct from observed conventions

```text
/capstone:standards team-style-guide.md
```

Standards can seed from a style guide or existing agent instructions, then asks what this project requires. It consults relevant existing documents lazily as each domain arises. A codebase habit is not automatically a desired rule: the interview can ask whether an observed practice is intentional.

`standards.md` contains these ordered domains: Typing; Libraries vs reinventing; Paradigm; Error handling; Organization; Documentation; Testing; Tooling; CI gates; Security; Logging and privacy; API conventions; Accessibility; Performance budgets; Versioning and release; Process; Agent rules; followed by Not in play.

Each domain is explicitly answered, accepts the applicable craft rule, or is ruled out with a reason. Questions awaiting another person's answer remain named as open. The output is imperative and carries no `paths_covered`: a code change cannot make a chosen standard disappear. `03-conventions.md`, by contrast, describes what the code currently does.

A standards decision can override Capstone's vendored craft rules when it names the rule being overridden. Merely conflicting with the default without recording an intentional override is not enough. Planning copies applicable rules into task constraints; the implementation review checks the full standards file. Standards may suggest seeding `AGENTS.md`/`CLAUDE.md`, but this command does not rewrite those files itself.

## stack: researched choices for actual capabilities

```text
/capstone:stack preferred-vendors.md
/capstone:stack refresh
```

Stack derives capabilities from the recorded system: services, communication channels, state stores, processes/configuration, logic that calls external systems, existing standards commitments, and UI choices. It presents that list with its document sources for additions or removals. A checklist can reveal a missing design decision; it does not automatically create a need for every common dependency.

For each capability the stage researches maintenance, licensing, pricing, and fit; presents 2–4 alternatives plus writing it yourselves; and records your choice. Existing libraries, platform features, or the standard library may be the recommendation. A no-dependency choice is a real output, with its rationale and rejected alternatives. Without web research, facts that may be stale are marked accordingly.

After the gate, `05-dependencies.md` records the complete capability matrix: version floors, license/pricing notes, reasons, no-dependency choices, and open/deferred capabilities. A greenfield chapter remains prescriptive; an existing-code chapter keeps observed mode and marks new selections as picked but not yet installed. **Stack does not install or upgrade packages.** Build or a feature implementation performs code changes.

`stack refresh` re-vets only already recorded choices: maintenance, license/pricing changes, and newer major versions. It does not reopen the capability inventory or silently change the UI stage's committed component/font/icon choices. Map check recommends re-vetting research older than six months; that recommendation is not an automatic package update.

## Before build: cross-stage readback

Start reads the six completed pre-build stages and checks coverage, misplaced decisions, and contradictions. Coverage and ownership corrections are presented in digests; contradictions are raised with final-file evidence. Answers land in the files that own them. Completed interview bodies are not the routine source for this pass.

Readback records `readback/all@<stamp>`, with the stamp derived from ordered latest stage ledger keys. Unchanged completed stages skip an already recorded pass; amended stage output requires another pass. This ensures build receives the current set of decisions, while still allowing explicitly open items to remain identifiable.

Sources: [uiux](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/uiux.md), [architecture](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/architecture.md), [standards](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/standards.md), [standards inventory](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/standards-inventory.md), [stack](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/stack.md), [readback](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/start.md).
