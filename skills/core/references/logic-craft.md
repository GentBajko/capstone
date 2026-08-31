# Logic craft - the rule dimensions every scenario is swept against

Read by `protocols/logic.md`. **This file is the method** for
specifying business logic, in full: the same product yields the same
rule coverage on any machine, whoever runs the interview.

## 1. What this file is, and is not

Not a question list. The questions belong to the domain and cannot be
written down in advance: a payments product and a game ask nothing
alike. What can be written down is the set of **dimensions** a rule
can live in, and those are the same everywhere. Sweeping a scenario
against them generates that scenario's questions.

This exists because `logic`'s generation rule - *"if I had to
implement this scenario right now, what rule would I have to
invent?"* - orders the questions well and stops badly. It measures
what you noticed, so a rule nobody thought to ask about reads exactly
like a rule that does not exist. The dimensions below are what nobody
thinks to ask.

**The split: the generation rule orders, this sweep gates.** The rule
still picks what to ask next, by whatever matters most. §4's gate
decides when the scenario is finished.

## 2. The sweep, per scenario

Run it yourself; it is not an interrogation the user sits through.

1. **Generate.** For each dimension in §3, write the questions it
   raises *for this scenario*. Most raise none.
2. **Eliminate.** Delete every question already answered by the
   mockup, by an earlier scenario, or by an earlier answer in this
   one. A dimension a previous scenario settled globally is cited
   through the scenario's `depends_on` frontmatter, never re-asked.
3. **Batch the empties.** Dimensions that do not apply go into **one**
   confirmation, not one question each: "no money moves here, nothing
   is notified, one actor throughout - right?" A correction turns a
   batched empty back into a real question.
4. **Ask what remains**, one per turn, per `logic`'s Phase B conduct.
5. **Record.** Applicable answers land in the scenario file's normal
   sections (§3 names which). Dimensions ruled inapplicable are
   recorded per §4.

The sweep runs once the scenario's happy path is known, not before: a
dimension's questions are only answerable against concrete steps.

## 3. The dimensions

Each carries what it covers, the **probe** that generates its
questions, the **tell** that it applies, and the scenario-file section
its answers land in.

### Who, and whether

**D1 Authority.** Who may trigger this, on whose behalf, under what
role or grant; who may act for someone else; what happens when
authority is revoked mid-flow.
*Probe:* "who is allowed to do this, and what happens when someone who
was allowed stops being allowed halfway through?"
*Tell:* more than one kind of actor exists. *Lands in:* Trigger &
preconditions.

**D2 Eligibility and preconditions.** What must already be true - of
the actor, the target, the system - before this may run: entitlement,
subscription or quota state, prerequisite lifecycle states, required
prior scenarios.
*Probe:* "what must already be true, and who checks it?"
*Tell:* always. *Lands in:* Trigger & preconditions.

**D3 Input.** What is accepted, what is rejected, what is normalized
before use: canonical forms, length and size and range limits,
defaults for what is omitted, what an empty value means.
*Probe:* "what does the user or caller supply, and what is the worst
thing they could supply that must still be handled?"
*Tell:* anything crosses the boundary. *Lands in:* Steps, Unhappy
paths.

### What is computed

**D4 Computation.** Every number this scenario produces or compares:
the formula, each input and where it comes from, units, rounding and
its direction, precision, tie-breaks.
*Probe:* "show me the arithmetic: what exactly is combined, in what
order, and what happens to the remainder?"
*Tell:* any number appears. *Lands in:* Steps.

**D5 Money.** Charges, refunds, proration, tax, fees; when value is
reserved versus captured; what a partial or failed attempt costs and
**who absorbs it**.
*Probe:* "who pays, at what moment, and who eats it when it fails
after the money moved?"
*Tell:* value changes hands, including credits and non-currency
balances. *Lands in:* Steps, Unhappy paths, Outcomes & side effects.

**D6 Limits and thresholds.** Caps, rate limits, quotas, minimums;
the behavior **exactly at** the boundary, not near it; who may exceed
one and how.
*Probe:* "what is the number, what happens at exactly that number, and
who is allowed past it?"
*Tell:* any "too many", "too much", "too often". *Lands in:* Branches.

### When

