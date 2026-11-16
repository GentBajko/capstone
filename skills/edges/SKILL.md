---
name: edges
description: Use when several repos of one system are cloned side by side and their capstone docs should say which repo each consumed contract comes from - "connect the repos", "fill in the interfaces", "which service does this call go to", "wire the edges up for quarry" - reads every mapped repo in the folder once and writes the missing from in each consumer's 09-interfaces.md, with the evidence in each repo's ledger. Run it from the folder that holds the clones, after map has run in each; it asks nothing, never writes a producer's to, and never changes a far end already answered.
---

# Capstone: edges

From this skill's base directory, read `../core/references/core.md`
and `../core/references/core-authoring.md`, then execute
`../core/references/protocols/edges.md`
exactly.
