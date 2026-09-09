---
name: feature
description: Use when the user wants one feature taken from idea to working code - "add a feature", "build X end to end", "take X from idea to shipped" - runs the feature chain groom → plan → implement consecutively, detecting the feature's stage and resuming at the first incomplete one. For the whole-product greenfield pipeline use start; to execute an already-approved plan use implement. Always asks subagents or inline before each new or resumed run.
---

# Capstone: feature

From this skill's base directory, read `../core/references/core.md`
(this command routes rather than writes, so `core-authoring.md` is not
needed), then execute
`../core/references/protocols/feature.md`
exactly.

Always ask subagents or inline at the start of each run, including
resumes. Wait for the explicit choice and carry it through the whole
chain, including planning, review and reference refreshes.
