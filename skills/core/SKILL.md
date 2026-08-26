---
name: core
description: Internal to the capstone suite - carries the shared rules (references/) and scripts every capstone subcommand reads; it exists so npx-skills installs ship them alongside the command skills. Not meant to be invoked directly; when invoked anyway, run references/../scripts/help.sh and output its stdout verbatim.
---

# Capstone: core (internal)

This folder is the capstone suite's shared brain: `references/`
(core rules, protocols, craft files) and `scripts/` (help, config
initializer, lint). Every other capstone skill resolves it as
`../core/` from its own base directory, so install the whole suite;
a lone capstone skill without `core` cannot run.

Invoked directly, print the usage: run `scripts/help.sh` via bash
(or `scripts\help.ps1` via powershell on Windows) from this skill's
base directory and output its stdout verbatim; nothing else.
