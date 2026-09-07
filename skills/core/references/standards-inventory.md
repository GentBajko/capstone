# Standards inventory - the domains every standards run sweeps

Read by `protocols/standards.md`. **This file is the method** for
deciding how code must be written here, in full: the same project
yields the same standards coverage on any machine, whoever runs the
interview.

## 1. What this file is, and is not

Not a script to read aloud. Reading ninety questions at a user is the
fastest way to get ninety shrugs. What is written down is the set of
**items** a standard can exist for, and those are the same in every
project. Sweeping the project against them generates the questions
worth asking, and most of them are already answered before anyone is
asked anything.

Three things answer an item without a turn of the interview:

- **An earlier answer.** "Result types everywhere" settles what a
  caller sees, what may be swallowed, and half of the API error body.
  Deduce it, record it, move on.
- **`../code-craft.md`.** Where an item names a default below, the
  question is "what do you change about this", never an open field.
  Accepted unchanged is a real answer and is recorded as one.
- **The existing code.** On a repo with a `03-conventions.md`, an item
  the code already answers becomes a confirmation: "exceptions
  everywhere today - preference or accident?"

**The split: the protocol orders, this sweep gates.** `standards.md`'s
Phase B still picks what to ask next, by whatever the project makes
urgent. §5's gate decides when the interview is finished.

## 2. The sweep, per domain

Run it yourself between questions; it is not an interrogation the user
sits through.

1. **Generate.** For each item in the domain you are on, write the
   question it raises *for this project*. Many raise none.
2. **Eliminate.** Delete every question already settled by an earlier
   answer, by `../code-craft.md`, or by the conventions chapter. Record
   the settled value with its source rather than re-asking it.
3. **Batch the empties.** Items that do not apply go into **one**
   confirmation, not one question each: "no HTTP surface, no browser
   UI, nothing runs on a schedule - so no API conventions, no
   accessibility target, no performance budget for a page. Right?" A
   correction turns a batched empty back into a real question.
4. **Ask what remains**, one per turn, per `standards.md`'s Phase B
   conduct.
5. **Record.** Answers land in the `standards.md` section each item
   names. Items ruled out are recorded per §5.

The sweep runs per domain, as the interview reaches it, not once at the
start: an item's questions are only answerable once the domains before
it have narrowed the ground.

## 3. The domains

`standards.md` carries one `## ` heading per domain, in exactly this
order, and closes with a final section for what was ruled out. The nine
domains the protocol walked before this file existed keep their
relative order; the eight added ones sit where the answers they need
have already been given.

- **Typing** - how much the checker knows, and where it is allowed not
  to know.
- **Libraries vs reinventing** - what earns a dependency here, and what
  the project writes for itself.
- **Paradigm** - the shape of the code: objects, functions, state, and
  how a dependency reaches the thing that needs it.
- **Error handling** - how failure is represented and where it is
  allowed to stop.
- **Organization** - where a file goes, what it may be called, and what
  it may import.
- **Documentation** - the prose the code owes: doc comments, decision
  records, the README.
- **Testing** - what is tested, with what doubles, and what a test is
  allowed to touch.
- **Tooling** - formatter, linter, checker, and the one command a
  contributor runs before pushing.
- **CI gates** - what blocks a merge, what only reports, and who may
  override.
- **Security** - secrets, trust boundaries, authorization, advisories,
  encryption.
- **Logging and privacy** - what is written down about users, in what
  shape, for how long.
- **API conventions** - the promises this project's callers may rely
  on.
- **Accessibility** - the conformance target and what enforces it.
- **Performance budgets** - the numbers that fail a review.
- **Versioning and release** - what a version means here and how one
  ships.
- **Process** - branches, commits, pull requests.
- **Agent rules** - what an AI assistant must always and never do in
  this repo.
- **Not in play** - not a domain. The closing section of
  `standards.md`, listing every item the sweep ruled out, one line
  each with its reason.

## 4. The items

Each item carries what it covers, the **probe** that generates its
question, the `../code-craft.md` rule it **defaults** to when one
exists, and the `standards.md` section its answer lands in.

### Typing

