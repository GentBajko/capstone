# standards - how code must be written here

**Reads:** config → `standards-interview.md` (resume) → lazily, per
domain: `03-conventions.md`; the index plus `01-architecture.md` and
`05-dependencies.md` (or the architecture interview);
`mockup/README.md`, never bulk-read upfront.

Elicits how code **must** be written in this project, independent of
what the code currently does. The output is normative (allowed, like
the reviews, to say "do X, never Y", because every rule is the user's
own recorded decision, not the skill's opinion).

**Standards, not conventions.** `03-conventions.md` reports what this
codebase habitually does, violations included, and `map` rewrites it
whenever the code moves. This file records what the user decided it
must do, and nothing regenerates it. Where they disagree, the code is
wrong, not this file: that gap is what `review` reports.

Interview state: `docs/capstone/standards-interview.md`, same resumable
format as the other interviews (status frontmatter per core.md's
Interview lifecycle, `### Q<n>` entries appended before the next
question, and an `## Open questions` ledger seeded once with the nine
Phase B domains as checkboxes, maintained by appends and toggles,
never whole-file rewrites). Interview files are never indexed. Output:
`docs/capstone/standards.md`, indexed under Companion docs.

## Phase A - setup / resume

Read the interview file if it exists and resume; never re-ask. An
artifact argument (a style guide, an existing CLAUDE.md) seeds the
interview per core-authoring.md's Artifact seeding rule. Then
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
- **Libraries vs reinventing**: `../code-craft.md`'s ladder is the
  default posture (stdlib and native platform features before a
  dependency; never a new one for what a few lines can do). Ask what
  the user changes about it: preferred libraries per capability (HTTP,
  validation, ORM, testing, state, CLI, ...), the vetting bar
  (maturity, license, bus factor), the dependency budget, and where
  hand-rolling wins instead.
- **Paradigm**: OO / functional / procedural mix; immutability stance;
  inheritance policy; dependency-injection style.
- **Error handling**: exceptions vs result types; error taxonomy;
  logging rules; what must never be swallowed.
- **Organization**: package-by-feature vs by-layer; file-size
  discipline; naming conventions; comment and docstring policy.
- **Testing**: `../code-craft.md`'s TDD, YAGNI-scoped, is the default
  (failing test → minimum code to green → verify → commit; non-trivial
  logic always leaves its check behind, trivial one-liners need none).
  Ask what the user changes about it: fakes vs mocks, coverage
  philosophy, what must always have tests. Dropping test-first is an
  override, recorded as one.
- **Tooling**: formatter, linter and strictness, type-checker config.
- **Process**: commit message style, branch naming, and commit
  density; PR conventions (keep light). `../code-craft.md`'s Git
  section is the default: ask what the user changes about it, not
  the whole convention from scratch.
- **Agent rules**: anything an AI assistant must always or never do in
  this codebase.

**Overriding the craft file.** `../code-craft.md` governs everything
these domains leave open, and this file outranks it - but only by a
decision that *names what it overrides* (code-craft's Precedence
rule). When an answer contradicts the ladder, the TDD cycle, or the
earned-interfaces rule, record the rung or rule it replaces in the
same `### Q<n>` entry, so a later reader can tell a considered
departure from an accident. An answer that merely conflicts, without
saying so, is not an override: the ladder still stands.

## Phase C - the gate

When the queue is empty (or the user stops), set
`status: awaiting-formalization`, present the decision summary by
domain, and ask the user to formalize. Do not write the output until
they do.

## Phase D - the output

Write `docs/capstone/standards.md`: frontmatter stamps (no
`paths_covered`: standards don't go stale with code, and no refresh
path may regenerate them); banner "Standards the user set: binding,
not a description of current code."; rules organized by the domains
above, each traceable to its `§Q` entry; imperative voice.

Then append the changelog entry per core.md's ledger: key
`standards/all@Q<n>` from the interview's highest `### Q<n>`; record
the rules decided per domain and the domains the user ruled out. Update
the index per core.md, set `status: formalized`
in the interview file (only now that the output is on disk, per
core.md's Interview lifecycle), and suggest (never do unasked)
seeding the project's `AGENTS.md`/`CLAUDE.md` from it.

**Consumers:** the `architecture` interview pre-fills its conventions answers
from this file and never re-asks; `review`'s backend side gains a
standards-divergence dimension when this file exists (the conventions
chapter measured against these rules).
