# uiux - how the UI looks and how the UX behaves

**Reads:** config → `uiux-interview.md` (resume) →
`docs/capstone/mockup/` (the brief and screens) →
`docs/capstone/logic/` (states, unhappy paths) → the existing
`uiux/` outputs when re-entering → `../uiux-craft.md` (the method,
in full) → `../uiux-inventory.md` (the completion test, in full,
before the first question) → in extraction mode: the conventions and
architecture chapters, then the frontend token, component, and route
sources.

Sits between `logic` and `architecture`: turns the mockup's screens
and the logic's rules into a committed frontend design (direction,
design system, one design chapter per screen) that `stack` honors and
`build` implements. Docs only, never code. Like `standards`, the
output is normative but records only decisions the user has confirmed.

## Method

`../uiux-craft.md` is the method, in full and for every surface:
§1-3 the posture, modes, and dials; §4 the visual world and the
direction session's five steps; §5 the direction contract; §6 the
craft rules; §7 the refuse list and rulings; §8 the pre-flight; §9 the
extraction pass. No installed skill substitutes for it, so the same
project designs the same way on any machine and a resume elsewhere
reaches the same questions.

`../uiux-inventory.md` is the completion test beside it, read in full
before the first question: §3's system items, §4's screen items, and
§5's gate. The method decides how well this stage designs; the
inventory decides when it is allowed to stop. Its items generate
questions rather than being read out, and what does not apply is
confirmed in one batch per its §2.

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

State: `docs/capstone/uiux-interview.md` (standard resumable format
and lifecycle per core.md: numbered `### Q<n>` entries with question,
answer as given, and normalized decision, plus an `## Open threads`
ledger). Seed the ledger once from `../uiux-inventory.md`, the way
`architecture` seeds its own from `../interview.md`: a checkbox line
per system item (`- [ ] S1 Faces`), then one per screen in the
mockup's order (`- [ ] screen 03-invoice`), whose box closes when
that screen has swept §4's eleven items. Direction sits above both as
its own box. Maintain it with appends and toggles, never whole-file
rewrites; a box closes when the item is answered, cited, or recorded
inapplicable, and an item the user declines to settle stays open here
with its reason. Resume = read the file, never re-ask. An artifact
argument (brand book, Figma export, reference screenshots) seeds the
interview per core-authoring.md's Artifact seeding rule.

Prerequisite: either `docs/capstone/mockup/` is formalized and on disk
(greenfield: the screens are this
stage's unit of work), or the repo has frontend code (brownfield:
Extraction mode below). Neither → say so, point at `mockup` (or
`start`), and stop.

If `mockup/README.md` records no visual surface
(`cli`/`api`/`none` only), there is nothing to design: write
`uiux-interview.md` with `status: formalized` and `skipped: no-ui`
in its frontmatter, append the changelog entry (key
`uiux/skipped@<stamp>`, recording the surfaces that made it moot)
and hand back; inside `start` the pipeline continues.
`docs/capstone/logic/` is read when present; absent or partial,
proceed and record in the interview file that unhappy-path styling
leans on the mockup's `## States` sections only - which are an
inventory, so a state the mockup marked `rule: logic` has no trigger
yet: style it and record that its condition is unsettled, never invent
one to fill the gap.

## Extraction mode (brownfield)

With no mockup but existing frontend code, this stage documents the
incumbent design as observed fact instead of interviewing a new one.
`../uiux-craft.md` §9 is the method: its read order (tokens and
theme, the component language and the states each primitive actually
implements, routes and their observed modes, each surface's
composition), and its rule that what you cannot find is itself a
finding. Read the conventions and architecture chapters first, then
those frontend sources of visual truth.
Confirm only the surface inventory with the user (which routes are the
screens), then write `uiux/` as observed: `01-direction.md` records
the incumbent world as found (no contract blocks are invented for
it), `02-system.md` the observed tokens and components with
`file:line` cites, `03-experience.md` the interaction patterns the
code actually implements (what confirms, what undoes, what retries,
what a slow request renders, what is remembered between visits), and
`screens/NN-<route>.md` per confirmed surface.
Every file carries `paths_covered` (the frontend globs it was read
from) so `map` refreshes it as the code moves. Voice: descriptive;
this mode records what is, never what should be; the changelog key is
`uiux/all@<stamp>` (no interview to number). The greenfield
interview phases below do not run.

**Invoked by `map`** (its design-coverage steps):
run the extraction above, scoped to the surfaces no design chapter
claims, with these differences: the files are written directly as
descriptive observations (hard rule 1; no confirmation gate), the
surface inventory is confirmed with the user only when the run is
interactive, no `uiux-interview.md` is created (nothing was asked),
and the invoking protocol's changelog entry records the files instead
of a `uiux/` key. `01-direction.md` is written only when the
extraction can actually observe a direction: tokens and a component
language that hold across surfaces. Where it cannot, the file records
that the incumbent has no consistent visual system, with the
divergences as evidence, and no contract blocks are invented.

