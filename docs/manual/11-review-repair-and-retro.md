# Review code, repair documentation, and improve instructions

These commands answer different questions. `review` evaluates the code and UI. `doctor` checks whether Capstone's own documentation state is consistent. `retro` uses evidence from a session to propose better rules, checks, and access to information. None is a general source-code fix command.

## review: opinionated findings with evidence

```text
/capstone:review
/capstone:review backend
/capstone:review fe
```

No argument runs backend then frontend. `backend`/`be` and `frontend`/`fe` select one side. A project with no frontend records that side as not applicable rather than pretending a UI review happened.

The backend side refreshes stale reference material before judging it. It checks boundary integrity, unused/unwired code, typing, failure paths, important test gaps, unnecessary module complexity, repeated change patterns, security trust boundaries, stack currency, and differences from recorded standards. It uses source spot checks for evidence; a recorded project decision can justify a departure from generic craft advice.

The frontend side compares the implementation with the project's UI system, experience rules, screen designs, and required states. With browser capability and a verified run command, the protocol inspects screens in shipped themes at desktop/mobile sizes. Otherwise it states that findings are based on source. Missing UI docs do not block a review, but the findings then rest on the craft baseline and inferred surface modes; uiux extraction can provide an explicit observed reference first.

Output is `docs/capstone/review.md`, marked as opinion, with Backend and Frontend sections and Critical/Important/Minor findings. Each side has a separate date/commit stamp. A one-sided run preserves the other side and its stamp. Each finding includes the claim, source/screenshot evidence, why it matters, and a suggested direction. Severity reflects user harm, not the number of style rules involved.

The report is ignored local output, while the ledger records the occurrence and counts of the review. Repeated reviews at the same commit receive distinct event keys. Review never implements its findings; select an accepted issue and use `/capstone:feature <change>` to specify, approve, and implement it. It also does not merge legacy `be-review.md`/`fe-review.md` into the current report; those are superseded and their deletion is offered separately.

## doctor: restore documentation consistency

```text
/capstone:doctor
/capstone:doctor fix
```

Doctor first presents a findings table with the check, finding, owning rule, and proposed repair. The normal invocation waits for approved repairs. `fix` pre-approves documented crash-rule repairs, not arbitrary rewrites or new decisions. A clean or report-only run writes nothing. Actual repairs get one `doctor/<scope>@<stamp>` ledger entry and relevant checks are rerun.

| Symptom | What doctor checks and can repair |
| --- | --- |
| A stage says done but has no ledger key | Catch up the missing entry from recorded decisions; do not re-interview |
| A key exists but its output is missing | Regenerate from available recorded decisions; report unrecoverable loss if those records are absent |
| A feature plan's approval no longer matches its spec | Remove invalid approval, re-plan and re-gate |
| Approved plan missing/truncated | Rebuild the plan from the spec and require its gate again |
| Shipped feature folder remains | Diagnose torn wrap; finish the prescribed wrap cleanup rather than replay tasks |
| Index links fail or outputs lack rows | Repair index/file relationships and legacy index location |
| Final docs cite private interview questions | Put the actual decision/rationale into the owning final file and remove private provenance |
| Ignore/config policy drift | Run initializer or correct approved keys/tracking; personal keys do not belong in project settings |
| Shipped features were not absorbed | Re-run absorption from available feature spec; do not invent a deleted spec |
| Missing logic coverage | Run the appropriate map extraction for the missing behavior |
| Ledger too large or fragments pending | Rotate/fold under the ledger's branch rules |
| Interface schema/site/model gap | Use the owning map/schema repair path |
| Questionnaire unanswered after its stage moved on | Name the recipient/date; do not fill or delete the unanswered request |
| Asset marked present but missing | Report the inconsistency and repair its status or supply the file |

Doctor does not silently bootstrap a missing reference. That absence is a finding; use map when the intended action is to generate the initial reference. A non-default branch's pending fragments are expected and remain unfolded.

## retro: improve the environment from a real session

```text
/capstone:retro
/capstone:retro <session-name>
```

The optional session name is resolved by your harness; it is not a Capstone-global transcript ID format. If the harness cannot read a past session, the command says so and uses the current one.

Retro looks for seven kinds of evidence: a documented fact found late; defects a machine check could have caught; rules repeatedly needing correction; steering-file bloat; repeated/expensive commands; instructions that demonstrably changed no behavior; and required information that was unavailable. No supporting event means no invented suggestion. A rule the session never exercised is untested, not automatically dead.

The output is a conversation table: `# | Candidate | Category | Evidence | Proposed edit | Owning file`. It presents exact proposed text, ordered by correctness impact, wasted work, then friction. You approve, skip, or amend **each row**. This is not a blanket approval to rewrite the agent's instructions.

Retro directly applies only approved changes to `standards.md`, in the owning domain. Removed rules leave a reason under Not in play. Changes to `AGENTS.md`, `CLAUDE.md`, lint configs, CI, tests, source, index, or reference chapters are proposed as text and a destination, not applied by this command. Use the appropriate writer separately. There is no `retro.md` output file and no independent retro interview lifecycle.

Only a run that actually changes standards writes `retro/<scope>@<stamp>`. In 6.4.1, a rule should generally be placed with the reviewer if it can be checked there; the executor needs rules up front when following them later would require rewriting its work. Retro explains that placement rather than automatically accumulating longer implementation prompts.

Sources: [review protocol](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/review.md), [doctor protocol](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/doctor.md), [retro protocol](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/references/protocols/retro.md), [initializer repairs](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/init-config.sh).
