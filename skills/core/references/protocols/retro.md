# retro - turn a finished session into edits to the agent's environment

**Reads:** config → `<index_file>` → `<docs_dir>/standards.md` →
`<docs_dir>/03-conventions.md`
→ the project's `AGENTS.md` and `CLAUDE.md` where either is present →
the ledger (`<docs_dir>/changelog.md`, its rotation files, and
`changelog.d/` fragments; the latest `retro` entry's declined rows
among them) → the session the user names, defaulting to the one
running now.

Read-only diagnosis first, then edits the user approves, the same
posture `doctor` takes. The subject is the environment the agent
worked in: the steering files it read, the standards it was bound by,
the checks a machine runs for it, and the docs it had to reach
through. It never changes code and never rewrites a chapter; `map`
owns the reference and `implement` owns the source. It runs under
`review`, so it is core.md hard rule 1's named exception: it ranks
candidates and recommends edits to the environment because the user
invoked it. Its judgment stops at that environment: `review`'s sides
hold every opinion about the codebase, and retro holds none about it.

**Attribution.** Adapted, condensed and modified, from
mattpocock/skills (MIT, © Matt Pocock,
<https://github.com/mattpocock/skills>), whose `retro` command reads a
finished session and proposes changes to the instructions the agent
ran under. That project does not endorse this adaptation, and is not
required for any capstone command to run.

## The session is the evidence

Every finding cites something that happened in the session: a
correction the user made, a review round that found the same defect
twice, a path the run searched for and did not find, a command re-run
because nothing recorded it. Open the named session's transcript when
the harness can reach one. A harness that cannot open a past session
says so in one line and the run continues against the session in
progress. Never infer an event the transcript does not hold: a
candidate with no evidence in this session is not reported at all.
A row the latest `retro` ledger entry records as declined is not
raised again unless this session holds new evidence for it, which
the row then names.

## Candidates

Walk all seven, in this order. Each says what to look for and when it
applies. A category with nothing behind it is reported clear in one
line, never filled with a plausible suggestion.

1. **Navigation.** A fact the reference already held that the run
   reached late: three chapters opened to answer one question, a glob
   over the source tree for a path `01-architecture.md` names, a file
   opened that no index row points at. Applies when the fact existed
   and was found slowly. Proposed edit: the command that makes the
   fix durable, never a line pasted into a generated chapter, which
   the next `map` refresh erases: a file with no index row is
   `doctor`'s check 3, and a chapter that buries the fact is
   regenerated from the code by `/capstone:map <topic>`. A fact that
   was absent rather than buried is candidate 7, never this one.
2. **Automated checks.** A defect a machine can detect that a human
   caught instead: a review round naming an unhandled failure path, a
   user correcting an import the layering forbids, a missing test the
   `06-testing.md` layout already requires. Applies when the rule is
   mechanical, so a linter, a type checker or a test can decide it
   without judgment. Proposed edit: the rule itself, named exactly,
   plus the `standards.md` domain that records it (Tooling for the
   rule, CI gates for whether it blocks a merge).
3. **Standards rules.** A decision the session made twice, a
   correction with no recorded rule behind it, or a rule the run
   satisfied by reading around it. Applies when the answer is durable
   and specific to this project. The proposed edit names the domain
   from `../standards-inventory.md` §3 that owns it and whether the
   rule is added, removed or sharpened; a sharpening quotes the
   sentence standing today beside the sentence replacing it. Compare
   the rule against `03-conventions.md` before proposing it: a rule
   the code already follows everywhere is a rule nobody needs.
4. **Steering-file bloat.** Instructions in `AGENTS.md` or
   `CLAUDE.md` that belong elsewhere: a rule `standards.md` already
   binds, a rule a lint could enforce, background prose the run never
   used. Applies when a line can move without losing force. The
   proposed edit names the destination and the one-line pointer the
   steering file keeps, per `../standards-inventory.md`'s S92:
   `standards.md` is the source and the agent file mirrors it.
5. **Tool economy.** Expensive or repeated calls a recorded command
   would replace: the same shell pipeline run three times or more, a
   whole-tree search to find one path, a build re-run because no run
   command was written down. Applies when the call is deterministic
   and worth naming. Proposed edit: a script plus the line that names
   it, and `/capstone:map operations`, which regenerates
   `07-operations.md` from the code so the command lands there
   durably; never a line pasted into that generated chapter, which
   the next `map` refresh erases.
6. **No-ops.** A steering instruction that changed no behavior: one
   the run had occasion to apply and would have satisfied without it,
   or one worded too vaguely to act on. Applies only where the
   session did the thing the rule governs. A rule the session never
   approached is untested, not dead, and is not reported. Proposed
   edit: delete it, or replace it with the check that would make it
   observable.
7. **Information access.** What the agent needed and could not reach:
   a question it answered by asking the user, a value it guessed,
   source it read because no chapter held the answer, a cross-repo
   contract with no row in `09-interfaces.md`. Applies when the
   missing fact belongs in a capstone output. Proposed edit: the
   chapter or scenario file that should hold it, and the command that
   writes it (`map <topic>`, `start logic`, `groom`).

## Where a rule belongs

The implementing agent carries the context pressure. It holds the
plan, the diff, the tests and the standards at once, and every
sentence added to its instructions competes with the work for
attention. The reviewer starts fresh and sees only a diff, so a rule
placed there costs nothing until it fires. **A new rule belongs to
the reviewer wherever a reviewer can check it**, and to the
implementer only where following it late means rewriting the work.
Cite this rule in the findings table for every candidate that could
sit on either side, and say which side it went to.

## Output: one findings table, approved row by row

Order by severity, highest first: what cost correctness (the session
shipped, or came close to shipping, something wrong), then what cost
turns (work redone, calls repeated), then what cost friction (a slow
read, a sentence too vague to act on). Ties break by candidate
number.

| # | Candidate | Category | Evidence | Proposed edit | Owning file |
| --- | --- | --- | --- | --- | --- |

`Evidence` is what happened, in one line, naming the turn or the
`file:line` it happened over. `Proposed edit` is the text to write,
not a description of it. `Owning file` is where that text lands.

Ask for each row: approve, skip, or amend. The table is a
message question per core.md's Structured questions: it is the chat
message, its last line asks for a verdict on each row by number, and
the turn ends there. The user answers in one reply, row by row: a
verdict per row number, never one verdict for the batch. Nothing is
applied before its own row is approved. An amended row is not yet
approved: apply the approved rows, then present each amended row
again, marked amended, as the next message question, and apply it
only once it is approved as shown. The text written is the approved
text, verbatim.

**Applying.** An approved edit to `<docs_dir>/standards.md` is written
into the domain `../standards-inventory.md` §3 names for it, under
that `## <Domain>` heading, in the imperative voice the file already
uses; a rule removed leaves one line in `## Not in play` carrying the
reason. Retro never creates `standards.md`: with no such file, an
approved rule that belongs there is printed for the user like the
rest, naming `/capstone:start standards` as the command that creates
the file. Everything else is proposed as text and never written, and
a fix that is a command (`/capstone:map <topic>`, `doctor`,
`start logic`, `groom`) is named for the user to run, never run by
retro.
`AGENTS.md`, `CLAUDE.md`, linter configs, CI workflows and test files
sit outside the docs area core.md hard rule 2 confines this run to,
and retro owns no file there: print the exact text and the file and
section it goes in, and stop. No index row is added, since
`standards.md` already carries one.

Then append the changelog entry per core.md's ledger whenever the
table proposed anything, approved or not: key `retro/<scope>@<stamp>`
with `<scope>` always `all` (`retro/all@<stamp>`), since a retro
reads a whole session. Bullets: each rule added, removed or sharpened
with the domain it landed in, and each declined row with its
candidate, its proposed edit in one line, and the reason the user
gave; the next retro reads them (The session is the evidence, above).
A run whose candidates all came back clear proposed nothing: it
writes nothing, sets no marker, and says so in one line.