**S1 Strictness.** The checker's setting, and whether existing code is
held to it or grandfathered behind a per-file marker.
*Probe:* "which strictness level is on, and does code written before
today get an exemption?"
*Default:* none; code-craft names typing as something never to be lazy
about and sets no level. *Lands in:* Typing, as the level plus the
grandfather rule.

**S2 Escape hatches.** `Any`, `object`, `as any`, casts, suppression
comments: which exist, where they are allowed, and what one must carry
to survive review.
*Probe:* "when the checker is wrong, what do you write, and what has to
sit next to it?"
*Default:* code-craft's Comments section, which grants a comment its
line only when it says what the code cannot - a suppression's reason
qualifies. *Lands in:* Typing, as the allowed hatch and its required
justification.

**S3 Structural vs nominal.** Protocols and interfaces versus concrete
types at a boundary; whether an identifier gets its own type or travels
as a string.
*Probe:* "does a function take the interface or the class, and is a
user id a distinct type or a string?"
*Default:* code-craft's Interfaces section: consumer-side protocols for
typing and test doubles are notation and always fine, provider-side
god-interfaces are banned. *Lands in:* Typing, as the boundary rule.

**S4 Enumerations.** Closed sets as enums, literal unions, or bare
strings, and where a bare string is still acceptable.
*Probe:* "status is one of four values - what is its type in the
database, in the domain, and on the wire?"
*Default:* code-craft's Never lazy about list names enums as part of
how minimal code is written. *Lands in:* Typing, as the rule plus the
exceptions.

**S5 Annotation coverage.** Which surfaces must be annotated: public
functions, module boundaries, internal helpers, tests.
*Probe:* "which of these may go unannotated - a private helper, a test,
a lambda?"
*Default:* none. *Lands in:* Typing, as the annotated surface list.

**S6 Absence.** How "no value" is spelled: optional types, sentinels,
empty collections, and whether an empty string and a null mean
different things.
*Probe:* "what does a missing value look like in a field, an argument,
and a JSON body, and are those three the same?"
*Default:* none. *Lands in:* Typing, as the absence rule.

### Libraries vs reinventing

**S7 The ladder itself.** Whether code-craft's seven rungs stand as
written, and which rung the project amends.
*Probe:* "stdlib and platform features before a dependency, never a new
one for what a few lines can do - accept, or change which rung?"
*Default:* code-craft's ladder in full. *Lands in:* Libraries vs
reinventing, as accepted or as the named amendment.

**S8 Preferred picks per capability.** HTTP client, validation, ORM or
query builder, testing, state, CLI parsing, dates, serialization: which
library the project already stands behind, so `stack` researches within
the choice rather than reopening it.
*Probe:* "for each capability the design already needs, is there a
library you will use whatever the research says?"
*Default:* none. *Lands in:* Libraries vs reinventing, as the pinned
picks; the versions and pricing land in `05-dependencies.md` at the
`stack` stage.

**S9 The vetting bar.** What a candidate must clear: last release,
maintainer count, open-issue behavior, license list, transitive weight,
supply-chain posture.
*Probe:* "name the thing that disqualifies a package outright, before
anyone argues about its API."
*Default:* none. *Lands in:* Libraries vs reinventing, as the bar
`stack` filters against.

**S10 The budget.** A cap on direct dependencies, or a rule about what
adding one costs, and who approves it.
*Probe:* "who says yes to a new dependency, and what do they need to
see?"
*Default:* code-craft's rung 5, which forbids a new dependency for what
a few lines can do. *Lands in:* Libraries vs reinventing, as the cap
and the approval path.

**S11 Where hand-rolling wins.** The cases where this project writes it
itself even though a library exists: a domain that keeps changing, a
one-function need, a dependency whose licence does not fit.
*Probe:* "name something you would write by hand here that most
projects would install."
*Default:* none; this is the deliberate inverse of the ladder and is
recorded as an override. *Lands in:* Libraries vs reinventing, as the
build-it list.

**S12 Abandonment.** What happens when a dependency stops being
maintained: fork, vendor, replace, or stay put with a pin.
*Probe:* "the library you rely on had its last commit two years ago -
what do you do, and when do you decide?"
*Default:* none. *Lands in:* Libraries vs reinventing, as the
abandonment response.

### Paradigm

