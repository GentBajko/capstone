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

Read the reference (`05-dependencies.md`, `01-architecture.md`,
`04-data-flow.md`, `07-operations.md`), `docs/capstone/logic/`,
`docs/capstone/standards.md`, and `docs/capstone/uiux/02-system.md`
when it exists. The capability list is **derived** from what those
documents already record, one row per thing they name:

- every row of `05-dependencies.md`'s **External services**;
- every channel in `01-architecture.md`'s **Communication**;
- every store, cache and queue named in `04-data-flow.md`'s **State**
  and **Side-effect boundaries**;
- every process and every environment variable in `07-operations.md`;
- every `logic/` scenario whose steps reach outside the process:
  payment, email, file, search, export, geocoding, PDF, scheduling;
- every commitment `uiux/02-system.md` records - design system and
  component kit, faces, icon family - carried in as **decided**.
  Research within them; never silently re-open them;
- every capability `standards.md` already pins, likewise carried in as
  decided rather than re-asked;
- anything the architecture interview left open.

Present the derived list with **its source per row**
(`04-data-flow.md` State → session store) and let the user add or
strike rows. A design that names something unusual - a license server,
a hardware key, a court-filing gateway - reaches the list because a
document named it, rather than because the model thought of it.

Then read this completeness prompt against the confirmed list, once,
and ask only about what it exposes as missing: database, cache, auth,
payments, email and notifications, file storage, background jobs,
search, UI framework and component kit, state management, testing
stack, hosting and deploy target, CI, monitoring. It checks the
derivation; it never sources it. An entry that appears here and in no
document is a question about the design, not a pick to research.

Seed the ledger with the confirmed list.

## Phase B - research and pick, one capability at a time

0. **Climb the ladder first** (`../code-craft.md`), to find the
   recommendation rather than to remove the question. Does the
   capability need to exist at all (rung 1)? Does the standard library
   cover it (rung 3)? A native platform feature (rung 4)? A dependency
   already picked for another capability (rung 5)? Record the rung
   that answers it. That answer becomes the option step 3 presents
   first and recommends, with the rung named. It ends nothing: every
   capability on the list still reaches the user as options. This is
   the last stage that can decide a capability never becomes a
   dependency, which is exactly why the user decides it rather than
   the model. Where they choose against the rung, core.md's Pushback
   rule caps you at two rounds; record the rung and their answer
   either way.
1. **Research current options**: web search when the harness has it:
   OSS packages, hosted services, paidware. Check maintenance activity,
   license, and real pricing. Without web access, use model knowledge
   and flag every fact that may be stale.
2. **Filter** by `standards.md`'s vetting bar (license policy,
   maturity, buy-vs-build posture) and the architecture's constraints
   (language, hosting decisions, quality targets).
3. **Present 2-4 options, recommended first, plus one more: write it
   ourselves.** That last option appears in every list, priced
   honestly - roughly how much code it is, what the project then owns
   forever, and which of the alternatives' costs it avoids. Each
   option carries what it is, pros, cons, license, pricing (for
   anything paid), and a one-line fit rationale tied to this project's
   docs. When a ladder rung answered the capability in step 0, the
   option that rung points at - writing it, the standard library, the
   dependency already picked - goes first and is named as the
   recommendation with its rung; the researched alternatives are still
   shown, with what they buy over it. Expertise governs the form
   (level 1: recommend and confirm in plain words; level 5: the
   comparison table). The user picks.
4. **Record the pick** as a `§Q` decision, together with the rung that
   ranked the options and whether the pick followed it; flip the
   ledger box.

## Phase C - gate and output

Set `status: awaiting-formalization`; present the summary table
(capability → decision → one-line why). On formalization, write or
update `05-dependencies.md` as the complete capability matrix: every
pick with version floor, license and pricing notes; every
no-dependency decision with the ladder rung that recommended it and the
options the user turned down for it; and every open or deferred
capability with its trigger. Write each decision's
rationale inline; append the changelog entry
per core.md's ledger: key `stack/all@Q<n>`; record the capability
→ pick table with version floors, licenses and pricing, what each pick
replaced in the architecture stage's draft, and the capabilities still
open. Update the index; then set `status: formalized`. On a repo with no
code the chapter carries `mode: prescriptive`; on a repo that already
has code, write the picks into the existing descriptive chapter as
decision facts ("picked but not yet installed") without flipping its
mode. Either way `map`'s refresh protocol preserves unimplemented picks
from this chapter: the research never vanishes because the code hasn't
caught up.

## refresh - re-vet the recorded picks

`stack refresh` re-researches only the picks `05-dependencies.md`
already records (maintenance activity, license changes, pricing,
newer majors), presents the deltas (unchanged picks in one line
each), and records re-confirmations or changes as new `§Q` entries,
updating the chapter rows touched with the decision and rationale
inline. Changelog key `stack/refresh@Q<n>`.
It never re-opens the capability list or the uiux stage's
commitments; a changed pick flows into `05-dependencies.md` like any
formalization. `map check`'s dependency section is what suggests it.

**Consumers:** `build` reads this chapter as its bill of materials.
