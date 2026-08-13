#!/usr/bin/env bash
# Prints capstone usage. Single source of truth for the help text.
# Keep in sync with help.ps1 (same text; lint-sync.sh asserts it).
cat <<'EOF'
capstone — codebase architecture reference generator

Usage: /capstone:<command>

  start                Run the greenfield pipeline stage by stage:
                       mockup -> logic -> architecture -> code-prefs -> stack -> build
                       (resumes at the first incomplete stage; also
                        triggers on a bare "capstone" prompt)

  docs                 Generate the reference docs; refresh stale topics on re-runs
  docs rebuild         Force a from-scratch rebuild of everything
  docs <topic>         Regenerate one topic file regardless of staleness
                       (architecture, models, conventions, data-flow,
                        dependencies, testing, operations, glossary)
  check-docs           Read-only trust report: topic staleness + pointer drift
  ask <question>       Answer an architecture question from the docs, with citations
  review               Opt-in judgment: prioritized improvement report -> review.md
  changelog [<ref>]    Architectural change history since <ref> -> changelog.md
  guides [<task>]      How-to guides: run-locally, deploy, project workflows
  onboarding           Guided reading path for new contributors -> onboarding.md
  mockup               Product discovery: seed + adaptive interview -> traceable markdown mockup
  logic                Business-logic interview, scenario by scenario -> docs/capstone/logic/
  architecture         Greenfield: exhaustive architecture interview -> prescriptive reference
  code-prefs           Code-preferences interview -> normative code-prefs.md
  stack                Research libraries/services per capability, you pick -> 05-dependencies.md
  build                Implementation plan (backend then frontend), gate, then working code

  groom <feature>      Feature interview against the existing docs -> features/<NN>-<slug>/spec.md
  plan <feature>       Task-by-task TDD plan from a groomed spec; gated on your approval
  implement <feature>  Execute the approved plan into code, via superpowers when installed
  implementation <desc>
                       Chain groom -> plan -> implement, resuming at the first unfinished stage

  help                 Show this message

Output: DESIGN.md (root index) + docs/capstone/*.md topic files, each stamped
with the commit it was derived at. Re-runs refresh only drifted topics.
Docs are strictly descriptive; only `review` judges.
Every command that writes records itself in docs/capstone/changelog.md.

Config: docs/capstone/capstone.json — expertise 1-5 (vibe coder ...
architect; how technical conversations are, asked once then saved),
docs_dir, index_file, subagent_threshold, docs_in_git, language, pipeline.
EOF
