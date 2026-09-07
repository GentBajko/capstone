# `doctor`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#doctor).

## What it does

`doctor` checks the docs area against itself and offers to fix what it
finds: a done marker with no ledger entry, a ledger key whose outputs
are missing, an index row pointing at a file that is not there, a plan
approval voided by an edited spec, a feature folder left behind after
its entry landed.

Every repair `doctor` performs is a rule some other protocol already
defines. It centralizes them; the owning protocol stays the source of
truth. Beyond those documented rules it proposes and never applies: it
will not invent a fix, and a finding it cannot repair by an existing
rule is reported as one rather than tidied away.

## When to reach for it

`/capstone:doctor` after a session that died mid-write, after a merge
that touched the docs area from two branches, or when a command
complains that state disagrees with disk. `doctor fix` pre-approves
the documented crash rules and still asks about everything else.

Reach for `map check` instead when the question is whether the
reference is still true about the code. `doctor` is about the docs
area's internal consistency: `map check` compares docs to code,
`doctor` compares docs to docs. They overlap on the schema pass,
which both run.

## What a finding looks like

Findings are grouped into two piles. Auto-repairable means a
documented crash rule covers it exactly, so `fix` may apply it without
asking again. Needs-confirmation means a person has to rule.

Each row names the check, the finding, the owning rule, and the
proposed repair. Some findings are reported unrecoverable rather than
repaired: an absorption gap whose `spec.md` was already deleted, or a
final output missing content that only an unavailable interview held.
`doctor` states the omission and never guesses at it.

## Common questions

**Does `doctor fix` apply everything it found?** No. It pre-approves
the documented crash rules only. Anything that needs a decision still
stops and asks.

**It reported unfolded `changelog.d/` fragments on my feature
branch.** That is the designed state, not a fault. Fragments fold only
on the repository's default branch, because folding on a side branch
puts two branches' entries back at the same insert offset, which is
the conflict fragments exist to remove.

**It says my ledger is untracked, loudly.** Deliberately.
`changelog.md`, its rotation files and `changelog.d/` are always
committed whatever `docs_in_git` says. `implement` deletes a feature's
folder on the strength of its ledger entry, so an untracked ledger is
one machine change away from losing why every shipped feature was
built that way.

**It wants to move `expertise` out of my project config.** Those two
keys are personal. `expertise` and `teaching_mode` live in the global
`capstone.json` and are ignored wherever else they sit, so a copy in
the project file only misleads the next reader.

## It's working if

The findings table comes back empty, or the repairs you approved are
on disk and re-running the affected checks reports them clear. A run
that repaired something leaves one `doctor/<scope>@<stamp>` entry in
the ledger naming each repair and its owning rule; a clean run leaves
nothing at all and says so.
