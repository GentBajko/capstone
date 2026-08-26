# Code craft - TDD + YAGNI for every line this plugin writes

Read by `protocols/plan.md`, `protocols/build.md`, and
`protocols/implement.md`, the stages that write implementation plans
and source code. Adapted from the ponytail skill. Precedence: the
project's `code-prefs.md` records the user's own decisions and wins
wherever the two conflict; this file governs everything code-prefs
leaves open. Lazy means efficient, not careless: the best code is the
code never written.

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
- Mark deliberate ceilings with a `ponytail:` comment naming the
  ceiling and upgrade path
  (`# ponytail: global lock, per-account locks if throughput matters`).
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
accessibility basics; typing per `code-prefs.md` (annotations, enums,
Protocols are how minimal code is written, never bloat to cut);
anything the spec or the user explicitly requires: the user insisting
on the full version ends the argument.
