# implement - execute the approved feature plan

**Reads:** config → the feature interview's approval frontmatter → `plan.md`
→ `spec.md` → `standards.md` → `../code-craft.md` → the operations
chapter its verifications rely on → `review-ledger.md` (resume).

Last stage of the feature chain: turns the approved `plan.md` into
code. With `build`, one of the two commands allowed to write source
code (core.md hard rule 2), and only after its plan gate.

Prerequisite, checked in this order (resolve a `<feature>` argument
as `groom`'s Resume rule does): no folder but an
`implement/<id>` key in the ledger (`changelog.md`, its rotation
files, or an unfolded `changelog.d/` fragment), or `implemented: true`
in a folder still present → the feature is done; say so, point at the
changelog entry, and stop. Otherwise require `plan_approved: true` in the
feature's `feature-interview.md`, with `approved_spec` still matching
a checksum of the current `spec.md`. No approval → execute
`protocols/plan.md` first (which chains `groom` when there is no
spec); a checksum mismatch is a voided approval: likewise `plan`.
`plan_approved` with `plan.md` missing or truncated is a crash:
re-run `plan`'s Phase B from the spec, then re-gate.

**Resume:** `features/` is gitignored (core-authoring.md's Local-only
outputs), so
the feature's progress lives in the working tree and is never
branch-scoped: read `plan.md`'s boxes directly, whatever is checked
out, and there is no docs copy to merge forward. The code those boxes
describe IS branch-scoped, so confirm the checked-out branch is the one
`base_commit` names before trusting a checked box; on a mismatch, say so
and check the branch out rather than re-running its tasks.
Walk the boxes in order: check off any unchecked step whose
verification already passes, continue executing from the first one
that doesn't. Never redo checked steps. Every box checked but
`implemented` absent → only Phases C-D remain; `review-ledger.md`
says where (mid-loop resumes the loop, a recorded dry verdict skips
to the wrap).

## Phase A - setup

Never write to main/master without the user's explicit consent: offer
a feature branch (or worktree) first, named per `../code-craft.md`'s
Git section (`<type>/<slug>`, the slug the feature's own). Record
`base_commit` in the feature-interview frontmatter: the branch
point, or HEAD before Task 1 on a consented main run; Phase C reviews
the diff from it. Read
`plan.md`, `spec.md`, `standards.md`, `../code-craft.md` (the
TDD + YAGNI discipline the code follows; standards wins on
conflict), and the operations chapter the plan's verification steps
rely on (`07-operations.md`'s Processes and Developer workflow
sections carry the verified commands). Review the plan critically:
a contradiction between tasks, or between plan and spec, goes to the
user before Task 1, batched, not one interrupt per discovery mid-run.

## Phase B - execute

**Ask the mode once, before Task 1**, and record it as
`execution: subagent | inline` in the feature-interview frontmatter
so a resumed run never re-asks:

> "Run the tasks in subagents (fresh context per task, recommended) or
> inline in this session?"

Subagent is the recommendation: a task executed in its own context
cannot drift on the previous task's leftovers, and the plan was
written so each task carries everything its executor needs. Inline is
the right pick for a short plan, a harness without subagents (state
that and take it, don't ask), or a user who wants to watch each step.

Both modes obey the same rules: tasks in dependency order, steps
exactly as written, every verification run and **passing** before its
box is checked off in `plan.md`, one commit per task per
`../code-craft.md`'s Git section (its density, message format, and
never-a-broken-commit rule; a task is exactly the "one reviewable
idea" that section names), never `git add`-ing the docs area or the
index. Stop and ask instead of guessing when a dependency is missing,
a verification keeps failing, or an instruction can be read two ways.
The checked boxes in `plan.md` are the durable progress record: check
each as it passes, never in batches, so a dead session resumes
mid-task.

### Subagent mode

One subagent per task, dispatched fresh, in plan order. Never two at
once: each task consumes what the previous one defined.

**The subagent's prompt carries everything, because nothing else
crosses into its context.** Copy in, verbatim rather than by
reference:

1. The task's full text from `plan.md`: its `Create:`/`Modify:`/
   `Test:` paths, the interfaces it consumes and produces, and every
   checkbox step with its code and exact commands.
2. `standards.md`'s rules, and `../code-craft.md`'s ladder, TDD
   scoping, **Comments section, and Git section in full**. A pointer
   to a file is useless here: a subagent that never reads
   `code-craft.md` commits however it likes, and comments every line
   it writes.
3. The conventions chapter's paradigm, typing, and error-handling
   rules, plus the operations chapter's verified commands.
4. The rules: execute only this task; run every verification and do
   not report success until it passes; commit exactly once, in the
   given format; touch no path outside the task's list; never
   `git add` the docs area; report the verification output, the
   commit subject, and anything ambiguous rather than deciding it.

Then, in the main session: check the task's boxes off yourself against
the reported verification, and dispatch the next. A subagent reporting
a failure it could not resolve, or an instruction it read two ways,
stops the run and goes to the user: never re-dispatch the same task
hoping for a better roll.

### Inline mode

Execute the tasks yourself in the same order, under the same rules,
checking each box as its verification passes.

Either way, code lands in the repository's source tree (never under
the docs area), and every code decision follows `standards.md` and
`code-craft.md`.

## Phase C - review until dry

Entered when every box in `plan.md` is checked (the final task's
verification passing checks the last one). Code complete is not code
reviewed: a single pass cannot catch bugs introduced by its own
fixes, so review recursively: loop over the feature's full diff
(`base_commit`..HEAD, from Phase A) until the loop proves itself
dry. The loop's state lives in the feature folder's
`review-ledger.md` (beside the plan; never indexed): every finding
ever raised with its verdict, the dry-round count, and the final dry
verdict; a resumed session picks the loop up from it instead of
restarting at round one.

1. **Round**: independent reviews of the diff, each through a
   different lens: spec compliance (every `spec.md` requirement
   implemented, nothing extra), code quality per `standards.md`,
   `code-craft.md` (unearned abstractions, unclimbed ladder rungs,
   and comments that only restate the code are findings), and
   the conventions chapter, and the spec's unhappy paths actually
   exercised by the tests. Fresh eyes every round: with subagents,
   dispatch one reviewer per lens; without, re-read the diff once per
   lens, coldly.
2. **Verify**: adversarially check each finding before acting: try
   to refute it against the spec, the plan, and the reference. Every
   finding goes into the ledger, confirmed or refuted; a round counts
   only findings not already there: dedupe against the ledger, not
   against the confirmed list, or refuted findings reappear and the
   loop never converges.
3. **Fix**: confirmed Critical/Important findings are fixed and
   their covering verifications re-run; fixes are new code and
   re-enter the next round. Minor findings: fix or record, per
   `standards.md`.
4. **Dry**: a round with zero new confirmed findings. Two
   consecutive dry rounds end the loop; one is not enough: the
   round after a fix wave exists to review the fixes. Record the dry
   verdict in the ledger; Phase D resumes read it.

Both execution modes start this loop at round one: neither performs a
whole-branch review of its own, and a per-task subagent has seen only
its own task, so nothing it reported counts as a review of the diff.
In subagent mode the round's lenses may themselves be dispatched in
parallel, one reviewer per lens, each reading the full diff.

## Phase D - wrap

Entered when Phase C goes dry.

1. The spec's Reference impact chapters are now stale by construction:
   run the `map` refresh on them so the reference records what was
   actually built, divergences included.
2. **Absorb the spec**: `features/` is local-only, so this is where
   its knowledge becomes durable. Per the spec's Reference impact
   list: merge the Behavior section into `logic/` (a new
   `NN-<scenario>.md` for a new scenario, amendments inside the named
   files otherwise; as built, divergences from the spec recorded as
   the shipped rule); update the `mockup/` screens the feature
   changed; update the touched `uiux/screens/` chapters, and
   `uiux/02-system.md` only when the spec recorded a token or lock
   change. Every absorbed or created file gains
   `absorbed_from: features/<id>@<date>` in frontmatter;
   refresh the folders' README indexes and Companion docs rows.
3. Write the changelog entry per core.md's ledger (a `changelog.d/`
   fragment): key
   `implement/<id>@Q<n>`, the same highest `§Q` (this stage adds
   none, so the key is stable across a resumed review loop). The
   entry stays a fragment here: folding is main-only per the ledger
   rule, and this run is normally on a feature branch. The fragment
   merges as its own file - that is the point - and the next writing
   run on main folds it. On a consented main run, fold per the
   ledger rule, this entry included.
   **Step 6 deletes the feature folder, so this entry is all that
   survives it: write it to be read without the spec beside it.**
   Bullets only, per the ledger's entry format. This is the longest
   entry any stage writes and still never a narrative:

   - **What**: the feature in one line, and for whom.
   - **Approach**: the one taken; then one bullet per alternative the
     spec rejected, each with its reason.
   - **Out of scope**: one bullet per ruling.
   - **Tasks**: the completed list, one line each.
   - **Diff**: the paths `base_commit`..HEAD touched.
   - **Chapters refreshed** (step 1) and **scenarios absorbed**
     (step 2): one bullet per file, naming what it gained or amended.
   - **Review loop**: rounds run, findings confirmed / fixed /
     refuted, and the dry verdict, from `review-ledger.md`.

   None of that is recoverable once the folder is gone; the shipped
   behavior lives in `logic/` and the chapters, but the reasoning
   lives only here.
4. Only now record `implemented: true` in the feature-interview
   frontmatter: the chain's done marker, written after the refresh
   and the absorption for the same reason `formalized` waits for
   outputs (a crash can't strand a "done" feature with a stale
   reference). The lifecycle `status` has been `formalized` since the
   spec landed.
5. Finish the branch: the repo's own merge flow, following whatever
   `git log` shows it uses (on a consented main run there is no branch
   to finish, just the repo's push conventions). Ask before opening a
   PR or pushing; neither is implied by the plan's approval.
6. **Delete `features/<id>/`**, last, once step 3's entry is on
   disk and the branch is finished. The folder was scaffolding: the
   spec is absorbed into `logic/`, `mockup/`, and `uiux/`, the plan
   is spent, the ledger's counts are in the changelog entry, and
   `features/` is gitignored so nothing here is recoverable from
   history anyway. Deleting it keeps the folder to features actually
   in flight.

   From here the **changelog key is the done marker**: the id is
   retired and never reused, and every stage-detection rule below
   reads "folder absent AND an `implement/<id>` key in the ledger
   (fragments included)" as done. Folder still present with that key is a
   torn wrap, not an unfinished feature: finish the delete, never
   re-run the stage (`doctor` repairs this).
