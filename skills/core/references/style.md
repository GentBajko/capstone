# Writing Rules for Generated Docs

The audience is a future Claude session with zero context that must answer
architecture questions without exploring the repo.

## Voice

- Declarative facts only. "Commands are validated in `server/ws.py:88`",
  never "commands should be validated" or "consider validating".
- No recommendations, no judgments, no TODOs, no hedging ("probably",
  "seems to", "appears").
- If something could not be determined, state that explicitly:
  "Retry behavior: not implemented anywhere in `src/net/`."

## Density

- Every claim carries a pointer: `path/to/file.py:123` or `path/to/dir/`.
- Prefer a table for enumerable facts (models, endpoints, dependencies);
  prose only for relationships a table cannot show.
- No filler: delete any sentence that does not help the reader locate or
  understand code. No introductions, no summaries of summaries.
- The index (`<index_file>`) stays under ~2 pages. Topic files have no
  hard cap but must earn their length: if a section repeats the index,
  cut it.
- `changelog.md` is exempt from every length rule: it is never
  condensed, summarized, or pruned.

## Naming

- Use the codebase's own names verbatim (`GenerateMapCommand`, not "the
  map generation command object").
- First mention of a symbol gives its definition site; later mentions do
  not repeat it.

## Structure

- Follow the required section templates in `topics.md` exactly: future
  sessions rely on stable headings to jump to what they need.
- Absent things are facts too: record them where a reader would look
  ("No message queue; all communication is synchronous websocket frames").
- Label shallow coverage: when an area was only skimmed, say so
  ("shallow: static assets, not inventoried") so readers can distinguish
  small-and-boring from not-examined.