**D7 Time.** Deadlines, expiry, grace periods, retention windows; what
"now" means and whose clock it is; timezone and calendar effects;
whether a stored time is an instant or a wall-clock date.
*Probe:* "what expires, when exactly, and by whose clock?"
*Tell:* anything is scheduled, expires, or is compared to a date.
*Lands in:* Branches, State transitions.

**D8 Sequencing and concurrency.** What happens when this runs twice,
out of order, simultaneously with itself, or while a related scenario
is mid-flight: idempotency, ordering guarantees, who wins a race,
what is locked.
*Probe:* "two of these arrive at the same instant - what is true
afterwards?"
*Tell:* always. *Lands in:* Unhappy paths, Invariants.

**D9 Lifecycle.** Which entity states this moves, which transitions
are legal, which are **forbidden**, which states are terminal, and
what can be reversed after the fact.
*Probe:* "what state does this leave things in, and which way can it
never go?"
*Tell:* any entity changes state. *Lands in:* State transitions.

### When it goes wrong

**D10 Failure and recovery.** Per external dependency and per step
that can fail: retried or not, how many times, with what backoff;
fallback; partial success and what compensates it; what the user sees
meanwhile.
*Probe:* "this step fails - what is retried, what is undone, and what
is left half-done if the retries also fail?"
*Tell:* the scenario calls anything it does not control. *Lands in:*
Unhappy paths.

**D11 Termination.** How this ends on success, on failure, on
cancellation, and on abandonment - a user who simply leaves; what
becomes of work already partly done.
*Probe:* "the user walks away mid-way and never comes back - what is
true an hour later?"
*Tell:* the scenario has more than one step. *Lands in:* Outcomes &
side effects.

### What others see

**D12 Visibility and disclosure.** Who can see what, and when; what is
shown to some actors and not others; and **what is deliberately
hidden**.
*Probe:* "what does the system know here that it deliberately does not
show, and who decided that?"
*Tell:* always. *Lands in:* Steps, Outcomes & side effects.

**D13 Notification.** Who is told, through what channel, at what
moment, saying what; and **what is deliberately silent**.
*Probe:* "who finds out, how, and what happens on purpose without
anyone being told?"
*Tell:* the scenario changes something another actor cares about.
*Lands in:* Outcomes & side effects.

**D14 Effects on others.** What this does to actors and entities it
does not name: fan-out, cascades, other people's balances, queues,
and views.
*Probe:* "who else's world changes because of this, without them
doing anything?"
*Tell:* more than one actor or entity exists. *Lands in:* Outcomes &
side effects.

**D15 Record and audit.** What is written down, how long it is kept,
what is immutable once written, and what must be reconstructible
afterwards and from what.
*Probe:* "six months later, someone disputes this - what proves what
happened?"
*Tell:* anything is persisted. *Lands in:* Outcomes & side effects.

### The closer

**D16 Invariants.** What must never be true after this scenario, on
any path through it, including every failure path above.
*Probe:* "name the thing that must never be true here, then walk each
unhappy path and check it holds."
*Tell:* always; run it **last**, against the answers the other
dimensions produced. *Lands in:* Invariants.

**D2, D8, D12 and D16 apply to every scenario.** The rest are earned
by the tell.

## 4. The completeness gate

A scenario is finished when **every dimension is answered, cited, or
recorded inapplicable** - not when nothing more comes to mind.

- **Answered**: its rules are in the scenario file's sections.
- **Cited**: settled by an earlier scenario, named in `depends_on`.
- **Inapplicable**: recorded in the scenario file's closing
  `## Dimensions not in play` list, one line each with the reason
  ("D5 money: nothing is charged or credited in this flow"). Per
  style.md, absent things are facts: a later reader can tell "no money
  here" from "nobody asked about money", and `review` will not
  re-raise it.

A dimension the user declines to settle is **not** inapplicable: it is
an open question, recorded as one in the interview file and named in
the scenario file, so the gap is visible to `architecture` and `build`
rather than silently absent.

Nothing here overrides `logic`'s per-scenario confirmation gate: the
sweep decides what to ask, the user still confirms the scenario before
it is written.

## 5. Extraction mode

The same sweep, with the code answering instead of the user. Per
dimension, either the code implements a rule - cited `file:line` - or
it does not, and "not implemented" is the finding, recorded as fact
rather than skipped. An unimplemented D10 or D16 in a brownfield
scenario is usually the most valuable line in the file: it is the
behavior the system was assumed to have.
