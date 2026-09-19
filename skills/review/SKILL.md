---
name: review
description: Use when asked for an opinionated review of the codebase - architecture/backend findings, UI findings against the project's own design docs, or both - severity-ranked with evidence, written to docs/capstone/review.md. Bare "review" does both sides; "review backend" or "review frontend" does one. "review retro [session]" is the third judgment axis - it reads a finished session and proposes edits to standards.md and the project's AGENTS.md/CLAUDE.md instead of judging code. Opt-in judgment; never edits code.
---

# Capstone: review

From this skill's base directory, read `../core/references/core.md`
and `../core/references/core-authoring.md`, then execute
`../core/references/protocols/review.md`
exactly (review is core.md's sole judgment exception). No argument
runs both sides; `backend`/`be` or `frontend`/`fe` runs one.

`retro` is the exception: `review retro [session]` executes
`../core/references/protocols/retro.md`
exactly instead, and review.md is not read. An argument after it
names the session; with none, it reads the session in progress.
