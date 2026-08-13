#!/usr/bin/env bash
# Prints capstone usage. Single source of truth for the help text.
# Keep in sync with help.ps1 (same text; lint-sync.sh asserts it).
cat <<'EOF'
capstone — codebase architecture reference generator

Usage: /capstone:<command>

  start                Run the greenfield pipeline stage by stage:
                       mockup -> logic -> design -> architecture -> code-prefs -> stack -> build
                       (resumes at the first incomplete stage; also
                        triggers on a bare "capstone" prompt)

  generate             Build the reference docs from scratch; `rebuild` forces,
                       a topic name regenerates one chapter
                       (architecture, models, conventions, data-flow,
                        dependencies, testing, operations, glossary)
  sync                 Refresh only the stamped files whose covered paths changed
  sync check           Read-only trust report: staleness, pointer drift,
                       absorption drift, stack re-vetting
  doctor               Verify and repair the docs area: torn writes, index
                       drift, voided approvals, absorption gaps
  ask <question>       Answer an architecture question from the docs, with citations
  be-review            Opt-in judgment: architecture/backend findings -> be-review.md
  fe-review            Opt-in judgment: UI improvements vs your own design docs -> fe-review.md
  changelog [<ref>]    Architectural change history since <ref> -> changelog.md
  guides [<task>]      How-to guides: run-locally, deploy, project workflows
  onboarding           Guided reading path for new contributors -> onboarding.md
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
  implement <feature>  Execute the approved plan into code, via superpowers when installed
  implementation <desc>
                       Chain groom -> plan -> implement, resuming at the first unfinished stage

  help                 Show this message

Output: DESIGN.md (root index) + docs/capstone/*.md topic files, each stamped
with the commit it was derived at. `sync` refreshes only what drifted.
Docs are strictly descriptive; only be-review and fe-review judge.
Every command that writes records itself in docs/capstone/changelog.md.

Interview commands accept an optional artifact argument (a PRD, notes,
screenshots) that pre-fills answers for your confirmation.

Config: docs/capstone/capstone.json — expertise 1-5 (vibe coder ...
architect; how technical conversations are, asked once then saved),
docs_dir, index_file, subagent_threshold, docs_in_git, language,
pipeline, workspaces.
EOF
