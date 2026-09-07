# `uiux`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#the-greenfield-pipeline).

## What it does

`uiux` decides how the product looks and how it behaves: a design
read, the visual direction, the design system's tokens, the
interaction rules, and one chapter per screen. It writes
`uiux/01-direction.md`, `02-system.md`, `03-experience.md`,
`screens/`, the brand SVGs under `uiux/assets/`, and `preview.html`.

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

## The preview, and the completion test

Before the gate the stage writes `uiux/preview.html`: one
self-contained page rendering the committed tokens as the flagship
first viewport plus a style tile, so you steer by looking at the
design rather than by reading hex values. It is regenerated whenever a
token changes and never committed.

The stage finishes when the product has been swept against the
inventory's twenty-seven system items and every screen against its
eleven screen items, each one answered, cited to an earlier answer, or
recorded in the owning file's `## Not in play` section with its
reason.

## Common questions

**This used to be called `design`.** It was renamed to `uiux` when it
grew to cover UX behavior as well as visual design, and gained the
extraction mode for repositories that already have a frontend.

**Which asset files get committed?** The brand SVGs under
`uiux/assets/` are committed, because `build` moves them into the app.
The raster exports beside them and `preview.html` are gitignored and
regenerable.

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
`uiux/assets/`, and `preview.html` renders the tokens you signed off.
The ledger carries one `uiux/all@Q<n>` entry.
