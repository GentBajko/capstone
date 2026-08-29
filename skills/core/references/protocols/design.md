# design - frontend design from the mockup and logic

**Reads:** config → `design-interview.md` (resume) →
`docs/capstone/mockup/` and `mockup-interview.md` (the brief) →
`docs/capstone/logic/` (states, unhappy paths) → the existing
`design/` outputs when re-entering → `../design-craft.md` (the method,
in full) → in extraction mode: the conventions and architecture
chapters, then the frontend token, component, and route sources.

Sits between `logic` and `architecture`: turns the mockup's screens
and the logic's rules into a committed frontend design (direction,
design system, one design chapter per screen) that `stack` honors and
`build` implements. Docs only, never code. Like `code-prefs`, the
output is normative but records only decisions the user has confirmed.

## Method

`../design-craft.md` is the method, in full and for every surface:
§1-3 the posture, modes, and dials; §4 the visual world and the
direction session's five steps; §5 the direction contract; §6 the
craft rules; §7 the refuse list and rulings; §8 the pre-flight; §9 the
extraction pass. No installed skill substitutes for it, so the same
project designs the same way on any machine and a resume elsewhere
reaches the same questions.

**Capabilities, not method.** Two things the harness may or may not
have change what this stage can *do*, never how it decides: image
generation (the direction's sketches, offered when it exists and
skipped in one line when it does not) and a live browser (screenshots
of an existing frontend in extraction mode). Their absence never
changes a design decision.

