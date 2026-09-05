#!/usr/bin/env bash
# Prints capstone usage. Single source of truth for the help text.
# Bash only: no PowerShell twin (lint-sync.sh check 8 enforces that).
cat <<'EOF'
capstone - codebase architecture reference generator

Usage: /capstone:<command>

  start                Run the greenfield pipeline stage by stage:
                       mockup -> logic -> uiux -> architecture -> standards -> stack -> build
                       (resumes at the first incomplete stage; also
                        triggers on a bare "capstone" prompt)

  map                  Build the reference docs, or refresh what drifted: no
                       reference yet builds one, an existing one gets only its
                       stale files rewritten, plus the logic/ scenarios and
                       uiux/ surfaces the map is missing
  map rebuild          Force a full rewrite of a reference that looks current
  map <topic>          Rebuild one chapter (architecture, models, conventions,
                        data-flow, dependencies, testing, operations, glossary)
  map check            Read-only trust report: staleness, pointer drift, absorption
                       drift, logic and design coverage, stack re-vetting
  doctor               Verify and repair the docs area: torn writes, index
                       drift, voided approvals, absorption gaps
  review [be|fe]       Opt-in judgment -> review.md; no arg does both sides,
                       backend (architecture) and frontend (UI vs your design docs)
  mockup               Product discovery: seed + adaptive interview -> traceable markdown mockup
  logic                Business-logic interview, scenario by scenario -> docs/capstone/logic/
  uiux                 How the UI looks and the UX behaves, from the mockup + logic
                       -> docs/capstone/uiux/
  architecture         Greenfield: exhaustive architecture interview -> prescriptive reference
  standards            Coding-standards interview -> normative standards.md
  stack                Research libraries/services per capability, you pick -> 05-dependencies.md
  stack refresh        Re-vet the recorded picks: maintenance, license, pricing deltas
  build                Implementation plan (backend then frontend), gate, then working code

  groom <feature>      Feature interview against the existing docs -> features/<date>-<slug>/spec.md
  plan <feature>       Task-by-task TDD plan from a groomed spec; gated on your approval
  implement <feature>  Execute the approved plan into code, in subagents or inline (you pick)
  feature <desc>       Take one feature idea to shipped code: chains groom -> plan ->
                       implement, resuming at the first unfinished stage

  help                 Show this message

Output: everything lands in docs/capstone/ - 00-index.md, the numbered
topic chapters, and the logic/ scenario map. Chapters carry the commit
they were derived at; the index carries none, so there is one copy of
freshness and `map` refreshes only what drifted.
Docs are strictly descriptive; only review judges.
Every command that writes records itself in docs/capstone/changelog.md.
A command that needs the reference and finds none builds it first.

Interview commands accept an optional artifact argument (a PRD, notes,
screenshots) that pre-fills answers for your confirmation.

Config: capstone.json in the agent's global folder (~/.claude; created
at install): expertise 1-5 (vibe coder ... architect; how technical
conversations are, asked once then saved), teaching_mode (true =
narrate and teach while working), docs_dir, index_file,
subagent_threshold, docs_in_git, language. Per-project state and
overrides live in an optional docs/capstone/capstone.json: pipeline,
workspaces, or any global key to override for that repo.
EOF
