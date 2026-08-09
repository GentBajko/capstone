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
`implemented` absent → only Phase C remains.

## Phase A — setup

Never write to main/master without the user's explicit consent: offer
a feature branch (or worktree) named after the slug first. Read
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
chain's stage detection reads them, whichever flow executes.

**Otherwise**: execute inline — tasks in order, steps exactly as
written, every verification run and passing before its box is checked
off in `plan.md`, one commit per task. Stop and ask instead of
guessing when a dependency is missing, a verification keeps failing,
or an instruction can be read two ways. The checked boxes in `plan.md`
are the durable progress record — check each as it passes, not in
batches, so a dead session resumes mid-task.

Either way, code lands in the repository's source tree (never under
the docs area), and every code decision follows `code-prefs.md`.

## Phase C — wrap

Entered when every box in `plan.md` is checked (the final task's
verification passing checks the last one).

1. The spec's Reference impact chapters are now stale by construction —
   run the `docs` refresh on them so the reference records what was
   actually built, divergences included.
2. Only now record `implemented: true` in the feature-interview
   frontmatter — the chain's done marker, written after the refresh
   for the same reason `formalized` waits for outputs (a crash can't
   strand a "done" feature with a stale reference). The lifecycle
   `status` has been `formalized` since the spec landed.
3. Offer `changelog` to record the architecture-level delta.
4. Finish the branch: the superpowers execution flows end in
   finishing-a-development-branch themselves — don't repeat it; after
   an inline run, use the repo's own merge flow.