**S13 The mix.** Objects, functions, procedures, and which layer uses
which; whether a class with one method is allowed.
*Probe:* "is a request handler a function or a class here, and does the
domain layer answer the same way?"
*Default:* none. *Lands in:* Paradigm, as the per-layer shape.

**S14 Immutability.** Whether values default to immutable, where
mutation is permitted, and how a change is represented when it is not.
*Probe:* "does a function that changes something return a new value or
edit the one it was given?"
*Default:* none. *Lands in:* Paradigm, as the default plus the
permitted mutation sites.

**S15 Inheritance.** Allowed at all, allowed one level, or replaced by
composition; abstract bases versus protocols.
*Probe:* "show me the deepest inheritance chain you would accept in
review."
*Default:* code-craft's ban on abstraction over an abstraction and on
provider-side god-interfaces. *Lands in:* Paradigm, as the inheritance
rule.

**S16 Dependency injection.** How a collaborator reaches the code that
needs it: constructor argument, module import, container, parameter
default; and how a test substitutes one.
*Probe:* "the handler needs a database - where does it come from, and
what does the test pass instead?"
*Default:* code-craft's ban on DI ceremony for one implementation.
*Lands in:* Paradigm, as the injection style.

**S17 Ambient state.** Singletons, module-level mutable values,
thread-locals, globals: which exist, and what may read them.
*Probe:* "what state is reachable from anywhere in the process, and who
is allowed to write it?"
*Default:* none. *Lands in:* Paradigm, as the ambient-state list.

### Error handling

**S18 Mechanism.** Exceptions, result types, error returns, or a split
by layer; and what crosses a public boundary.
*Probe:* "a repository call fails - what does the caller receive, and
what does the HTTP layer receive?"
*Default:* none. *Lands in:* Error handling, as the mechanism per
layer.

**S19 Taxonomy.** The error kinds that exist, who defines them, and how
a low-level failure is translated on its way up.
*Probe:* "name every error type a caller has to distinguish, and where
a driver error becomes one of them."
*Default:* none. *Lands in:* Error handling, as the type list and the
translation points.

**S20 What must never be swallowed.** The catch that logs and
continues, the bare except, the retry that hides a permanent failure.
*Probe:* "which failure, caught and ignored, would you call a bug in
review even if nothing broke?"
*Default:* code-craft's Never lazy about list, which names error
handling that prevents data loss. *Lands in:* Error handling, as the
never-swallow rule.

**S21 What the caller sees.** The split between the message a user or
API client gets and the detail that goes to the log; whether stack
traces or internal identifiers may leave the process.
*Probe:* "an internal error reaches a user - what exactly do they read,
and what do you need in the log to debug it?"
*Default:* none. *Lands in:* Error handling, as the message contract;
the field-level detail lands in Logging and privacy.

**S22 Stopping.** What is allowed to end the process: assertions,
panics, unwraps, `System.exit`; and which of those may appear on a path
a user can reach.
*Probe:* "what is allowed to crash this, and is a bad request one of
those things?"
*Default:* none. *Lands in:* Error handling, as the abort rule.

### Organization

**S23 Layout.** Package by feature or by layer, where shared code
lives, and how a new module earns a top-level folder.
*Probe:* "a new feature arrives - how many folders does it touch, and
which ones are new?"
*Default:* code-craft's fewest-files rule. *Lands in:* Organization, as
the layout rule.

**S24 Size discipline.** Any limit on file length, function length, or
argument count, and whether a limit is enforced or advisory.
*Probe:* "at what size does a file become a review comment, and does
anything enforce that?"
*Default:* none. *Lands in:* Organization, as the limits and their
enforcement.

**S25 Naming.** Case conventions per kind of name, the words the
project reserves, and how a test is named.
*Probe:* "what does a test's name have to tell a reader who never opens
its body?"
*Default:* none. *Lands in:* Organization, as the naming table.

**S26 Visibility and imports.** What is public, what is internal, which
direction imports may run, and whether anything enforces the layering.
*Probe:* "may the domain layer import the web framework, and what stops
it?"
*Default:* none. *Lands in:* Organization, as the import rule plus its
enforcement.

