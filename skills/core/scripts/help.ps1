# Prints capstone usage. Keep in sync with help.sh (same text; lint-sync.ps1 asserts it).
Write-Output @'
capstone - codebase architecture reference generator

Usage: /capstone:<command>

  start                Run the greenfield pipeline stage by stage:
                       mockup -> logic -> design -> architecture -> code-prefs -> stack -> build
                       (resumes at the first incomplete stage; also
                        triggers on a bare "capstone" prompt)

  generate             Build the reference docs from scratch; `rebuild` forces,
                       a topic name regenerates one chapter
                       (architecture, models, conventions, data-flow,
                        dependencies, testing, operations, glossary)
  sync                 Refresh the stamped files that drifted; extract the
                       logic/ scenarios the business-logic map is missing
  sync check           Read-only trust report: staleness, pointer drift,
                       absorption drift, logic coverage, stack re-vetting
  doctor               Verify and repair the docs area: torn writes, index
                       drift, voided approvals, absorption gaps
  review [be|fe]       Opt-in judgment -> review.md; no arg does both sides,
                       backend (architecture) and frontend (UI vs your design docs)
  mockup               Product discovery: seed + adaptive interview -> traceable markdown mockup
  logic                Business-logic interview, scenario by scenario -> docs/capstone/logic/
  design               Frontend design from the mockup + logic -> docs/capstone/design/
                       (uses the impeccable/design-taste skills when installed)
  architecture         Greenfield: exhaustive architecture interview -> prescriptive reference
  code-prefs           Code-preferences interview -> normative code-prefs.md
  stack                Research libraries/services per capability, you pick -> 05-dependencies.md
  stack refresh        Re-vet the recorded picks: maintenance, license, pricing deltas
  build                Implementation plan (backend then frontend), gate, then working code

  groom <feature>      Feature interview against the existing docs -> features/<NN>-<slug>/spec.md
  plan <feature>       Task-by-task TDD plan from a groomed spec; gated on your approval
  implement <feature>  Execute the approved plan into code, in subagents or inline (you pick)
  implementation <desc>
                       Chain groom -> plan -> implement, resuming at the first unfinished stage

  help                 Show this message

Output: everything lands in docs/capstone/ - 00-index.md, the numbered
topic chapters, and the logic/ scenario map. Chapters carry the commit
they were derived at; the index carries none, so there is one copy of
freshness and `sync` refreshes only what drifted.
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
'@
