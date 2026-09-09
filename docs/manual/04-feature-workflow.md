# Take a feature from idea to code

Use `feature` when an existing product needs one coherent change:

```text
/capstone:feature add CSV export for the account activity table
```

The chain is `groom` → `plan` → `implement`. It reads the existing reference, asks the questions needed to specify the change, presents an implementation plan for approval, executes it, reviews the diff, and updates the affected documentation. It can bootstrap a missing reference through map, subject to the large-repository confirmation rule.

Every new or resumed `feature` run in 6.4.1 first asks **inline or subagents**. There is no default. The choice covers research, mapping, planning, implementation, review, and wrap in that run. Inline prohibits subagent dispatch even above the map threshold. A later invocation asks again; a continuation of the same active run carries the answer forward. More agents can consume more of your harness allowance.

## Groom: agree what the feature does

To stop after the specification, invoke the stage directly:

```text
/capstone:groom add CSV export for account activity
```

Groom reads the index and the topics/scenarios/screens the change touches. It checks those topics' freshness and refreshes stale material before shaping the feature. If configured, it queries Quarry's downstream consumers and reads their contracts before the first interview question.

The interview establishes purpose, users, measurable success, candidate approaches, rejected alternatives, exact behavior, unhappy paths, and exclusions. For CSV export, useful decisions include who may export, whether filters apply, which fields are included, how large exports behave, and how failures are reported. These are illustrative questions, not preset answers or a promised default export design.

If the request hides several independent features, grooming splits the work and specifies one at a time. A ticket, PRD, or notes file can seed the interview; the agent presents the extracted answers for confirmation. Each new answer is written before the next question.

At the specification gate, the stage presents its summary and waits for approval. It then writes:

```text
docs/capstone/features/2026-09-09-csv-export/
  feature-interview.md
  spec.md
```

The actual identifier uses the date grooming began and a derived kebab-case slug. `spec.md` contains What & why, numbered Requirements, Approach, Behavior, Reference impact, and Out of scope. Reference impact names both code-reference chapters and scenario/screen files that must absorb the shipped behavior. Confirmed cross-repository names are recorded there for implement's later wrap.

Groom adds `groom/<id>@Q<n>` to the ledger and sets the interview's `status: formalized`. **Formalized here means the spec exists, not that code exists.** A standalone groom stops; the feature chain proceeds to plan.

## Plan: approve concrete work and verification

```text
/capstone:plan 2026-09-09-csv-export
```

With exactly one unfinished feature, the argument can be omitted. With several, select the identifier the agent reports. If the spec has not been formalized, plan runs groom first.

The output is `features/<id>/plan.md`:

| Part | What to check before approving |
| --- | --- |
| Header | Goal, approach, stack pieces, and relevant global rules copied from spec and standards |
| File map | Every file created or modified, with one responsibility each |
| Tasks | Exact Create/Modify/Test paths, consumed/produced interfaces, code, verification commands, expected results, and checkboxes |
| Coverage | Every requirement, behavior rule, and global constraint mapped to implementation and proving tests |

Tasks are ordered by dependency, with backend work before frontend work that uses it. The protocol requires the actual verification/code details rather than placeholders such as “add validation.” It repeatedly reviews the plan against the spec until a full pass finds no correction. For cross-repo changes, the affected consumer, contract, and fields are copied into each relevant task, not left only in a general introduction.

Approval writes a ledger entry and records `plan_approved: true` plus `approved_spec`, a checksum of the current spec. Changing `spec.md` voids that approval: the stage removes the old approval keys, studies the changed spec, updates the plan, and asks again. A plan file existing on disk is not approval by itself.

In 6.4.1, implementation reads copied constraints while writing code; its later reviewer reads the full `standards.md`. This makes the plan's Header important: it must carry every rule the executor needs up front.

## Implement: execute, review, and preserve the result

```text
/capstone:implement 2026-09-09-csv-export
```

A standalone implement asks for its own execution choice, including review-only or wrap-only resumes. Inside `feature`, it inherits the current answer. A missing/invalid plan approval leads back to plan.

Before writing to main/master, the protocol requires explicit consent and otherwise offers a feature branch or worktree. It records a `base_commit` checkpoint for the diff. Tasks run sequentially; in subagent mode, one fresh executor receives one task at a time. The task's verification must pass before its checkbox is checked. Each task has one source commit. A failure that cannot be resolved, missing dependency, or ambiguous instruction stops for clarification rather than silently redefining the plan.

After all boxes are checked, implement reviews the whole feature diff through spec compliance, code quality/standards, and unhappy-path test coverage. Findings are verified before changes, and both confirmed and refuted findings go into `review-ledger.md`. Confirmed Critical/Important findings are fixed and their checks rerun. Two consecutive rounds with zero **new confirmed** findings end the loop; repeated refuted findings are deduplicated too. This is the protocol's completion rule, not proof that no defect remains.

Wrap then:

1. Refreshes the spec's affected reference chapters and writes already-confirmed interface far ends.
2. Absorbs implemented behavior into `logic/`, changed mockup screens, and relevant UI design files; updates indexes and `absorbed_from: features/<id>@<date>`.
3. Writes `implement/<id>@Q<n>` with the feature, alternatives, exclusions, tasks, diff paths, refreshed/absorbed files, and review results.
4. Sets `implemented: true`, completes the repository's branch flow, and finally deletes the local feature folder.

Source commits do not include the docs area. Refreshed reference files remain dirty or staged for the repository's normal documentation commit flow. The protocol separately asks before a push or PR; plan approval does not itself authorize publication. Check the documentation diff and ledger are included in the intended repository workflow before relying on another clone to have them.

## Resume or change an existing feature

Run `/capstone:feature <id>` again in the same working directory. It reads state rather than restarting. A valid approved plan resumes execution; all tasks checked resumes review/wrap. Unchecked work whose verification already passes may be checked off; completed verified tasks are not blindly rerun. Confirm the code checkout matches the feature's branch context before trusting local checkboxes, because the ignored plan does not change when Git switches branches.

The feature folder is ignored and not recoverable from a fresh clone unless separately preserved. Once the folder is gone, the `implement/<id>` ledger key is the done marker. A later request to change that shipped behavior creates a new feature and a new identifier; it does not reconstruct and reopen the deleted plan. A remaining folder with a completed ledger key is a torn wrap for `doctor`, not permission to build it again.

Sources: [feature router](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/feature.md), [groom](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/groom.md), [plan](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/plan.md), [implement](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/implement.md).