**S27 Comments.** What earns a comment, what is deleted on sight, and
which surfaces owe a docstring.
*Probe:* "code-craft deletes a comment that restates its line and keeps
the one naming a constraint - what do you add to either list?"
*Default:* code-craft's Comments section in full. *Lands in:*
Organization, as accepted or as the named change; the mandatory
docstring surfaces land in Documentation.

**S28 Dead code and TODOs.** Whether commented-out code and `TODO`
markers may be committed, and what a permitted one must carry.
*Probe:* "is a `TODO` in a merged pull request a finding here?"
*Default:* code-craft deletes commented-out code on sight and forbids a
`TODO` standing in for work the current task covers. *Lands in:*
Organization, as accepted or as the named change.

### Documentation

**S29 Doc comments.** Which surfaces must carry one, in what format,
and what it must say beyond the signature.
*Probe:* "which functions owe a docstring, and what does it have to add
that the annotations do not?"
*Default:* code-craft writes docstrings only where `standards.md` asks
for them, on the surface it names, and nowhere else. *Lands in:*
Documentation, as the surface list and the format.

**S30 Decision records.** What size or kind of decision earns an ADR,
where the records live, and whether one is ever revised or only
superseded.
*Probe:* "which of last quarter's decisions should have left a document
behind?"
*Default:* none. *Lands in:* Documentation, as the ADR trigger and
location.

**S31 The README contract.** What the repository README must always
carry, and which changes oblige an update to it.
*Probe:* "what in the README goes stale first, and whose commit is
supposed to fix it?"
*Default:* none. *Lands in:* Documentation, as the README rule.

**S32 The generated reference.** Where `docs/capstone/` sits, that
`map` rewrites it rather than a person, and which files under it are
hand-maintained.
*Probe:* "which documentation is written by hand and which is
regenerated, and how does a reader tell them apart?"
*Default:* none. *Lands in:* Documentation, as the hand-written versus
generated split.

**S33 Examples.** Whether code samples in documentation are executed by
the test suite or left as prose.
*Probe:* "the README's example stops compiling - what catches it?"
*Default:* none. *Lands in:* Documentation, as the example rule.

### Testing

**S34 Test-first.** Whether code-craft's cycle stands: failing test,
minimum code to green, verify, commit.
*Probe:* "test first, or test after the code works - and is that a rule
or a habit?"
*Default:* code-craft's TDD, YAGNI-scoped. Dropping test-first is an
override and is recorded as one. *Lands in:* Testing, as accepted or as
the named override.

**S35 Doubles.** Fakes, mocks, stubs, or the real dependency in a
container; and which of the three a test is allowed to reach for.
*Probe:* "does a test that needs the database get a fake, a container,
or a real one?"
*Default:* code-craft's rule that an in-memory fake validates a seam's
shape rather than its semantics. *Lands in:* Testing, as the doubles
policy.

**S36 What a test may touch.** Network, disk, clock, randomness,
environment: which are allowed, and what replaces the ones that are
not.
*Probe:* "may a unit test read the wall clock or open a socket?"
*Default:* none. *Lands in:* Testing, as the isolation rule.

**S37 What must always be tested.** The paths where an untested change
is refused: money, authorization, parsers, migrations, anything with a
branch.
*Probe:* "name the code you would block a merge over for having no
test."
*Default:* code-craft: non-trivial logic always leaves its check
behind, trivial one-liners need none. *Lands in:* Testing, as the
must-test list.

**S38 Coverage.** A number, a rule about what must be covered, or
neither; and what happens when a change lowers it.
*Probe:* "is there a coverage number, and what does it do when it
drops?"
*Default:* none; code-craft rejects speculative suites and per-function
ceremony, which bounds the scope rather than setting a figure. *Lands
in:* Testing, as the coverage rule.

**S39 Flakes.** What happens to a test that fails intermittently:
quarantine, delete, fix within a window.
*Probe:* "a test fails one run in twenty - what happens to it today,
and what should?"
*Default:* none. *Lands in:* Testing, as the flake response.

### Tooling

**S40 Formatter.** The tool, its configuration, and whether formatting
is ever adjusted by hand.
*Probe:* "which formatter, whose config, and may anyone disagree with
it in a file?"
*Default:* none. *Lands in:* Tooling, as the tool plus its config
location.

