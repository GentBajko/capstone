# `uiux`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`uiux` decides how the product looks and how it behaves: a design
read, the visual direction, the design system's tokens, the
interaction rules, and one chapter per screen. It writes
`uiux/01-direction.md`, `02-system.md`, `03-experience.md`,
`screens/`, the approved brand SVGs under `uiux/assets/`, the review
copies under `uiux/assets/references/`, and `preview.html`.

The method is vendored into the plugin rather than delegated to an
installed design skill, so the same product is designed the same way
on any machine whatever the user has installed, and a run cannot
silently fall back to a different taste.

## When to reach for it

`/capstone:uiux` after `mockup` is formalized. On a repository that
already has a frontend it runs in extraction mode instead, documenting
the design that exists rather than interviewing for one.

Reach for `review frontend` instead when the design is already
recorded and you want the code judged against it. `uiux` sets the
standard; `review` holds the code to it.

## Prerequisites

A formalized `mockup`, for the screens and their states, and `logic/`
for the unhappy paths each screen has to show. A product whose mockup
recorded no visual surface skips this stage.

## Review artifacts, and the completion test

Before the gate the stage asks whether it should make a first-pass logo
as a standalone SVG and a page mockup for review. It writes the
canonical working copies to `uiux/assets/references/logo.svg` and
`uiux/assets/references/page-mockup.html`, and writes
`uiux/preview.html` as the separate token/style tile. The page mockup
is pure self-contained HTML with the SVG inline, CSS inline, no CDN,
and no build step.

Claude Code publishes the SVG and mockup as artifacts when its artifact
tools are available. GPT publishes the mockup as a Site. Other
harnesses hand back the local HTML path. The files stay in the ignored
reference folder through later phases until they are no longer needed.
The user must explicitly approve the artifacts or request changes
before `uiux` enters its formalization gate and before the pipeline
continues to `architecture`; every requested change is recorded and
regenerated.

The stage finishes when the product has been swept against the
inventory's twenty-seven system items and every screen against its
eleven screen items, each one answered, cited to an earlier answer, or
recorded in the owning file's `## Not in play` section with its
reason, and the user has explicitly approved the logo and page mockup
review. Without that approval the stage remains before the gate.

## Common questions

**This used to be called `design`.** It was renamed to `uiux` when it
grew to cover UX behavior as well as visual design, and gained the
extraction mode for repositories that already have a frontend.

**Which asset files get committed?** The accepted brand SVGs under
`uiux/assets/` are committed, because `build` moves them into the app.
The candidate `logo.svg`, page mockup, raster exports and
`preview.html` under the ignored reference/working paths are retained
until no longer needed and are not final design authority.

**Where can I review the mockup?** Claude Code uses artifacts, GPT uses
Sites, and other harnesses use the pure HTML file in
`uiux/assets/references/page-mockup.html`. The local file is always
written even when a harness publishes a richer presentation.

**`build` stopped on an asset row.** `02-system.md`'s `## Assets`
table marks each file `present` or `awaited`, and `build` stops on an
`awaited` row. A row marked `present` whose file is not actually in
`uiux/assets/` is a `doctor` finding, because it stops `build` later
and further from the cause.

## It's working if

`docs/capstone/uiux/` holds `01-direction.md`, `02-system.md`,
`03-experience.md` and one chapter per screen, every inventory item is
answered or listed under a `## Not in play` heading with its reason,
`02-system.md`'s `## Assets` table matches what is actually in
`uiux/assets/`, the user has explicitly approved the logo and page
mockup, the review copies remain in `uiux/assets/references/`, and
`preview.html` renders the tokens you signed off. The ledger carries
one `uiux/all@Q<n>` entry.
