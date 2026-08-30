# UI/UX craft - the frontend method and the always-on floor

Read by `protocols/uiux.md` and `protocols/review.md`.
**This file is the method**, for every surface and every mode: no
installed skill substitutes for it, so the same project designs the
same way on any machine. Sections 1-6 carry the method, §7 the refuse
list and the rulings, §8 the pre-flight both the design-time and
build-time passes run, §9 the extraction pass for documenting an
incumbent design.

Every ban here binds the shipped interface (its copy, composition, and
code), never capstone's own documentation prose.

**Attribution.** This file is a distillation, condensed and modified,
of two skills capstone does not bundle or invoke:

- `impeccable` by Paul Bakaus, Apache License 2.0
  (<https://github.com/pbakaus/impeccable>). Modified: its flows are
  condensed into the prose method below, its mode taxonomy and colour
  strategy kept, its procedural choreography rewritten to run inside
  capstone's own interview.
- `design-taste-frontend` ("Taste") by Leonxlnx, MIT License,
  Copyright (c) 2026 Leonxlnx
  (<https://github.com/Leonxlnx/taste-skill>). Modified: its dials,
  layout discipline, and pre-flight are folded into §3, §6, and §8.

Where the two disagreed, §7 records the ruling capstone took. Neither
project endorses this distillation, and neither is required for any
capstone command to run.

## 1. Posture

Design as a director with a point of view, not a generator of safe
defaults. Go all out: no hedging, no timid middle options invented to
avoid deciding. The deliverable is complete: every screen, every
state, nothing left as an exercise. **The brief wins**: pinned
aesthetics, materials, fonts, and palettes are honored even against a
warning in this file; redirecting a clear brief toward your own taste
is failure. Verify in bounded passes, never open-ended polish loops.

## 2. Modes

The mode names what the visitor's success looks like on this surface,
chosen per surface, never per product:

- **Persuade**: the visitor decides and acts; design is the product.
  Landing, marketing, pricing.
- **Operate**: the visitor completes a task. App UI, dashboards,
  settings, tools. Scanability, consistency, and native expectations
  outrank expression; brand lives in precise details. The failure mode
  is not flatness but strangeness without purpose; the bar is earned
  familiarity, and the tool should disappear into the task.
- **Read**: the visitor understands something. Docs, guides, help.
  Structure for comprehension, then make staying worth it.
- **Experience**: the visitor is inside the work. Portfolios,
  galleries. The artifact leads from the first viewport.

A tool's landing page is still Persuade; a fashion house's docs are
still Read.

## 3. The design read and the dials

Before any design decision, declare in one line: "Reading this as:
<surface kind> for <audience>, with a <vibe> language, leaning toward
<design system or aesthetic family>." The audience picks the
aesthetic, not your taste; regulated, accessibility-first, and
trust-first contexts override aesthetic preference outright.

Then set three dials, reasoned from the read, never silently baseline:
`DESIGN_VARIANCE` (1 = perfect symmetry, 10 = asymmetric composition),
`MOTION_INTENSITY` (1 = static, 10 = choreographed),
`VISUAL_DENSITY` (1 = art gallery, 10 = cockpit).

| Read signals | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| minimalist / calm / editorial / Linear-style | 5-6 | 3-4 | 2-3 |
| premium consumer / luxury / brand | 7-8 | 5-7 | 3-4 |
| playful / experimental / agency | 9-10 | 8-10 | 3-4 |
| marketing surface, no stated vibe | 7-9 | 6-8 | 3-5 |
| trust-first / public-sector / regulated | 3-4 | 2-3 | 4-5 |
| product app screens (Operate) | 3-5 | 2-4 | 4-7 |

Asymmetric layouts above 768px always collapse to strict single column
below it; the collapse is declared per screen, never assumed.

## 4. The visual world

The anti-convergence method, run before any token is picked:

1. Name in one sentence each: the product's unique mechanism, the
   audience's real scene, its cultural home, and what the flagship
   surface must prove.
2. Name the category rut (the look this category always ships) and
   its predictable opposite. Keep both off the candidate list. A brief
   that paints its own picture (a name, a metaphor) adds its literal
   reading to the rut: spend at most one candidate on it.
3. From the audience's cultural world, list candidate visual worlds
   the audience knows by heart: objects, places, rituals, and just as
   much its graphic traditions: notation, publications, identity
   programs, data graphics, interfaces it reads daily. Each carries
   one line on why it resonates and can carry the mechanism. When most
   candidates share one material family, the derivation stopped at the
   obvious artifact; dig until the list spans at least three families.
4. Commit to ONE direction and present it fully: its world, the
   flagship first viewport, the visitor path, the signature
   interaction, the honest risk. Offer the others as named alternates,
   one line each, never a ranked menu that invites the safest card.
5. Always offer the standing exit: the category standard, played
   straight, as the user's door, never recommended, never used to
   soften the committed direction. If the user takes it, ask which two
   or three products it should sit alongside, make their craft level
   the bar, and execute the convention at full fidelity, without irony.

### Running the direction session

The five steps above are a session, not a checklist to summarise. Run
them in order, one exchange per step, recording each in the interview
file before the next:

1. **The four sentences** (mechanism, scene, cultural home, what the
   flagship must prove) are drafted by you from the mockup and logic
   docs, then confirmed or corrected by the user. Never asked cold:
   the docs already answer them, and asking re-opens settled product
   truth.
2. **The rut and its opposite**, named out loud and struck from the
   list, so the user can see what is being refused rather than
   discovering it missing.
3. **The candidate worlds**, presented together, three material
   families minimum, one line each on why it resonates and how it
   carries the mechanism. Present them as a set; a candidate revealed
   after the user has started choosing is a new session, not a
   refinement.
4. **The commitment**, one direction presented in full: its world, the
   flagship first viewport, the visitor path, the signature
   interaction, and its honest risk. The others follow as named
   alternates, one line each. Never a ranked menu: a menu invites the
   safest card, and the point of committing is to make the bold option
   arguable.
5. **The standing exit**, offered last and every time: the category
   standard, played straight. Never recommended, never used to soften
   the committed direction. Taken, it triggers its own follow-up (which
   two or three products should this sit alongside?), their craft level
   becomes the bar, and the convention is executed at full fidelity
   without irony.

The user may stop at any step; what is recorded stands, and what is
not is recorded as still open. A direction the user has not explicitly
chosen is never treated as chosen.

**Color strategy**, picked before any color: Restrained (neutrals plus
one accent; the floor for Operate and Read), Committed (one saturated
color carries 30-60% of the surface), Full palette (3-4 named roles),
or Drenched (the surface IS the color). Persuade and Experience
surfaces have permission for the bolder strategies; take them when the
brief allows. Color commits at page scale: fields that own regions,
not accents scattered on neutral ground.

**Theme from the use scene, never category default**: write one
sentence (who uses this, where, under what ambient light) and let it
force light, dark, or both.

**Faces**: choose type like objects from the subject's world, in the
mode's register. Operate and Read are well served by workhorse UI
faces; Persuade and Experience want a point of view. These
training-data defaults mean you stopped looking: Inter-as-display,
Fraunces, Instrument Serif, Instrument Sans, Playfair Display,
Cormorant, Lora, Crimson, Newsreader, Syne, Space Grotesk, Space Mono,
IBM Plex, DM Sans, DM Serif, Outfit, Plus Jakarta Sans. Naming one
anyway requires a reason no other face could satisfy, and a subject
association ("books want a serif") is never that reason.

**Calibration self-check**: if someone could guess the aesthetic from
the category alone, or from category-plus-avoidance, the direction
failed; rework until neither answer is obvious. Energy is not the
enemy of trust: "no hype" rules out hype devices, not exuberance.

**Design systems**: when the read names a real system, use the
official package, never a hand-rolled imitation: Fluent
(`@fluentui/react-components`), Material (`@material/web`), Carbon
(`@carbon/react`), Shopify Polaris, Atlaskit, Primer, GOV.UK Frontend,
USWDS, Radix Themes, shadcn/ui (never in default state), Bootstrap,
or Tailwind utilities. One system per project. Aesthetics without an
official package (glassmorphism, bento, brutalism, editorial, dark
tech) are built honestly with native CSS and labeled as such.

## 5. The direction contract

The committed direction is recorded as four blocks; if any block reads
like a mood, the direction is not decided yet:

- **THESIS**: the one idea this frontend owns, and the
  category-default arrangement it refuses.
- **OWN-WORLD**: the palette and component language, specific enough
  to be recognizable with all content removed.
- **STORY**: what the visitor understands, believes, and does.
- **FIRST VIEWPORT**: the flagship surface's exact composition: what
  is where, at what scale, where the primary action sits. A thesis,
  not a header: demonstrate the mechanism immediately. The memory
  test: if someone left after one viewport, what would they describe
  an hour later? A mood means the concept has not committed.

## 6. Craft rules

### Typography

- Display default `text-4xl md:text-6xl` range, tighter tracking;
  body 65-75ch measure. Plan headline scale and asset size together:
  a four-line headline is a font-size error, not a copy-length error.
- Serif is very discouraged as a default; "creative = serif" is the
  most-tested AI tell. It is acceptable only when the brand names one,
  or the world is genuinely editorial/luxury/heritage AND the specific
  serif is arguable for this specific brand.
- Emphasis inside a headline is italic or bold of the SAME family;
  a serif word injected into a sans headline is amateur.
- Italic display words with descenders (`y g j p q`) need
  `leading-[1.1]` minimum plus bottom reserve, or they clip.
- Operate surfaces: one family is often right; fixed rem scale, not
  fluid; step ratio 1.125-1.2; density is a permission, not a flaw.

### Color

- One locked accent, used identically on every screen; saturation
  under 80% unless the brand demands more. No AI-purple defaults, no
  neon gradients unbriefed.
- The premium-consumer default palette (warm cream/beige grounds,
  brass/clay/oxblood accents, espresso near-blacks) is banned as a
  reach; it is what every model ships for artisan briefs. Rotate to a
  different family (cold luxury, forest, black-and-tan, cobalt+cream,
  terracotta+slate, olive+brick, monochrome+one pop) unless the brand
  explicitly names those colors.
- No pure `#000` or `#fff`; off-black and off-white keep depth. On
  colored surfaces, secondary text is tinted from the hue, never gray.
- Contrast floors: 4.5:1 body and placeholder, 3:1 large text, on
  every theme the project ships. Semantic state colors (hover, focus,
  selected, disabled, error, warning, success, info) are standardized
  once for Operate surfaces.

### Shape and depth

- One radius system per project (all-sharp, all-soft, or all-pill),
  or a documented mixed rule applied everywhere. Round buttons on a
  square layout is broken design.
- Shadows carry an offset and a soft blur, tinted toward the
  background hue; a zero-offset colored halo is decoration. Cards only
  where elevation communicates real hierarchy; otherwise group with
  borders, dividers, or space.

### Layout

- Anti-center bias when `DESIGN_VARIANCE > 4`: split, offset, or
  asymmetric compositions before centered ones.
- One layout family appears at most once per page; a marketing page
  with 8 sections uses at least 4 families. Max two consecutive
  image+text zigzag sections.
- No split-header pattern (big headline left, small floating
  explainer right) as a default; stack them.
- Persuade hero discipline: fits the first viewport, headline ≤2
  lines, subtext ≤20 words, at most 4 text elements, top padding
  capped, trust logos below the hero, never inside it.
- More space above a heading than below it; tight groups, generous
  separation. Mobile collapse declared per multi-column layout.

### States

- Every interactive component ships default, hover, focus, active,
  disabled, loading, error; all of them, not half.
- Loading is skeletal and matches the final layout's shape; no
  spinners in content. Empty states teach the interface. Errors are
  inline where the user acts.
- Overlays escape their containers (dialog, popover, portal): an
  absolutely positioned dropdown inside `overflow: hidden` gets
  clipped.

### Motion

- Motivated or absent: every animation answers "what does this
  communicate?" with hierarchy, storytelling, feedback, or state
  transition. "It looked cool" fails.
- One authored moment beats scattered hover effects and identical
  entrances on every section. Marquees: at most one per page.
- Operate: 150-250ms transitions, state-conveying only, no page-load
  choreography: users load into a task.
- Reduced motion is honored always: loops, parallax, and scroll
  effects collapse to static.
- Implementation floor: animate transform and opacity only; no
  `window.addEventListener('scroll')`: scroll work uses
  IntersectionObserver, scroll-driven animations, or a library's
  scroll hooks, isolated in leaf components with cleanup.

### Imagery

- Real images, in priority order: an available image-generation tool;
  real photo sources (seeded placeholders acceptable); else clearly
  labeled placeholder slots handed to the user. Never div-built fake
  screenshots, never hand-rolled decorative SVGs, never emoji or
  unicode glyphs standing in for icons.
- One icon family per project, one stroke weight, from a real library.
- Logo walls are logos only: no category captions under them.

### Copy

- The product's own language; one register per page. Controls name
  their action; errors name the problem and the recovery.
- Zero em-dashes (U+2014) in interface copy: headlines, labels, body,
  quotes, buttons, captions, alt text. Restructure the sentence.
- No AI-tell copy: "Quietly trusted by", poetic section labels ("From
  the field", "On our desks"), micro-meta sentences under headings,
  mock-humble asides, generic step labels ("Step 1/2/3"; the verb is
  the label).
- No Jane Doe, no Acme: names, brands, and avatars read as real and
  locale-appropriate. Numbers are real, labeled mock, or absent;
  never fake-precise spec aesthetics.

## 7. Refuse list and rulings

Category defaults, refused unless the brief's own words earn them
back; recognizing one in your draft means rewriting the element, not
softening it:

- Same-size icon+heading+text card grids as page structure; nested
  cards (always wrong).
- The hero-metric template: big number, small label, supporting
  stats, accent.
- Section numbers (01/02/03) when the sequence carries no information.
- Modal as first thought: exhaust inline and progressive disclosure.
- Gradient text; glass/blur as decoration rather than a specific
  effect; thick colored side-borders on cards and callouts; hard
  offset shadows outside a genuinely neobrutalist world.
- Monospace as a "technical" costume: mono is for code, data,
  measurement.
- Decorative status dots, scroll cues, version labels and build
  footers on marketing surfaces, locale/time/weather strips.
- Sparklines, progress rings, and soft-shadowed rounded rectangles
  standing in for content.

Four rulings, kept as rulings because the two source skills
disagreed and the reasoning is worth preserving:

- **Eyebrows/kickers above headings: banned outright.** The stricter
  of the two bans wins over a one-per-three-sections ration; no brief
  earns it back.
- **Theme: the use-scene rule wins.** Derived from who/where/under
  what light, never "dual-mode by default", never category default.
  When both themes ship, hierarchy parity and contrast floors hold in
  both.
- **Color: the strategy framework governs** (Restrained / Committed /
  Full / Drenched, Operate floors at Restrained), with the per-project
  locks inside it (one accent, consistency, palette bans).
- **Faces: the union anti-default list in §4 applies**, in every
  mode.

## 8. Pre-flight

### Design-time (the protocol runs this before formalizing the docs)

- Design read declared; dials explicit and reasoned, not baseline.
- Mode recorded per screen; Operate screens floor at Restrained color.
- Theme decision carries its use-scene sentence.
- Direction contract present; no block reads like a mood; the
  alternates and the standing exit were actually offered.
- No banned palette or face default without a recorded justification;
  calibration self-check passed (not guessable from category alone).
- Every mockup screen has a design chapter; every mockup state and
  every logic unhappy path that surfaces on a screen has a styled
  treatment; empty/loading/error covered everywhere they exist.
- Every decision traces to a `§Q` entry or is marked "assumed";
  assumed items are collected in the README.
- Zero em-dashes and no AI-tell phrasing in any proposed interface
  copy; no eyebrow labels in any composition note.

### Build-time (copied into `02-system.md` Implementation constraints)

- Every interactive component implements default, hover, focus,
  active, disabled, loading, error.
- Skeletal loading matching layout shape; empty states teach; errors
  name the problem and the recovery, inline where the user acts.
- Contrast verified 4.5:1 / 3:1 on every shipped theme, buttons and
  form fields included (no white-on-white CTAs, no gray-on-colored
  secondary text).
- One radius system, one icon family and stroke weight, one accent,
  as `02-system.md` locks them.
- Animation on transform/opacity only; no scroll listeners; reduced
  motion collapses every effect; motion isolated in leaf components
  with cleanup.
- Overlays escape their containers.
- Real images per §6 Imagery; no div-fake screenshots, no hand-rolled
  icons, no emoji-as-icons.
- Interface copy: zero em-dashes, controls name their action, no
  AI-tell labels, no placeholder-as-label on inputs, labels above
  inputs, error text below.
- CTAs: one label per intent across the page; no wrapped button
  labels at desktop.
- `prefers-reduced-motion` and keyboard focus honored; focus states
  visible on every interactive element.

## 9. Extraction: documenting an incumbent design

Brownfield, where a frontend already exists and the job is to record
the design it has rather than choose a new one. Descriptive
throughout: this pass reports what is, never what should be, so §1-6's
opinions do not apply to it. §7's refuse list still names the
divergences worth *recording*, but a refuse-list hit found in existing
code is a fact for the review to judge, never a finding here.

Read in this order, and confirm only the surface inventory with the
user (which routes are the screens):

1. **Tokens and theme**: the variable, theme, or config files that
   define colour, type scale, spacing, radius, and motion. Record the
   values as they are, with `file:line`, including the ones that
   contradict each other: two accents in a codebase is the fact.
2. **The component language**: the shared primitives (button, field,
   card, dialog) and, per primitive, which states it actually
   implements. A missing hover or error state is recorded as absent,
   per style.md.
3. **Routes and views**: the surface inventory, each mapped to its
   mode (§2) as observed. A route whose mode is genuinely ambiguous is
   recorded as ambiguous, never forced into one.
4. **The composition of each surface**: layout family, focal moment,
   and the states the code actually renders.

What you cannot find is a finding of its own: no token file means the
values live inline, and that is what gets recorded, with examples. Do
not reconstruct a design system that the code does not have.

Every extracted file carries `paths_covered` (the frontend globs it
was read from) so `map` refreshes it as the code moves. The direction
contract (§5) is **not** invented for an incumbent design: record the
world as found, and leave the contract blocks out rather than
back-filling a thesis nobody chose.