**S41 Linter.** The tool, the enabled rule set, how a rule is
suppressed in place, and what a suppression must carry.
*Probe:* "which lint rules are denied rather than warned, and what does
an in-line suppression have to say for itself?"
*Default:* code-craft's Comments section governs the suppression's
justification. *Lands in:* Tooling, as the rule set and the suppression
rule.

**S42 Type checker.** The tool and the settings that differ from its
defaults.
*Probe:* "which checker, and which of its flags did you turn on or off
deliberately?"
*Default:* none; S1 sets the strictness this configures. *Lands in:*
Tooling, as the checker's configuration.

**S43 The one command.** The single command a contributor runs before
pushing, and what it covers.
*Probe:* "what do you type before you push, and does it run everything
CI runs?"
*Default:* none. *Lands in:* Tooling, as the pre-push command.

**S44 Hooks and automation.** Pre-commit hooks, editor-on-save
actions, whether a hook may be skipped, and what notices when one was.
*Probe:* "may someone commit with `--no-verify`, and does anything find
out?"
*Default:* none. *Lands in:* Tooling, as the hook policy.

### CI gates

**S45 What blocks a merge.** The checks whose failure stops the merge
button, named exactly.
*Probe:* "list the checks that must be green, and confirm every other
check is advisory."
*Default:* none. *Lands in:* CI gates, as the blocking list.

**S46 What only reports.** Checks that run and post results without
blocking, and how a persistent one gets promoted or removed.
*Probe:* "which check is red often enough that nobody reads it any
more?"
*Default:* none. *Lands in:* CI gates, as the advisory list.

**S47 Overrides.** Who may merge past a red gate, what they must
record, and whether the override is visible afterwards.
*Probe:* "the gate is red and the fix has to ship tonight - who clicks
it, and where is that written down?"
*Default:* none. *Lands in:* CI gates, as the override rule.

**S48 The matrix.** Which runtimes, versions, and platforms every merge
is tested against, and which are tested on a schedule instead.
*Probe:* "which version combinations must pass per pull request rather
than nightly?"
*Default:* none. *Lands in:* CI gates, as the matrix.

**S49 Pipeline budget.** How long the blocking pipeline may take, and
what moves out of it when it exceeds that.
*Probe:* "how long is too long to wait for a green tick, and what gets
moved to nightly first?"
*Default:* none. *Lands in:* CI gates, as the time budget.

### Security

**S50 Secrets.** Where secrets live, how code reads one, what may never
reach a log, an error message, a fixture, or a document.
*Probe:* "name every place a secret is allowed to exist, and every
place a value from that list may never be printed."
*Default:* capstone's own `redact` config key, whose default list is
`*_SECRET`, `*_TOKEN`, `*_PASSWORD`, `*_KEY`, keeps matching variables
out of the generated reference. *Lands in:* Security, as the storage
rule and the never-print list.

**S51 The validation boundary.** The exact layer where untrusted input
is validated, and what an inner function is allowed to assume.
*Probe:* "point at the line where a request body stops being
untrusted."
*Default:* code-craft's Never lazy about list names input validation at
trust boundaries. *Lands in:* Security, as the boundary and the inner
assumption.

**S52 Authorization placement.** Which layer decides whether an actor
may do a thing, and what makes a missing check visible.
*Probe:* "a new endpoint ships with no permission check - what catches
it before a user does?"
*Default:* none. *Lands in:* Security, as the check's location and its
enforcement.

**S53 Dependency advisories.** The scanner, how often it runs, and the
response time for a critical advisory against a direct dependency.
*Probe:* "a critical advisory lands against something you ship - how
long until it is patched, and who is woken up?"
*Default:* none; S9's vetting bar decides what gets in, this decides
what happens after. *Lands in:* Security, as the scanner plus the
response window.

**S54 Encryption.** What is encrypted at rest, what in transit, which
algorithms and key sizes are acceptable, and how a key is rotated.
*Probe:* "which columns are encrypted, and who can decrypt them?"
*Default:* none. *Lands in:* Security, as the at-rest and in-transit
lists.

