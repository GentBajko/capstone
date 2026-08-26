# code-prefs - code-preferences interview, then a normative standards doc

**Reads:** config → `code-prefs-interview.md` (resume) → lazily, per
domain: `03-conventions.md`; the index plus `01-architecture.md` and
`05-dependencies.md` (or the architecture interview);
`mockup/README.md`, never bulk-read upfront.

Elicits how the user **wants** code written in this project, independent
of what the code currently does. The output is normative (allowed,
like the reviews, to say "do X, never Y", because every
rule is the user's own recorded decision, not the skill's opinion).

Interview state: `docs/capstone/code-prefs-interview.md`, same resumable
format as the other interviews (status frontmatter per core.md's
Interview lifecycle, `### Q<n>` entries appended before the next
question, and an `## Open questions` ledger seeded once with the nine
Phase B domains as checkboxes, maintained by appends and toggles,
never whole-file rewrites). Interview files are never indexed. Output:
`docs/capstone/code-prefs.md`, indexed under Companion docs.

## Phase A - setup / resume

Read the interview file if it exists and resume; never re-ask. An
artifact argument (a style guide, an existing CLAUDE.md) seeds the
interview per core.md's Artifact seeding rule. Then
ground the interview in whatever already exists, each source read
lazily, only when the current question domain touches it, and only if
present:

- The conventions topic (`docs/capstone/03-conventions.md`): ask
  preference questions as confirmations of observed reality ("the code
  currently uses exceptions everywhere: preference or accident?")
  rather than from scratch.
- The architecture reference (index + `01-architecture.md`,
  `05-dependencies.md`) or the `architecture` interview's decisions: the
  chosen stack scopes the library questions; ask about the libraries
  the project actually faces, not generic ones.
- The mockup (`docs/capstone/mockup/README.md`): its scenarios inform
  testing and error-handling preferences (what must never break, what
  the user journey tolerates).

Never bulk-read all of these upfront; pull each in at the domain that
needs it.

## Phase B - the interview

One question per turn; offer concrete options when enumerable; adaptive
follow-ups until each answer is concrete; record the normalized decision
immediately. Walk these domains, skipping any the user rules out:

- **Typing**: strict or loose; escape-hatch policy (`Any`, casts,
  ignores); structural (protocols/interfaces) vs nominal; enums vs raw
  strings; annotation coverage expectations.
- **Libraries vs reinventing**: default posture (buy/adopt vs build);
  preferred libraries per capability (HTTP, validation, ORM, testing,
  state, CLI, ...); the vetting bar (maturity, license, bus factor);
  dependency budget and when hand-rolling is preferred.
- **Paradigm**: OO / functional / procedural mix; immutability stance;
  inheritance policy; dependency-injection style.
- **Error handling**: exceptions vs result types; error taxonomy;
  logging rules; what must never be swallowed.
- **Organization**: package-by-feature vs by-layer; file-size
  discipline; naming conventions; comment and docstring policy.
- **Testing**: TDD or not; fakes vs mocks; coverage philosophy; what
  must always have tests.
- **Tooling**: formatter, linter and strictness, type-checker config.
- **Process**: commit message style; PR conventions (keep light).
- **Agent rules**: anything an AI assistant must always or never do in
  this codebase.

## Phase C - the gate

When the queue is empty (or the user stops), set
`status: awaiting-formalization`, present the decision summary by
domain, and ask the user to formalize. Do not write the output until
they do.

## Phase D - the output

Write `docs/capstone/code-prefs.md`: frontmatter stamps (no
`paths_covered`: preferences don't go stale with code); banner
"User-stated preferences: normative, not a description of current
code."; rules organized by the domains above, each traceable to its
`§Q` entry; imperative voice.

Then append the changelog entry per core.md's ledger: key
`code-prefs/all@Q<n>` from the interview's highest `### Q<n>`; record
the rules decided per domain and the domains the user ruled out. Update
the DESIGN.md index per core.md, set `status: formalized`
in the interview file (only now that the output is on disk, per
core.md's Interview lifecycle), and suggest (never do unasked)
seeding the project's `AGENTS.md`/`CLAUDE.md` from it.

**Consumers:** the `architecture` interview pre-fills its conventions answers
from this file and never re-asks; `be-review` gains a
preference-divergence dimension when this file exists.
