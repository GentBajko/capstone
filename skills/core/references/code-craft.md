# Code craft - TDD + YAGNI for every line this plugin writes

**The discipline every stage that decides what gets built answers
to.** Read by `protocols/architecture.md` and `protocols/stack.md`,
which decide what will exist, and by `protocols/plan.md`,
`protocols/build.md`, and `protocols/implement.md`, which write it.
`review` judges against it. A layer agreed at design time and a
dependency agreed at stack time are both code the ladder never gets
to stop later, which is why the ladder runs there too, before a line
exists. Adapted from the ponytail skill.

**Precedence, and its one limit.** `standards.md` records the user's
own decisions and outranks this file: capstone's rule everywhere is
that your recorded decisions beat generic best practice. But the
override must be **deliberate and recorded** - a standards rule that
names what it overrides wins, while a silent conflict resolves to the
ladder. "The user might not have wanted this" is not an override.
This file governs everything standards leaves open.

**And the user can always overrule it live.** The ladder is the
position you argue from, never a veto: a rung that says "defer this"
is a recommendation with a reason, and core.md's Pushback rule caps
you at two rounds. If the user wants the layer, the dependency, or the
abstraction built now anyway, build it - and record the rung you
climbed and their answer, so the decision reads as considered rather
than careless.

Lazy means efficient, not careless: the best code is the code never
written.

## The ladder

Stop at the first rung that holds, after understanding the problem,
never instead of it. Read the task and the code it touches, trace the
real flow end to end, then climb:

1. Does this need to exist at all? Speculative need = skip it, say so
   in one line. (YAGNI)
2. Already in this codebase? Reuse the helper, util, type, or pattern
   that already lives here. Look before you write.
3. Stdlib does it? Use it.
4. Native platform feature covers it? `<input type="date">` over a
   picker lib, CSS over JS, a DB constraint over app code.
5. Already-installed dependency solves it? Use it. Never add a new one
   for what a few lines can do.
6. Can it be one line? One line.
7. Only then: the minimum code that works.

Bug fix = root cause, not symptom: before editing, grep every caller
of the function you touch. One guard in the shared function beats one
per caller; patching only the reported path leaves sibling callers
broken.

## Rules

- No unrequested abstractions: no factory for one product, no config
  for a value that never changes, no scaffolding "for later".
- Deletion over addition. Boring over clever. Fewest files possible.
  Shortest working diff wins, in the right place; the smallest change
  in the wrong place is a second bug.
- Two same-size options: take the one correct on edge cases. Less
  code, never a flimsier algorithm.
- Mark deliberate ceilings with a `ceiling:` comment naming the limit
  and the upgrade path
  (`# ceiling: global lock, per-account locks if throughput matters`).
- Comments state only constraints the code can't show. No narration,
  no doc-comments nobody asked for.

## TDD, YAGNI-scoped

Test-first stands (the plan's task cycle: failing test → minimum code
to green → verify → commit). YAGNI bounds the scope, never the order:
test the behavior being built now, with the project's real runner; no
speculative suites for unbuilt features, no fixture cathedrals, no
per-function ceremony. Non-trivial logic (a branch, a loop, a parser,
a money/security path) always leaves its failing-then-green check
behind. Trivial one-liners need no test: YAGNI applies to tests too.

## Interfaces: earned, not speculative

- Consumer-side interfaces/Protocols for typing and test doubles are
  notation, not abstraction: narrow, named by behavior, always fine.
- An adapter/seam is EARNED by one of: (a) a commodity-shaped boundary
  with real swap probability (email, payments, blob storage, SMS, LLM
  providers); (b) portability within ONE guarantee family (Kafka ↔
  Kinesis: durable partitioned log; never across families; Kafka to
  Redis pub/sub is a redesign, not a plug); (c) a second real
  implementation existing today.
- One seam per guarantee family, named by behavior. Domain types cross
  the seam; vendor types (`ConsumerRecord`, shard iterators, partition
  numbers) never leak past it.
- Banned: provider-side god-interfaces (`IDatabase`), abstraction over
  an abstraction (an interface over an ORM: the ORM is the database
  abstraction), DI ceremony for one implementation, config-switchable
  backends for hypothetical vendors. Swappability elsewhere comes from
  locality (one contained module), not ceremony.
- The seam interface is written when the second implementation becomes
  real: it teaches the true shape. An in-memory test fake validates
  the seam's shape, not its semantics.

## Never lazy about

Understanding the problem (read fully, then be lazy); input validation
at trust boundaries; error handling that prevents data loss; security;
accessibility basics; typing per `standards.md` (annotations, enums,
Protocols are how minimal code is written, never bloat to cut);
anything the spec or the user explicitly requires: the user insisting
on the full version ends the argument.

## Git: branches, commits, and their density

The default for every stage that writes code. `standards.md`'s
Process domain records the user's own conventions and wins wherever
the two conflict; a repo whose existing history plainly follows
another convention wins too: match what `git log` shows rather than
imposing this.

### Branch

One branch per unit of work, named `<type>/<slug>`, the slug matching
the feature's own (`feat/invite-links`, not `feat/new-stuff`). Types:
`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`.

Never commit to `main`/`master` without the user's explicit consent:
offer the branch first. Consent given, the rules below still hold.

### Commit message

    <type>(<scope>): <subject>

    <body: why, not what>

    <footer: refs, breaking changes>

- `<type>` from the list above; `<scope>` the module or area touched,
  omitted when the change is genuinely repo-wide.
- `<subject>`: imperative mood, no trailing period, at most 72
  characters, and a real claim: `fix(auth): reject expired refresh
  tokens`, never `fix bug` or `update code`.
- **The body says why.** The diff already says what. Explain the
  reason the change was needed, the approach's trade-off, and anything
  a reader would otherwise have to reconstruct. A commit whose reason
  is obvious from the subject needs no body; most need one.
- Footer carries issue or spec references and `BREAKING CHANGE:` with
  the migration path.
- Never mention the tool that wrote it, and never add co-author or
  "generated by" trailers unless the user asks.

### Density: one reviewable idea per commit

The unit is **one complete idea a reviewer could accept or reject on
its own**, which for a plan-driven run is one task: its test, its
implementation, and the verification that proves it, together.

- **Never a broken commit.** Every commit builds and its tests pass.
  The red step of a TDD cycle is not committed on its own; red and
  green land together.
- **Never mix kinds.** A refactor and a behavior change in one commit
  are two commits. Formatting churn is its own commit, or better, its
  own branch.
- **Never a catch-all.** "wip", "fixes", "address review" say nothing;
  say what was fixed. Squash the wip locally before the branch is
  finished.
- Too big: a reviewer cannot hold it in their head, or the subject
  needs an "and". Too small: a commit that does not build, or that
  only makes sense read beside its neighbor.
- Fixes to review findings amend or follow the commit they correct,
  named for the correction (`fix(auth): narrow the token window
  review flagged`), never a bare "review fixes".

### Order

Commits land in dependency order: what a later commit consumes, an
earlier one defines. A branch reads top to bottom as the argument for
the change, so a reviewer walking it never meets a name before its
definition.