A later standalone `uiux` run confirms or corrects those drafts and
records the decisions as usual: that is what turns an extracted
description into the committed design the rest of the pipeline reads.

## Phase B - the design read (the seeds)

Derive before asking; never re-ask what the docs answer:

- The surface inventory: every mockup screen, grouped by mode:
  Operate (app screens), Persuade (landing/marketing), Read
  (docs/content), Experience (showcase). The mode belongs to the
  surface, not the product: a tool's landing page is still Persuade.
- Audience, purpose, positioning, and constraints from
  `mockup/README.md`.
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
2b. The asset question, asked here and never skipped: "Will you supply
   the logo as SVG, or should this stage attempt one?" Say plainly
   that most harnesses cannot draw, so an attempt yields a shaped
   placeholder rather than an identity, and it stands only until you
   replace it. The answer fills the `Source` column of `02-system.md`'s
   `## Assets` table for every logo row. **Never generate a mark
   before this answer exists.** An unanswered asset row stays
   `awaited`, which stops `build` with the list; a placeholder nobody
   asked for ships silently and is discovered in production.
3. The use scene: who uses this, where, under what ambient light;
   and let the answer force light, dark, or both. Never a category
   default.
4. The UX posture: "when the user is mid-task and something goes
   wrong, should the product get out of the way, or stop them and
   make them confirm?" The answer sets the default for confirmations,
   undo, destructive actions, and how loudly errors interrupt.

## Phase C - direction, system, experience, screens

Two generation rules run together, and whichever list is longer picks
the next question: **"if I had to lay out every screen right now, what
visual decision would I have to invent?"** and **"if I had to make
this product feel right to use, what interaction decision would I have
to invent?"** The first drives Direction, System, and Screens; the
second drives Experience. A stage that only ever asks the first
produces a good-looking product nobody can operate.

- **Direction** (the visual world): run uiux-craft §4's direction
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
- **Experience** (how it behaves): the decisions no wireframe shows
  and no business rule settles, asked once and applied everywhere.
  Navigation model and how the user knows where they are. Feedback:
  what is optimistic, what waits, and what the wait looks like past
  roughly a second. Destructive actions: confirm, undo, or both, per
  the posture seed. Error recovery: what the product does with the
  user's work when a step fails, and whether it retries silently.
  Progressive disclosure: what is visible by default versus behind a
  step. Input burden: what is remembered, defaulted, or asked again.
  Keyboard, pointer, and touch expectations, and the accessibility
  floor (`logic`'s rules say what must be true; this says what the
  user is put through to satisfy them). Each answer is a rule
  `screens/` then applies rather than re-decides.
- **Screens**: for each mockup screen, resolve what the wireframe
  underdetermines: composition and focal moment, the styled meaning
  of every state (the mockup's `## States` inventory crossed with the
  logic scenarios' unhappy paths, which is where a `rule: logic` state
  gets its trigger), motion moments, copy register - the mockup's
  labels are working copy this stage ratifies or replaces. Ask only
  where the docs and the committed world don't already decide it.

Drill until concrete. The user may stop at any time; jump to Phase D
and record remaining vagueness honestly.

**The exit test.** The two generation rules above still order the
questions; `../uiux-inventory.md` decides when there are none left.
Phase C is over when every one of its §3 system items and, per screen,
every one of its §4 screen items is answered, cited to an earlier
answer, or recorded inapplicable with its reason - not when nothing
further comes to mind. Sweep per that file's §2: generate, eliminate
what the mockup and the earlier answers already settle, and put the
items that do not apply into **one** confirmation rather than one
question each. A correction inside that batch turns an empty back into
a real question. Close each ledger box as its item lands.

## Phase D' - the preview

Run once the direction is committed and the §3 system items are
answered, before the gate. Skip it when either is still open; say so
in one line rather than previewing a design that is half decided.

Write one self-contained HTML file to
`docs/capstone/uiux/preview.html`: the flagship surface's first
viewport rendered from the committed tokens, plus a style tile showing
the palette, the type scale, the buttons in every hierarchy, one form
field through its validation states, and the loading and empty
vocabularies. No external requests and no CDN; fonts are a system
stack with the chosen faces named in an HTML comment. It renders
decisions already recorded. A value the interview has not settled goes
back to Phase C as a question rather than into this file.

Where the harness can publish an artifact, publish it and hand the
user the link. Where it cannot, say the file's path in one line.
Either way the user steers before the gate: each correction is
recorded as a `### Q<n>` entry like any other answer, and the file is
rewritten from the corrected tokens. Regenerate it whenever a system
item changes after it was first written, so the gate never presents a
picture of a superseded palette.