**S55 The auth review rule.** Who must review a change touching
authentication, authorization, session handling, or cryptography, and
whether the author may merge it.
*Probe:* "a one-line change to the session cookie - how many people see
it before it ships?"
*Default:* none. *Lands in:* Security, as the review requirement.

### Logging and privacy

**S56 Shape.** Structured records or plain lines, the serialization,
and the fields every entry carries.
*Probe:* "show me one log line - what fields does it always have?"
*Default:* none. *Lands in:* Logging and privacy, as the format and the
standard fields.

**S57 Level policy.** What belongs at each level, what is never logged
at all, and which level pages someone.
*Probe:* "what deserves an error rather than a warning, and what wakes
a human at 03:00?"
*Default:* none. *Lands in:* Logging and privacy, as the level table.

**S58 Correlation.** The identifier that ties one request's lines
together, where it is created, and how it survives a queue or a second
service.
*Probe:* "one user report, one timestamp - how do you find every line
that request produced?"
*Default:* none. *Lands in:* Logging and privacy, as the identifier and
its propagation.

**S59 Personal data.** Which fields count as personal, what is
redacted, hashed, or dropped before writing, and where that happens.
*Probe:* "an email address reaches a log statement - what appears in
the file?"
*Default:* capstone's `redact` list, which covers configuration
variables rather than payload fields, so payload classification is
decided here. *Lands in:* Logging and privacy, as the classified field
list and the redaction point.

**S60 Retention.** How long logs are kept, who may read them, where
they are shipped, and what is deleted on a user's request.
*Probe:* "how long do these lines exist, and who can read them a month
from now?"
*Default:* none. *Lands in:* Logging and privacy, as the retention
window and the access rule.

### API conventions

**S61 Versioning.** Whether the API carries a version, where it sits,
and what a version number covers.
*Probe:* "is the version in the path, a header, or nowhere?"
*Default:* none. *Lands in:* API conventions, as the versioning scheme.

**S62 Deprecation window.** How long a superseded version keeps
answering, how callers are told, and what the last response before
removal looks like.
*Probe:* "you replace an endpoint today - when does the old one stop
answering, and how does its last caller find out?"
*Default:* none. *Lands in:* API conventions, as the window and the
notice.

**S63 Error body.** The fields every error response carries, whether
error codes are stable strings, and how validation failures are
reported per field.
*Probe:* "show me the JSON body of a 422 - every field of it."
*Default:* none; S19's taxonomy is what these codes name. *Lands in:*
API conventions, as the error body shape.

**S64 Pagination.** Cursor or offset, the default size, the maximum,
and what the response carries so a caller can ask for the next page.
*Probe:* "a collection endpoint returns ten thousand rows - what
actually comes back?"
*Default:* none. *Lands in:* API conventions, as the pagination
contract.

**S65 Idempotency.** Which operations may be retried safely, whether an
idempotency key is accepted, and how long a key is honored.
*Probe:* "the client retries a create because the connection dropped -
how many records exist afterwards?"
*Default:* none. *Lands in:* API conventions, as the idempotent
operation list and the key rule.

**S66 Rate limits.** The limits, the headers or fields that signal
them, and what a caller is expected to do on refusal.
*Probe:* "a caller exceeds the limit - what status, what headers, and
what should they do next?"
*Default:* none. *Lands in:* API conventions, as the limit and its
signal.

**S67 The compatibility promise.** What may change in a response
without a version bump: added fields, reordered arrays, widened enums,
loosened requirements.
*Probe:* "which of these breaks a caller: a new field, a removed field,
a field that stopped being required?"
*Default:* none. *Lands in:* API conventions, as the promise; the
payload tables in `09-interfaces.md` are what `quarry check` measures a
change against.

### Accessibility

**S68 The conformance target.** The standard and level this project
holds itself to, and whether it applies to every surface or a named
subset.
*Probe:* "which standard, which level, and does the internal admin
screen count?"
*Default:* code-craft's Never lazy about list names accessibility
basics, without naming a level. *Lands in:* Accessibility, as the
target and its scope.

**S69 The keyboard rule.** Whether every interactive element is
reachable and operable without a pointer, and what focus order and
focus visibility are owed.
*Probe:* "unplug the mouse - is there anything a user can no longer
do?"
*Default:* none. *Lands in:* Accessibility, as the keyboard
requirement.

