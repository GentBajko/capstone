# retro - turn a finished session into edits to the agent's environment

**Reads:** config → `<docs_dir>/standards.md` → `<docs_dir>/03-conventions.md`
→ the project's `AGENTS.md` and `CLAUDE.md` where either is present →
the ledger (`<docs_dir>/changelog.md`, its rotation files, and
`changelog.d/` fragments) → the session the user names, defaulting to
the one running now.

Read-only diagnosis first, then edits the user approves, the same
posture `doctor` takes. The subject is the environment the agent
worked in: the steering files it read, the standards it was bound by,
the checks a machine runs for it, and the docs it had to reach
through. It never changes code and never rewrites a chapter; `map`
owns the reference and `implement` owns the source. It is not
core.md's judgment exception either. `review` still holds every
opinion about the codebase, and retro holds none about it.

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
progress. Never infer an event the transcript does not hold, and never
carry a finding forward from an earlier retro: a candidate with no
evidence in this session is not reported at all.

## Candidates

Walk all seven, in this order. Each says what to look for and when it
applies. A category with nothing behind it is reported clear in one
line, never filled with a plausible suggestion.

1. **Navigation.** A fact the reference already held that the run
   reached late: three chapters opened to answer one question, a glob
   over the source tree for a path `01-architecture.md` names, a file
   opened that no index row points at. Applies when the fact existed
   and was found slowly. Proposed edit: an index row, or a pointer
   line in the chapter a reader opens first. A fact that was absent
   rather than buried is candidate 7, never this one.
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
   and worth naming. Proposed edit: the verified command into
   `07-operations.md`, or a script plus the line that names it.
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
   writes it (`map <topic>`, `logic`, `groom`).

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

Ask for each row: approve, skip, or amend. Nothing is applied before
its own row is approved, and the answers are taken row by row rather
than as one batch.

**Applying.** An approved edit to `<docs_dir>/standards.md` is written
into the domain `../standards-inventory.md` §3 names for it, under
that `## <Domain>` heading, in the imperative voice the file already
uses; a rule removed leaves one line in `## Not in play` carrying the
reason. Everything else is proposed as text and never written.
`AGENTS.md`, `CLAUDE.md`, linter configs, CI workflows and test files
sit outside the docs area core.md hard rule 2 confines this run to,
and retro owns no file there: print the exact text and the file and
section it goes in, and stop. No index row is added, since
`standards.md` already carries one.

Then append the changelog entry per core.md's ledger, and only when
`standards.md` was actually changed: key `retro/<scope>@<stamp>`,
`<scope>` being `all` for a retro covering a whole session or the
domain name when one domain was touched. Bullets: each rule added,
removed or sharpened with the domain it landed in, and each candidate
the user declined with the reason they gave, since the next retro will
raise it again otherwise. A run that proposes and is declined writes
nothing, sets no marker, and says so in one line.