Conversation cadence: one question per turn, expertise-calibrated per
core.md (level 1 hears "calm or bold?", never "what
DESIGN_VARIANCE?"). Every decision is appended to the interview file
before the next question.

## Phase A - setup / resume

State: `docs/capstone/design-interview.md` (standard resumable format
and lifecycle per core.md: numbered `### Q<n>` entries with question,
answer as given, and normalized decision, plus an `## Open threads`
ledger seeded once with three areas: direction, system, screens).
Resume = read the file, never re-ask. An artifact argument (brand
book, Figma export, reference screenshots) seeds the interview per
core-authoring.md's Artifact seeding rule.

Prerequisite: either `mockup-interview.md` is `formalized` with
`docs/capstone/mockup/` on disk (greenfield: the screens are this
stage's unit of work), or the repo has frontend code (brownfield:
Extraction mode below). Neither → say so, point at `mockup` (or
`start`), and stop.

If the mockup's `surfaces` frontmatter records no visual surface
(`cli`/`api`/`none` only), there is nothing to design: write
`design-interview.md` with `status: formalized` and `skipped: no-ui`
in its frontmatter, append the changelog entry (key
`design/skipped@<stamp>`, recording the surfaces that made it moot)
and hand back; inside `start` the pipeline continues.
`docs/capstone/logic/` is read when present; absent or partial,
proceed and record in the interview file that unhappy-path styling
leans on the mockup's `## States` sections only.

## Extraction mode (brownfield)

With no mockup but existing frontend code, this stage documents the
incumbent design as observed fact instead of interviewing a new one.
`../design-craft.md` §9 is the method: its read order (tokens and
theme, the component language and the states each primitive actually
implements, routes and their observed modes, each surface's
composition), and its rule that what you cannot find is itself a
finding. Read the conventions and architecture chapters first, then
those frontend sources of visual truth.
Confirm only the surface inventory with the user (which routes are the
screens), then write `design/` as observed: `01-direction.md` records
the incumbent world as found (no contract blocks are invented for
it), `02-system.md` the observed tokens and components with
`file:line` cites, `screens/NN-<route>.md` per confirmed surface.
Every file carries `paths_covered` (the frontend globs it was read
from) so `sync` refreshes it as the code moves. Voice: descriptive;
this mode records what is, never what should be; the changelog key is
`design/all@<stamp>` (no interview to number). The greenfield
interview phases below do not run.

## Phase B - the design read (the seeds)

Derive before asking; never re-ask what the docs answer:

- The surface inventory: every mockup screen, grouped by mode:
  Operate (app screens), Persuade (landing/marketing), Read
  (docs/content), Experience (showcase). The mode belongs to the
  surface, not the product: a tool's landing page is still Persuade.
- Audience, purpose, positioning, and constraints from
  `mockup-interview.md`.
- A proposed one-line design read per surface group ("Reading this
  as: <surface kind> for <audience>, with a <vibe> language, leaning
  toward <system or aesthetic family>") plus proposed dial values
  (`DESIGN_VARIANCE` / `MOTION_INTENSITY` / `VISUAL_DENSITY`), each
  with one line of reasoning.

The seeds (the only predetermined questions):

1. Present the read, the mode map, and the dials for confirmation or
   correction.
2. "What brand material already exists and is binding: name, logo,
   colors, fonts, references you want honored?"
3. The use scene: who uses this, where, under what ambient light;
   and let the answer force light, dark, or both. Never a category
   default.

## Phase C - direction, system, screens

Generation rule for every question after the seeds: **"if I had to
lay out every screen right now, what design decision would I have to
invent?"** The next question is whatever tops that list, routed
through the method source:

- **Direction** (the visual world): run design-craft §4's direction
  session, all five steps in order (the four sentences, the rut struck
  out, the candidate worlds as a set, one commitment presented in full
  with its alternates, and the standing exit offered last), recording
  the candidates, the commitment, the alternates declined, and the
  user's choice. Then §5's contract, the color
  strategy (Restrained / Committed / Full palette / Drenched; Operate
  surfaces floor at Restrained), faces chosen past the anti-default
  list, and the calibration self-check: guessable from the category
  alone means rework before presenting.
- **System**: the tokens `02-system.md` needs: typography, palette
  per shipped theme, the single locked accent, spacing and radius
  locks, icon family, motion language, and the component-library /
  design-system pick (a user decision `stack` will honor).
- **Screens**: for each mockup screen, resolve what the wireframe
  underdetermines: composition and focal moment, the styled meaning
  of every state (the mockup's `## States` crossed with the logic
  scenarios' unhappy paths), motion moments, copy register. Ask only
  where the docs and the committed world don't already decide it.

Drill until concrete. The user may stop at any time; jump to Phase D
and record remaining vagueness honestly.

## Phase D - the gate

Set `status: awaiting-formalization`; present the summary: the read
and mode map, the committed direction (world, the flagship surface's
first viewport, signature interaction), dials, tokens, the per-screen
notes, and what is still vague. The user formalizes or amends; do not
generate until they do.

## Phase E - the design docs

On formalization, first run design-craft §8's design-time pre-flight
(every mode, delegated or not); fix failures before writing. Then
write `docs/capstone/design/` (chapterized markdown, no HTML,
standard frontmatter stamps plus the `§Q` entries each file
implements, anything invented marked "assumed" inline):

- `01-direction.md`: the design read; the mode map (screen → mode
  table); the direction contract in prose: THESIS (the one idea this
  frontend owns and the category default it refuses), OWN-WORLD (the
  palette and component language, recognizable with all content
  removed), STORY (what the visitor understands, believes, does),
  FIRST VIEWPORT (the flagship surface's exact composition); dial
  values with reasoning; the theme decision with its use-scene
  sentence; anti-default commitments (the defaults this project
  explicitly rejects); the alternates and canon declined, one line
  each. A contract block that reads like a mood is not decided;
  return to Phase C rather than writing it.
- `02-system.md`: what `stack` and `build` consume: typography
  (faces with the reason no listed default could satisfy, scale,
  pairing; for Operate: one family is often right, fixed rem scale,
  1.125-1.2 ratio, 65-75ch prose measure); color (strategy, palette
  values per shipped theme, the locked accent, semantic state colors
  for Operate, contrast floors 4.5:1 body / 3:1 large); spacing and
  shape (radius lock, rhythm, more space above a heading than below);
  iconography (one family, one stroke weight); motion (the authored
  moment, 150-250ms Operate transitions, state-conveying only,
  reduced-motion behavior); the component-library / design-system
  pick with its reasoning; and `## Implementation constraints`:
  design-craft §8's build-time checklist copied in, plus any
  project-specific additions.
- `screens/<NN>-<screen>.md`: one per mockup screen, same number and
  slug as its mockup file (the subfolder exists so numbering can
  mirror `mockup/` exactly). Frontmatter names the mockup file, the
  scenario(s), the logic file(s), and the `§Q` entries. Sections:
  `## Mode & job`; `## Composition` (wireframe → designed layout:
  hierarchy, grid, focal moment; the flagship's first viewport is a
  thesis, not a header); `## States` (every mockup state and every
  logic unhappy path surfacing here, each with its styled treatment:
  empty states teach, loading is skeletal, errors name the problem
  and the recovery); `## Motion` (each moment and what it
  communicates); `## Copy` (register, key labels, tone rules).
- `README.md`: the folder's index, like the mockup's: a table design
  chapter → mockup screen → logic scenarios → `§Q`, with every
  "assumed" item collected for the user to review.

Only after every file is on disk, append the changelog entry per
core.md's ledger (key `design/all@Q<n>`, `<n>` the highest `### Q<n>`
in `design-interview.md`), recording the committed direction, the
alternates and canon declined, the dial and token decisions, the
per-screen coverage, and what the gate left vague. Add the Companion
docs row for `design/`; then set `status: formalized` (per core.md's
Interview lifecycle).

**Handoff:** (when running inside the `start` pipeline, it continues
automatically) next is `architecture`: its inputs are unchanged
(mockup and logic). `stack` honors `02-system.md`'s committed picks;
`build` implements `screens/` and enforces the Implementation
constraints, which carry design-craft §8's build-time checklist.
