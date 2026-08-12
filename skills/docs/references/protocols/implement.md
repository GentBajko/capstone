# implement — execute the approved feature plan

Last stage of the feature chain: turns the approved `plan.md` into
code. With `build`, one of the two commands allowed to write source
code (core.md hard rule 2) — and only after its plan gate.

Prerequisite — checked in this order (resolve a `<feature>` argument
as `groom`'s Resume rule does): `implemented: true` → the feature is
done; say so and stop. Otherwise require `plan_approved: true` in the
feature's `feature-interview.md`, with `approved_spec` still matching
a checksum of the current `spec.md`. No approval → execute
`protocols/plan.md` first (which chains `groom` when there is no
spec); a checksum mismatch is a voided approval — likewise `plan`.
`plan_approved` with `plan.md` missing or truncated is a crash:
re-run `plan`'s Phase B from the spec, then re-gate.

**Resume:** if docs are committed, the feature's progress lives on
its branch — check out the feature branch before reading `plan.md`'s
boxes. If the branch's feature-interview frontmatter disagrees with
the entry branch's copy (different approval keys), the newer approval
governs: merge the docs forward before resuming.
Walk the boxes in order: check off any unchecked step whose
verification already passes, continue executing from the first one
that doesn't. Never redo checked steps. Every box checked but
`implemented` absent → only Phases C–D remain; `review-ledger.md`
says where (mid-loop resumes the loop, a recorded dry verdict skips
to the wrap).

## Phase A — setup

Never write to main/master without the user's explicit consent: offer
a feature branch (or worktree) named after the slug first. Record
`base_commit` in the feature-interview frontmatter — the branch
point, or HEAD before Task 1 on a consented main run; Phase C reviews
the diff from it. Read
`plan.md`, `spec.md`, `code-prefs.md`, and the guides the plan's
verification steps rely on (`guides/run-locally.md` if present).
Review the plan critically —
a contradiction between tasks, or between plan and spec, goes to the
user before Task 1, batched, not one interrupt per discovery mid-run.

## Phase B — execute

**If the superpowers plugin is available** (its skills appear in your
skill list): hand off — the spec and plan ARE superpowers' spec and
plan, so skip its brainstorming and writing-plans stages and execute
`plan.md` via `superpowers:subagent-driven-development` (recommended)
or `superpowers:executing-plans`, whichever the user picks. As each
task completes there, check its boxes off in `plan.md` yourself — the
chain's stage detection reads them, whichever flow executes. Stop the
handoff short of superpowers' finishing-a-development-branch step:
when its tasks (and, in the subagent-driven flow, its final
whole-branch review) are done, return here — Phase C loops the
review until dry, and only Phase D finishes the branch.

**Otherwise**: execute inline — tasks in order, steps exactly as
written, every verification run and passing before its box is checked
off in `plan.md`, one commit per task. Stop and ask instead of
guessing when a dependency is missing, a verification keeps failing,
or an instruction can be read two ways. The checked boxes in `plan.md`
are the durable progress record — check each as it passes, not in
batches, so a dead session resumes mid-task.

Either way, code lands in the repository's source tree (never under
the docs area), and every code decision follows `code-prefs.md`.

## Phase C — review until dry

Entered when every box in `plan.md` is checked (the final task's
verification passing checks the last one). Code complete is not code
reviewed: a single pass cannot catch bugs introduced by its own
fixes, so review recursively — loop over the feature's full diff
(`base_commit`..HEAD, from Phase A) until the loop proves itself
dry. The loop's state lives in the feature folder's
`review-ledger.md` (beside the plan; never indexed): every finding
ever raised with its verdict, the dry-round count, and the final dry
verdict — a resumed session picks the loop up from it instead of
restarting at round one.

1. **Round** — independent reviews of the diff, each through a
   different lens: spec compliance (every `spec.md` requirement
   implemented, nothing extra), code quality per `code-prefs.md` and
   the conventions chapter, and the spec's unhappy paths actually
   exercised by the tests. Fresh eyes every round — with subagents,
   dispatch one reviewer per lens; without, re-read the diff once per
   lens, coldly.
2. **Verify** — adversarially check each finding before acting: try
   to refute it against the spec, the plan, and the reference. Every
   finding goes into the ledger, confirmed or refuted; a round counts
   only findings not already there — dedupe against the ledger, not
   against the confirmed list, or refuted findings reappear and the
   loop never converges.
3. **Fix** — confirmed Critical/Important findings are fixed and
   their covering verifications re-run; fixes are new code and
   re-enter the next round. Minor findings: fix or record, per
   `code-prefs.md`.
4. **Dry** — a round with zero new confirmed findings. Two
   consecutive dry rounds end the loop; one is not enough — the
   round after a fix wave exists to review the fixes. Record the dry
   verdict in the ledger; Phase D resumes read it.

In the subagent-driven handoff, that flow's final whole-branch review
counts as round one (record its findings in the ledger); the
executing-plans handoff has no final review, so start at round one
yourself. Keep looping until dry either way.

## Phase D — wrap

Entered when Phase C goes dry.

1. The spec's Reference impact chapters are now stale by construction —
   run the `docs` refresh on them so the reference records what was
   actually built, divergences included.
2. Append the changelog entry per core.md's ledger — key
   `implement/<NN>-<slug>@Q<n>`, the same highest `§Q` (this stage adds
   none, so the key is stable across a resumed review loop). Record the
   completed task list, the files the `base_commit`..HEAD diff touched,
   the chapters refreshed in step 1, and the review-loop counts from
   `review-ledger.md` — rounds run, findings confirmed, fixed, refuted,
   and the dry verdict — which nothing else preserves, since that ledger
   is never indexed.
3. Only now record `implemented: true` in the feature-interview
   frontmatter — the chain's done marker, written after the refresh
   for the same reason `formalized` waits for outputs (a crash can't
   strand a "done" feature with a stale reference). The lifecycle
   `status` has been `formalized` since the spec landed.
4. Finish the branch — the step Phase B deferred: superpowers'
   finishing-a-development-branch when installed, the repo's own
   merge flow otherwise (on a consented main run there is no branch
   to finish — just the repo's push conventions).
5. Run `changelog` (execute `protocols/changelog.md`) — mandatory, not
   offered. Running it after the branch is finished keeps its refs
   reachable from the mainline; if a PR merge has not landed locally
   yet, run it once the merge is pulled.