**S70 The contrast floor.** The minimum contrast ratio for text, for
large text, and for interactive borders and icons.
*Probe:* "what ratio does a disabled button's label have to clear?"
*Default:* none; `uiux/02-system.md`'s palette is what this constrains.
*Lands in:* Accessibility, as the ratio per element class.

**S71 The automated check.** The tool that runs in CI, what it covers,
and what it cannot see.
*Probe:* "which check runs per pull request, and which failures only a
person will ever notice?"
*Default:* none; S45 decides whether it blocks. *Lands in:*
Accessibility, as the tool and its blind spots.

**S72 Exemptions.** Surfaces excluded from the target, the reason, and
who signed each one off.
*Probe:* "name a screen this does not apply to, and say why."
*Default:* none. *Lands in:* Accessibility for the rule, and `Not in
play` for a surface excluded outright.

### Performance budgets

**S73 The numbers.** The budget per surface class: page load, API
response percentile, background job duration, query time, bundle size.
*Probe:* "give me one number per surface class that, exceeded, fails a
review."
*Default:* none. *Lands in:* Performance budgets, as the budget table.

**S74 Measurement.** Where each number is measured, against what data
volume, and on what hardware.
*Probe:* "measured on whose machine, against how many rows?"
*Default:* none; a number without this is unenforceable. *Lands in:*
Performance budgets, as the measurement method per number.

**S75 Regression.** What a change that breaches a budget does: blocks
the merge, opens an issue, or needs a recorded exception.
*Probe:* "a change doubles a query's time and still passes the tests -
what happens?"
*Default:* none. *Lands in:* Performance budgets, as the regression
response.

**S76 Resource ceilings.** Memory, connection pool, concurrency, and
per-request cost limits, and what happens at the ceiling.
*Probe:* "what is the most memory one request may use, and what happens
to request one thousand and one?"
*Default:* code-craft's `ceiling:` marker names a deliberate limit and
its upgrade path in the code. *Lands in:* Performance budgets, as the
ceilings.

### Versioning and release

**S77 The scheme.** Semantic versioning, calendar versioning, or a
build number, and what the number promises a consumer.
*Probe:* "what does the middle number changing tell someone who depends
on this?"
*Default:* none. *Lands in:* Versioning and release, as the scheme.

**S78 What breaking means.** The changes that force a major bump here:
a removed field, a narrowed input, a changed default, a slower
guarantee.
*Probe:* "which of these is breaking - removing a response field,
adding a required request field, changing a default?"
*Default:* none; S67's compatibility promise is the caller-facing half
of the same answer. *Lands in:* Versioning and release, as the breaking
list.

**S79 The branch model.** Trunk-based, release branches, or long-lived
environments, and where a hotfix starts.
*Probe:* "production is broken and `main` has unreleased work - where
does the fix branch from?"
*Default:* code-craft's Git section: one branch per unit of work, named
`<type>/<slug>`. *Lands in:* Versioning and release, as the model;
naming stays in Process.

**S80 Tagging and artifacts.** What is tagged, what a tag builds, where
the artifact is published, and whether a tag is ever moved.
*Probe:* "what exists after a release that did not exist before it?"
*Default:* none. *Lands in:* Versioning and release, as the tag and
artifact rule.

**S81 The changelog.** Who writes it, from what source, and whether an
entry is required per change or assembled at release time.
*Probe:* "where does a release note come from - the commits, a file
each change edits, or a person?"
*Default:* none; capstone's own ledger records design decisions rather
than shipped changes, so this is a separate file. *Lands in:*
Versioning and release, as the changelog source.

**S82 Cadence and authority.** How often a release ships, who may cut
one, and what must be true before they do.
*Probe:* "who can release, and what stops them on a Friday afternoon?"
*Default:* none. *Lands in:* Versioning and release, as the cadence and
the release authority.

### Process

**S83 Commit messages.** The subject form, whether a type and scope are
required, and what the body must explain.
*Probe:* "code-craft asks for `<type>(<scope>): <subject>` in the
imperative under 72 characters, with a body saying why - what do you
change?"
*Default:* code-craft's Git section, Commit message. *Lands in:*
Process, as accepted or as the named change.

