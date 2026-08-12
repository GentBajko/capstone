# onboarding — reading path

Output: `docs/design/onboarding.md`, frontmatter stamps. A guided tour
for a new contributor, ordered: each stop names the file or doc to read,
why now, and 1–3 things to notice there. Start at DESIGN.md; route
through the code's load-bearing files (entry point, dispatch, one
representative handler, the persistence seam); end by pointing at the
how-to guides and the test suite's conventions. ~10 stops maximum;
narrative voice allowed; every stop cites its target.

Before overwriting an existing `onboarding.md`, read its stamp and
append a catch-up changelog entry if none carries it. After writing,
append this run's entry per core.md's ledger — key
`onboarding/all@<stamp>`; record the stamp, the number of stops, and the
ordered targets the tour routes through. Then add or refresh the
Companion docs row.
