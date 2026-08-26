# ask <question> - cited Q&A

**Reads:** config → `<index_file>` (the question's topic rows) → the
touched topic chapters (after step 2's staleness pass) → source only
to spot-check cited pointers.

1. From the DESIGN.md index, pick the topics the question touches.
2. Run `sync check`'s staleness test on just those topics; refresh any
   that are stale before answering. That refresh is `sync`'s write and
   is recorded by `sync`; `ask` never appends a changelog
   entry.
3. Answer from the docs, citing the doc sections and the `file:line`
   pointers they carry. Spot-check pointers you rely on.
4. Config `workspaces` set → the root index routes to each
   workspace's own index; pick topics across all workspaces the
   question touches.
5. If the docs cannot answer, say so explicitly, answer from targeted
   code reading instead, and name which topic file should have covered
   it: that gap is a template bug worth reporting to the user.
