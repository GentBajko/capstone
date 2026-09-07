# UI/UX inventory - the decisions a design is finished when it has made

Read by `protocols/uiux.md`, in full, beside `../uiux-craft.md`.
That file is **the method**: how a direction is derived, what the
dials mean, which defaults are refused, what the pre-flight checks.
This file is the **completion test**: the decisions a shipped frontend
needs somebody to have made, so the stage can tell "this is finished"
from "I stopped thinking of things to ask".

## 1. What this file is, and is not

Not a script, and not a questionnaire to read aloud. The questions
belong to the product: a trading terminal and a wedding planner ask
nothing alike, and asking either one "what is your radius lock?" is
how an interview loses its user. What can be written down is the set
of **decisions that exist in every design**, and those are the same
everywhere. Each item's probe turns it into this product's question.

This exists because `uiux`'s two generation rules - *"if I had to lay
out every screen right now, what visual decision would I have to
invent?"* and *"if I had to make this product feel right to use, what
interaction decision would I have to invent?"* - order the questions
well and stop badly. They measure what you noticed. A disabled state
nobody specified reads exactly like a product whose controls are never
disabled, and the gap surfaces two stages later, as a subagent
inventing a grey.

**The split: the generation rules order, this inventory gates.** They
still pick what to ask next, by whichever list is longer. §5's gate
decides when the stage is finished.

Most items arrive already settled. The mockup fixed the screens and
their states; the direction session fixed the world, the color
strategy and the faces; one system answer settles a dozen screens. An
item settled elsewhere is **cited**, never re-asked.

## 2. The sweep

Two passes, because the two lists close at different times. §3's
system items close once, for the product, over Phase C's System and
Experience work. §4's screen items close per screen. A system item
answered late reopens no screen: the screens read it rather than
copying it.

Run each pass yourself. It is not an interrogation the user sits
through.

1. **Generate.** For each item, write the question its probe raises
   *for this product*, or *for this screen*. Many raise none.
2. **Eliminate.** Delete every question the mockup, the logic
   scenarios, the committed direction, or an earlier answer already
   settles. A screen item ruled on by `02-system.md` or
   `03-experience.md` is cited there rather than re-decided; a screen
   that wants to contradict one is a question for the user, per
   `uiux.md` Phase C.
3. **Batch the empties.** Items that do not apply go into **one**
   confirmation, not one question each: "nothing here works offline,
   no screen is ever permission-denied, and you ship light only -
   right?" A correction turns a batched empty back into a real
   question.
4. **Ask what remains**, one per turn per `uiux.md` Phase C's conduct,
   in the order the generation rules pick rather than this file's
   numbering.
5. **Record.** Answers land where the item says. Items ruled
   inapplicable are recorded per §5.

The system pass runs after the direction is committed: a palette
question asked before the world is chosen is a question about nothing.
The screen pass runs per screen once that screen's composition is
sketched, for the same reason.

## 3. System items

Settled once, for the product. Each carries what it covers, the
**probe** that generates its question, and where the answer **lands**.

### Type

**S1 Faces.** Every family the product ships - display, text, and mono
where it has one - with the reason no face on uiux-craft §4's
anti-default list could do this job.
*Probe:* "name the faces, then say what this one does that the obvious
choice could not. A subject association is not an answer."
*Lands in:* `02-system.md`, typography.

**S2 Scale and measure.** The step ratio and the concrete sizes it
yields, the line height at each, and the prose measure in characters.
*Probe:* "give me the sizes in order, and say how wide a paragraph
gets before it wraps."
*Lands in:* `02-system.md`, typography.

### Color

**S3 Palette per theme.** Every ground, raised surface, border,
primary text and secondary text value, once per theme the product
ships. A theme with no listed values is a theme nobody designed.
*Probe:* "give me the values, not the family: ground, raised surface,
border, primary text, secondary text - for each theme this ships."
*Lands in:* `02-system.md`, color.

**S4 The locked accent.** The one accent, its value, what it is
allowed to mark, and where it is forbidden.
*Probe:* "one color marks the thing the user should touch. Which is
it, and what is it never allowed to appear on?"
*Lands in:* `02-system.md`, color.

**S5 Semantic state colors.** Error, warning, success and info, plus
the marks for selected, hover, focus and disabled: standardized once
and used identically on every surface.
*Probe:* "what color is an error, and is that the same color as a
destructive button, or deliberately not?"
*Lands in:* `02-system.md`, color.