**S84 Branch naming.** The prefix set and how the slug is derived.
*Probe:* "code-craft's types are feat, fix, refactor, docs, test,
chore, perf - is that your list?"
*Default:* code-craft's Git section, Branch. *Lands in:* Process, as
accepted or as the named change.

**S85 Commit density.** How much one commit contains, and whether a
branch is squashed on merge.
*Probe:* "code-craft asks for one reviewable idea per commit and never
a broken one - does your merge button then squash them all anyway?"
*Default:* code-craft's Git section, Density. *Lands in:* Process, as
accepted or as the named change.

**S86 Pull requests.** The size a reviewer will accept, what the
description must carry, how many approvals are needed, and the merge
style.
*Probe:* "how many files is too many for one pull request here, and who
has to approve it?"
*Default:* none. *Lands in:* Process, as the pull-request rule.

**S87 The default branch.** Whether anyone may commit straight to it,
and what protection enforces the answer.
*Probe:* "can you push to `main` right now, and should you be able
to?"
*Default:* code-craft forbids committing to `main` without the user's
explicit consent. *Lands in:* Process, as the branch protection rule.

### Agent rules

**S88 Never.** What an AI assistant must never do here: files it may
not touch, commands it may not run, changes it may not make unasked.
*Probe:* "what would an assistant do in this repo that you would call a
serious mistake, even if the tests passed?"
*Default:* none. *Lands in:* Agent rules, as the never list.

**S89 Always.** What it must do every time: run a named gate, cite the
file it changed, report a failing command's output as it was.
*Probe:* "before an assistant says a task is done, what must it have
run, and what must it have shown you?"
*Default:* none. *Lands in:* Agent rules, as the always list.

**S90 Scope.** How far an agent may range from the request: fixing a
neighboring bug, reformatting a touched file, upgrading a dependency
that got in the way.
*Probe:* "an assistant sees a real bug two functions away from its task
- fix it, report it, or ignore it?"
*Default:* code-craft's Never mix kinds rule keeps a refactor and a
behavior change in separate commits. *Lands in:* Agent rules, as the
scope rule.

**S91 Attribution.** Whether generated code is marked, whether commits
carry co-author or tool trailers, and what a pull-request description
must disclose.
*Probe:* "should a commit say a model wrote it?"
*Default:* code-craft never mentions the tool that wrote a commit and
adds no co-author or generated-by trailer unless asked. *Lands in:*
Agent rules, as accepted or as the named change.

**S92 Where these rules live.** Which file an agent actually reads -
`AGENTS.md`, `CLAUDE.md`, a rules directory - and which copy wins when
two disagree.
*Probe:* "an assistant opens this repo cold - which file tells it the
rules, and does that file agree with this one?"
*Default:* none; `standards.md` is the source, and Phase D offers to
seed the agent file from it rather than doing it unasked. *Lands in:*
Agent rules, as the mirror location and the precedence rule.

## 5. The completeness gate

The interview is finished when **every item is answered, cited, or
recorded inapplicable** - not when nothing more comes to mind.

- **Answered**: the decision is in `standards.md`, under the domain the
  item names.
- **Cited**: `../code-craft.md`'s rule is accepted unchanged. The
  domain section says so and names the rule, so a later reader sees a
  decision rather than a gap.
- **Inapplicable**: recorded in `standards.md`'s closing
  `## Not in play` list, one line each with the reason ("S65
  idempotency: this project exposes no API a caller retries"). Per
  style.md, absent things are facts: a later reader can tell "no API
  here" from "nobody asked about the API", and `review` will not
  re-raise it.

An item the user declines to settle is **not** inapplicable: it is an
open question, recorded as one in the interview file and named in
`standards.md`, so the gap is visible to `stack`, `build` and `review`
rather than silently absent.

A whole domain can be inapplicable. Record it in `Not in play` as one
line naming the domain and the reason, rather than a line per item. The
domain still gets its heading in `standards.md`, holding one sentence
that points at that line: the section list is fixed, and a reader who
opens the file for the API rules deserves an answer where they looked.

Nothing here overrides `standards.md`'s Phase C gate: the sweep decides
what to ask, the user still formalizes before anything is written.
