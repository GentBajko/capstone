# Architecture craft - be-review's fallback method

Read by `protocols/be-review.md` when the deep-module skills
(`improve-codebase-architecture`, `codebase-design`) are not
installed; when they are, their own text wins and this file stays
closed except §5's rulings, which bind always. Adapted from
mattpocock/skills (MIT, © Matt Pocock), the deep-module school:
Ousterhout's depth, Feathers' seams, Fowler's smells.

## 1. Vocabulary

Use these terms exactly in findings, never "component," "service,"
"API," or "boundary":

- **Module**: anything with an interface and an implementation;
  scale-agnostic (a function, class, package, or tier-spanning
  slice).
- **Interface**: everything a caller must know to use the module
  correctly: the signature, but also invariants, ordering, error
  modes, configuration, performance character.
- **Depth**: leverage at the interface: how much behaviour a caller
  or test exercises per unit of interface learned. Deep = small
  interface, lots of behaviour. Shallow = interface nearly as complex
  as the implementation.
- **Seam**: the place where behaviour can be altered without editing
  in that place; where a module's interface lives.
- **Adapter**: a concrete thing satisfying an interface at a seam; a
  role, not a substance.
- **Leverage**: what callers get from depth: one implementation
  paying back across N call sites and M tests.
- **Locality**: what maintainers get from depth: change, bugs, and
  verification concentrating in one place.

## 2. Deep vs shallow - the tests that decide

- **The deletion test.** Imagine deleting the module. Complexity
  vanishes → it was a pass-through; flag it. Complexity reappears
  across N callers → it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the
  same seam. Code that must be tested *past* its interface is the
  wrong shape; that is a finding about the module, not the tests.
- Depth is a property of the interface, not the implementation: a
  deep module may be several files and internally composed of small
  swappable parts; they just aren't in the interface. Deep ≠ big
  file; a project's small-files convention and deep modules coexist.

## 3. Dependency categories - how a module tests across its seam

Classify a module's dependencies before judging its testability:

1. **In-process** (pure computation, in-memory state): always
   mergeable and testable directly; no adapter.
2. **Local-substitutable** (a real local stand-in exists: PGLite for
   Postgres, an in-memory filesystem): test with the stand-in; the
   seam stays internal, no port at the interface.
3. **Remote but owned** (your own services over a network): a port
   at the seam; production gets the transport adapter, tests an
   in-memory one; the logic stays in one deep module.
4. **True external** (Stripe, Twilio; not yours): an injected
   port; tests provide a mock adapter.

**Replace, don't layer:** once tests exist at a deepened module's
interface, the old unit tests on its swallowed shallow parts are
waste: their absence is not a coverage gap, their survival is a
finding. Tests assert observable outcomes through the interface and
survive internal refactors; a test that breaks when behaviour didn't
change is testing past the interface.

## 4. Seam discipline

One adapter means a hypothetical seam; two adapters mean a real one:
the same law `code-craft.md`'s "Interfaces: earned, not speculative"
states from the YAGNI side; the two files agree, cite either.
Internal seams (private to an implementation, used by its own tests)
are fine and are not exposed through the interface because tests use
them. A single-adapter port is indirection, not architecture: flag
it.

## 5. The smell baseline

Heuristics, never hard violations; each reads *what it is → the fix
direction*. Two rulings bind in every mode, delegated or not:
**the repo's documented standards and recorded decisions override the
baseline** (where they endorse something the baseline would flag,
suppress the smell), and **skip anything tooling already enforces**.

- **Mysterious Name**: a name that hides what it does → rename; no
  honest name means murky design.
- **Duplicated Code**: the same logic shape in several places →
  extract the shape once.
- **Feature Envy**: a method reaching into another object's data
  more than its own → move it to the data it envies.
- **Data Clumps**: the same fields travelling together → a type
  wanting to be born.
- **Primitive Obsession**: a primitive standing in for a domain
  concept → give the concept its own small type.
- **Repeated Switches**: the same case-cascade on the same type
  recurring → polymorphism or one shared map.
- **Shotgun Surgery**: one logical change forcing scattered edits →
  gather what changes together.
- **Divergent Change**: one module edited for unrelated reasons →
  split by reason for change.
- **Speculative Generality**: abstraction for needs nothing has →
  delete it; inline until a real need shows.
- **Message Chains**: `a.b().c().d()` navigation callers depend on →
  hide the walk behind one method.
- **Middle Man**: a thing that mostly delegates onward → cut it,
  call the target.
- **Refused Bequest**: an implementer ignoring most of what it
  inherits → composition, not inheritance.

## 6. The review method

1. **Scope by heat.** Deepening pays off where change happens: walk
   the git history for hot spots (files and areas that keep coming
   up) and weight attention there. The user naming a direction
   overrides. Scattered change with no hot spot → widen the net.
2. **Walk for friction, not checklists**: where does understanding
   one concept mean bouncing between many small modules; where are
   interfaces nearly as complex as their implementations; where were
   pure functions extracted "for testability" while the real bugs
   hide in how they're called; what leaks across seams; what is
   untestable through its current interface?
3. Apply the deletion test to every suspect; classify dependencies
   (§3) before proposing how a deepened module would be tested.
4. Grade each candidate **Strong / Worth exploring / Speculative**,
   and say what deleting or merging it concentrates. Benefits are
   stated as leverage and locality, never as "cleaner".
5. The project's recorded decisions (the reference, the interviews,
   `code-prefs.md`) are ADR-equivalents: a candidate contradicting
   one is surfaced only when the friction justifies reopening the
   decision, and says so explicitly.