**S6 Contrast floors.** The ratios this project holds itself to and
the pairs that were actually measured: body, placeholder, large text,
and non-text controls, on every shipped theme.
*Probe:* "which pair in this palette sits closest to the floor, and
what did it measure?"
*Lands in:* `02-system.md`, color; the check that enforces it is
uiux-craft §8's.

**S7 Theme parity.** With more than one theme: what stays identical
across them (hierarchy, the accent's job, the floors) and what is
allowed to differ (elevation, image treatment, the accent's value).
*Probe:* "what may look different in the other theme, and what has to
be the same decision wearing different values?"
*Lands in:* `02-system.md`, color.

### Shape, space, and depth

**S8 Spacing rhythm.** The base unit, the scale built on it, and the
rule for vertical rhythm around headings and between groups.
*Probe:* "what is the unit, and which four gaps will you actually use?
A layout with eleven different gaps has no rhythm."
*Lands in:* `02-system.md`, spacing and shape.

**S9 Radius lock.** One radius system for the project - sharp, soft,
or pill - or a documented mixed rule and where each half applies.
*Probe:* "sharp, soft, or pill, and what is the exact value on a
button, a card, and an input?"
*Lands in:* `02-system.md`, spacing and shape.

**S10 Border and elevation language.** How this product separates
things: border, divider, space, or shadow; what a shadow means when it
appears, and its offset, blur, and tint.
*Probe:* "two things need separating. What does it, and what has to be
true before anything is allowed a shadow?"
*Lands in:* `02-system.md`, spacing and shape.

**S11 Density.** The `VISUAL_DENSITY` dial made concrete: control
heights, row heights, the padding inside a card, and whether the
product ships more than one density.
*Probe:* "how tall is a table row and how tall is a button, and does
the power user get a tighter setting?"
*Lands in:* `02-system.md`, spacing and shape.

### Layout

**S12 Breakpoints and the layout at each.** The breakpoint values,
and per breakpoint what the frame does: navigation, column count, and
which asymmetric compositions collapse to a single column.
*Probe:* "name the widths, then describe the frame at each: where does
navigation live at the narrowest one?"
*Lands in:* `02-system.md`, spacing and shape. Each screen's own
collapse is P10.

### Marks and pictures

**S13 Icon family and stroke weight.** One family from a real library,
one stroke weight, one optical size, and what happens the day the
family has no icon the product needs.
*Probe:* "which library, at what stroke, and what do you do when it
has nothing for the thing you are labelling?"
*Lands in:* `02-system.md`, iconography.

**S14 Imagery and illustration policy.** Whether the product carries
photography, illustration, both, or neither; where those images come
from; the treatment applied to them; and what an image slot shows
before it has an image.
*Probe:* "where do the pictures come from, and what does the surface
look like on the day there are none?"
*Lands in:* `02-system.md`, imagery.

**S15 The asset set.** Every file the brand needs in order to exist as
a product: logo mark, wordmark, mono and on-dark variants, favicon
source, `og.png` source, app-icon source, email header, and one
illustration per empty state a screen calls for. Per file: supplied by
the user, generated here, or a placeholder awaiting one.
*Probe:* "which of these do you already have as SVG, and which should
this stage attempt, knowing a generated mark is a placeholder until
you replace it?"
*Lands in:* `02-system.md`'s `## Assets` table, one row per file.

### Motion

**S16 Motion language.** The authored moment, the durations and
easing curves the product actually uses, and what a transition is
allowed to communicate.
*Probe:* "give me the numbers - how long, on what curve - and name the
one moment worth animating."
*Lands in:* `02-system.md`, motion.

**S17 Reduced motion.** What each moving thing becomes under
`prefers-reduced-motion`, loops, parallax, and scroll-driven effects
included.
*Probe:* "with motion off, does this still read, and what does the
authored moment become?"
*Lands in:* `02-system.md`, motion.

### The states every control ships

**S18 Focus treatment.** What a focused control looks like: ring
color, width, offset, and whether keyboard focus differs from pointer
focus. Visible on every interactive element, on every theme.
*Probe:* "tab into this. What did you just see, and would you still
see it on the accent-colored button?"
*Lands in:* `02-system.md`, color and shape; the keyboard path that
reaches it is `03-experience.md`'s.

**S19 Hover and selection treatment.** What hover does, what selection
does, how the two read on the same element at once, and what a touch
device gets in place of hover.
*Probe:* "a selected row under the pointer: what does that look like,
and can you tell it from a merely hovered one?"
*Lands in:* `02-system.md`, color.

**S20 Disabled treatment.** How a disabled control reads, whether it
stays legible, and whether this product prefers disabling a control or
letting the user press it and explaining the refusal.
*Probe:* "the button cannot be pressed yet. Greyed, hidden, or
pressable with an explanation - and how does the user learn why?"
*Lands in:* `02-system.md`, color; the policy behind the choice is
`03-experience.md`'s.

### The vocabularies every screen reuses

**S21 Loading vocabulary.** Skeleton, spinner, progress bar, inline
indicator, optimistic silence: which of them exist, and the rule that
picks one - by wait length, by whether the layout is known in advance,
by whether the user is blocked.
*Probe:* "three waits: 200ms after a click, two seconds for a table,
forty seconds for an upload. What is on screen in each?"
*Lands in:* `02-system.md`; the thresholds themselves are
`03-experience.md`'s feedback rule.

**S22 Empty-state pattern.** The anatomy of an empty state - what it
says, what it offers, whether it carries an illustration - and how
"nothing yet" differs from "nothing matches this filter" and from "you
may not see anything here".
*Probe:* "a brand-new account opens this. What is on the screen, and
what does it get them to do?"
*Lands in:* `02-system.md`; each screen's own copy is P5.

**S23 Error presentation.** Where an error appears relative to where
the user acted - at the field, inline, in a banner, in a toast, in a
dialog - how long it stays, who dismisses it, and whether it names a
recovery.
*Probe:* "the save failed. Where does that sentence appear, how does
it leave, and what does it tell the user to do next?"
*Lands in:* `02-system.md`; what happens to the user's work is
`03-experience.md`'s error-recovery rule.

**S24 Form field anatomy.** Label position, help text, required
marking, placeholder policy, error-text position, and the field's own
states.
*Probe:* "describe one text field carrying a label, a hint, and an
error, and say where each of the three sits."
*Lands in:* `02-system.md`.

**S25 Validation timing.** When a field is checked - on change, on
blur, on submit, after a debounce - when its error clears, and whether
submit is blocked or allowed to fail.
*Probe:* "the email is half-typed and invalid. When exactly does the
product say so, and when does it stop saying so?"
*Lands in:* `03-experience.md`.

**S26 Button hierarchy.** The levels this product ships - primary,
secondary, tertiary, destructive, whatever else - what each looks
like, and how many primaries a surface may carry.
*Probe:* "how many kinds of button are there, and how many primary
ones may share one viewport?"
*Lands in:* `02-system.md`.

### The pick

**S27 Component library or design system.** The library or system by
package name, or the decision to build honestly with native CSS; plus
what the project may restyle in it and what it must not.
*Probe:* "which package, and what are you willing to fight it over -
or is this hand-built, and who keeps it consistent?"
*Lands in:* `02-system.md`, the design-system pick. `stack` honors it;
`build` installs it.

**S3, S4, S8, S9, S18 and S27 apply to every product with a visual
surface**, and so does S26 the moment anything is clickable. S7 is
moot on a single theme, S12 on a fixed-size surface, S17 where nothing
moves; the rest are earned by the product having the thing they
describe.

## 4. Screen items

Settled per screen, in that screen's `screens/<NN>-<screen>.md`. Same
three parts; *Lands in* names a section of that file.

**P1 Composition and focal moment.** The designed layout the wireframe
underdetermines, and the one thing the eye lands on first.
*Probe:* "someone opens this and looks at exactly one thing first.
What is it, and what did you do to the layout to make that true?"
*Lands in:* `## Composition`.

**P2 Hierarchy.** The order the eye takes after the focal moment: what
is second, what is third, and what is deliberately quiet.
*Probe:* "rank everything on this screen. What sits at the bottom of
the list, and why is it on the screen at all?"
*Lands in:* `## Composition`.

**P3 The grid.** Columns, gutters, the content max-width, and what is
allowed to break out of it.
*Probe:* "how many columns, how wide does content get, and what
escapes the grid on purpose?"
*Lands in:* `## Composition`.

**P4 States from the mockup and the scenarios.** Every state this
screen's mockup file lists, crossed with every unhappy path the logic
scenarios touching it produce, the two reconciled rather than
concatenated where both describe one state. Each gets its styled
treatment. A mockup state marked `rule: logic` gets its trigger here,
or the trigger is recorded unsettled rather than invented.
*Probe:* "walk the mockup's states and the scenario's failures
together. Which two are one state under different names, and which
failure has no state at all?"
*Lands in:* `## States`.

**P5 The absence states.** Empty, loading, error, offline,
permission-denied, and partial data - each one where it can actually
happen on this screen, and what the user sees.
*Probe:* "the data is missing, slow, forbidden, half-arrived, or the
network is gone. Which of those can happen here, and what is on the
screen in each case?"
*Lands in:* `## States`, beside P4's. One that cannot happen here is
recorded per §5.

**P6 Motion moments.** Each moment on this screen and what it
communicates: entry, transition between states, feedback on an action,
anything that pulls attention.
*Probe:* "what moves on this screen, and what would the user
misunderstand if it did not?"
*Lands in:* `## Motion`.

**P7 Copy register and key labels.** The register this screen speaks
in, and the actual text of every control, heading, and message that
carries weight. The mockup's labels are working copy: ratify or
replace them here.
*Probe:* "read me the primary button's label, the empty state's
sentence, and the error. Do those three sound like one product?"
*Lands in:* `## Copy`.

**P8 Keyboard path and focus order.** The order focus moves through
this screen, what carries a shortcut, where focus goes when something
opens and where it returns when it closes, and how the user escapes.
*Probe:* "keyboard only. Tab from the top: what is the order, and
where does focus land when the dialog closes?"
*Lands in:* `## Composition`; the product-wide expectation it obeys is
`03-experience.md`'s.

**P9 Touch targets.** The minimum hit area on this screen, the spacing
between adjacent targets, and anything whose touch size is larger than
its drawn size.
*Probe:* "the smallest thing here that a thumb taps: how big is it,
and what sits right next to it?"
*Lands in:* `## Composition`.

**P10 Responsive behaviour.** What this screen does at each of S12's
breakpoints: what reflows, what collapses, what moves, and what is
dropped.
*Probe:* "at the narrowest breakpoint, what is gone from this screen -
and was that a decision or an accident?"
*Lands in:* `## Composition`.

**P11 What the screen does not show.** The information and actions
deliberately kept off it, and where they live instead.
*Probe:* "name something a user will look for here and not find. Where
did you put it, and how do they get there?"
*Lands in:* `## Mode & job`. This is a content decision and belongs in
the body; `## Not in play` is a different record, of inventory items
that had nothing to decide.

**P1, P2, P4, P7 and P8 apply to every screen.** P3 is moot on a
single-column surface, P9 where the product never ships to touch, P10
where the surface has one size; the rest are earned by the screen
having the thing they describe.

## 5. The completeness gate

The stage is finished when **every item in both inventories is
answered, cited, or recorded inapplicable** - not when nothing further
comes to mind.

- **Answered**: the decision is written into the file the item names.
- **Cited**: settled by the mockup, by the committed direction, or by
  an earlier answer, with the owning file saying where. A screen item
  ruled on by `02-system.md` or `03-experience.md` cites the rule
  instead of restating it.
- **Inapplicable**: recorded in the owning file's closing
  `## Not in play` section, one line each with its reason ("P5
  offline: this screen is only reachable inside a session that has
  already loaded"). System items land in `02-system.md`'s section,
  experience items in `03-experience.md`'s, screen items in that
  screen's. Per style.md, absent things are facts: a later reader can
  tell "no motion on this screen" from "nobody asked about motion",
  and `review` will not re-raise it.

An item the user declines to settle is **not** inapplicable. It is an
open question, logged in `uiux-interview.md`'s `## Open threads`
ledger and named in the owning file, so `stack` and `build` see a gap
rather than a silent absence.

Nothing here overrides Phase D's gate: the inventory decides what is
asked, the user still formalizes before any file is written.

**Extraction mode does not run this sweep.** Documenting an incumbent
design records what the code has, and uiux-craft §9 is the method
there: an item the code never decided is an observation ("no disabled
state is implemented"), not a question. The later standalone `uiux`
run that confirms those drafts runs the sweep in full.
