# stack - research and pick the concrete stack, capability by capability

**Reads:** config → `stack-interview.md` (resume) → the reference
(`05-dependencies.md`, `01-architecture.md`, `04-data-flow.md`,
`07-operations.md`) → `logic/` → `standards.md` →
`../code-craft.md` (the ladder, before any vendor research) →
`uiux/02-system.md` when it exists.

Sits after `standards`, before `build`. Turns the reference's abstract
needs into concrete, user-picked libraries, packages, and paid
services, with real research, options, and trade-offs, not defaults
from memory.

Interview state: `docs/capstone/stack-interview.md` (standard lifecycle
per core.md, ledger seeded with the capability list; an artifact
argument (a preferred-vendor list, an infra doc) seeds it per
core-authoring.md's Artifact seeding rule). Output:
`05-dependencies.md` written or updated (`mode: prescriptive` while no
code exists) with the chosen stack.

## Phase A - derive the capability list

Read the reference (especially `05-dependencies.md`,
`01-architecture.md`, `04-data-flow.md`, `07-operations.md`),
`docs/capstone/logic/`, and `docs/capstone/standards.md`. List every
capability the design needs a concrete pick for (typically: database,
cache, auth, payments, email/notifications, file storage, background
jobs, search, UI framework/component kit, state management, testing
stack, hosting/deploy target, CI, monitoring) plus anything the
architecture interview left open. Confirm the list with the user and
seed the ledger with it. Capabilities `standards.md` already pins are
recorded as derived decisions, not re-asked. So are the commitments
`docs/capstone/uiux/02-system.md` records when it exists; the
design system / component kit, faces, icon family are user decisions:
research within them, never silently re-open them.

## Phase B - research and pick, one capability at a time

0. **Climb the ladder first** (`../code-craft.md`). A capability is
   not automatically a dependency, and this is the last stage that can
   decide it never becomes one. Does it need to exist at all (rung 1)?
   Does the standard library cover it (rung 3)? A native platform
   feature (rung 4)? A dependency already picked for another
   capability (rung 5)? If a rung holds, record the capability as
   **no dependency**, naming the rung that answered it, and move to
   the next one. Never research vendors for a need the platform
   already meets: rung 5 is explicit that you never add a new
   dependency for what a few lines can do. Every pick below is
   therefore a capability that survived the ladder - or one the user
   kept after hearing the rung, which core.md's Pushback rule caps at
   two rounds; record the rung and their answer either way.
1. **Research current options**: web search when the harness has it:
   OSS packages, hosted services, paidware. Check maintenance activity,
   license, and real pricing. Without web access, use model knowledge
   and flag every fact that may be stale.
2. **Filter** by `standards.md`'s vetting bar (license policy,
   maturity, buy-vs-build posture) and the architecture's constraints
   (language, hosting decisions, quality targets).
3. **Present 2-4 options, recommended first**, each with: what it is,
   pros, cons, license, pricing (for anything paid), and a one-line fit
   rationale tied to this project's docs. Expertise governs the form
   (level 1: recommend and confirm in plain words; level 5: the
   comparison table).
4. **Record the pick** as a `§Q` decision; flip the ledger box.

## Phase C - gate and output

Set `status: awaiting-formalization`; present the summary table
(capability → pick → one-line why). On formalization, write or update
`05-dependencies.md` listing every pick with version floor, license,
pricing notes, and `§Q` traceability; append the changelog entry per
core.md's ledger: key `stack/all@Q<n>`; record the capability → pick
table with version floors, licenses and pricing, what each pick replaced
in the architecture stage's draft, and the capabilities still open.
Update the index; then set `status: formalized`. On a repo with no code the chapter carries
`mode: prescriptive`; on a repo that already has code, write the picks
into the existing descriptive chapter as decision facts ("picked
(stack-interview.md §Q4), not yet installed") without flipping its
mode. Either way `map`'s refresh protocol preserves
unimplemented picks from `stack-interview.md`: the research never
vanishes because the code hasn't caught up.

## refresh - re-vet the recorded picks

`stack refresh` re-researches only the picks `05-dependencies.md`
already records (maintenance activity, license changes, pricing,
newer majors), presents the deltas (unchanged picks in one line
each), and records re-confirmations or changes as new `§Q` entries,
updating the chapter rows touched. Changelog key `stack/refresh@Q<n>`.
It never re-opens the capability list or the uiux stage's
commitments; a changed pick flows into `05-dependencies.md` like any
formalization. `map check`'s dependency section is what suggests it.

**Consumers:** `build` reads this chapter as its bill of materials.