`preview.html` is working state: gitignored, carrying no frontmatter,
and skipped by the schema pass. `02-system.md` stays the design of
record, and the preview is regenerated from it.

## Phase D - the gate

Set `status: awaiting-formalization`; present the summary: the read
and mode map, the committed direction (world, the flagship surface's
first viewport, signature interaction), dials, tokens, the per-screen
notes, and what is still vague. The user formalizes or amends; do not
generate until they do.

## Phase E - the design docs

On formalization, first run uiux-craft §8's design-time pre-flight
(every mode, delegated or not); fix failures before writing. Then
write `docs/capstone/uiux/` (chapterized markdown, no HTML,
standard frontmatter stamps, with every confirmed decision and its
rationale written directly into the owning file; anything invented is
marked "assumed" inline):

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
  pick with its reasoning; `## Implementation constraints`:
  uiux-craft §8's build-time checklist copied in, plus any
  project-specific additions; and last, `## Assets`.
  `## Assets` is a table, columns
  `Asset | File | Source | Status`, one row per file the brand needs:
  logo mark, logo wordmark, logo mono, logo on dark, favicon source,
  `og.png` source, app icon source, email header, and one row per
  empty-state illustration a screen calls for. `File` is the path
  under `docs/capstone/uiux/assets/`; `Source` is `supplied`,
  `generated` or `placeholder`, from the Phase B asset seed; `Status`
  is `present` when the file is on disk and `awaited` when it is not.
  A row is never dropped for being unfulfilled: `awaited` is the fact
  `build` stops on.
- `03-experience.md`: the Phase C Experience answers as rules the
  screens apply rather than re-decide: navigation model and
  orientation; feedback thresholds (what is optimistic, what waits,
  what a wait longer than ~1s shows); destructive-action policy
  (confirm, undo, or both); error recovery and what happens to the
  user's work; progressive-disclosure defaults; input burden (what is
  remembered, defaulted, never re-asked); keyboard, pointer, and touch
  expectations; the accessibility floor. `build` reads this beside
  `02-system.md`; `review`'s frontend
  side judges the shipped UX against it, the same way it judges the
  shipped UI against the system chapter. It closes with
  `## Not in play`.
- `screens/<NN>-<screen>.md`: one per mockup screen, same number and
  slug as its mockup file (the subfolder exists so numbering can
  mirror `mockup/` exactly). Frontmatter names the mockup file, the
  scenario(s), and the logic file(s). Sections:
  `## Mode & job`; `## Composition` (wireframe → designed layout:
  hierarchy, grid, focal moment; the flagship's first viewport is a
  thesis, not a header); `## States` (every mockup state and every
  logic unhappy path surfacing here, the two reconciled rather than
  concatenated where both describe one state, each with its styled
  treatment:
  empty states teach, loading is skeletal, errors name the problem
  and the recovery); `## Motion` (each moment and what it
  communicates); `## Copy` (register, key labels, tone rules); and
  last, `## Not in play`. Where a
  screen needs an interaction `03-experience.md` already rules on,
  cite the rule instead of restating it; a screen that contradicts it
  is a question for the user, not a local exception.
- `README.md`: the folder's index, like the mockup's: a table design
  chapter → mockup screen → logic scenarios, with every
  "assumed" item collected for the user to review.

The closing section of `02-system.md`, `03-experience.md` and every
screen file holds the inventory items that file had nothing to decide,
one line each with its reason ("S17 reduced motion: nothing on any
surface animates"). The rule is `../uiux-inventory.md` §5's, worded
the way `logic`'s scenarios record their own ruled-out dimensions, and
it is there for the same reason: a later reader can tell "no motion
here" from "nobody asked". An item the user declined to settle is an
open question rather than an inapplicable one, and is named as open.

Brand assets live in `docs/capstone/uiux/assets/`. **The SVGs are
committed** - they are the design of record for the mark, and a
frontend cannot be built from a file that lives on one machine.
Raster exports, screenshots and mood boards under that folder are
local working state and are ignored, along with `preview.html`.
`build` moves the SVGs into the scaffolded tree and rasterizes the
favicon, app icon and `og.png` from them.

Only after every file is on disk, append the changelog entry per
core.md's ledger (key `uiux/all@Q<n>`, `<n>` the highest `### Q<n>`
in `uiux-interview.md`), recording the committed direction, the
alternates and canon declined, the dial and token decisions, the
per-screen coverage, and what the gate left vague. Add the Companion
docs row for `uiux/`; then set `status: formalized` (per core.md's
Interview lifecycle).

**Handoff:** (when running inside the `start` pipeline, it continues
automatically) next is `architecture`: its inputs are unchanged
(mockup and logic). `stack` honors `02-system.md`'s committed picks;
`build` implements `screens/` and enforces the Implementation
constraints, which carry uiux-craft §8's build-time checklist.
