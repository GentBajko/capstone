---
name: start
description: Use when the user says just "capstone" with nothing else, or asks to start or continue the capstone pipeline - runs the greenfield chain one stage at a time, detecting completed stages and resuming at the first incomplete one. Always asks subagents or inline before each new or resumed run.
---

# Capstone: start

Pipeline: `mockup -> logic -> uiux -> architecture -> standards -> stack -> build`.

From this skill's base directory, read `../core/references/core.md`
(this command routes rather than writes, so `core-authoring.md` is not
needed), then execute
`../core/references/protocols/start.md`
exactly.

Always ask subagents or inline at the start of each run, including
resumes. Wait for the explicit choice and carry it through the whole
pipeline, including research, readback and build.
