# Capstone dispatcher - one entry point, many protocols

Read by harnesses whose entry point is a single context file
(GEMINI.md imports this file). Claude-family harnesses route via the
individual wrapper skills instead; both paths land on the same
protocol files.

1. Read `core.md` (same directory) first: hard rules, voice, and
   user config. Then `core-authoring.md`, unless the route below lands
   on `start` or `feature`, which route rather than write.
2. Route on the first argument. The reserved subcommand words
   (`map`, `doctor`, `review`, `mockup`,
   `logic`, `uiux`, `architecture`, `standards`, `stack`, `build`,
   `groom`, `plan`, `implement`, `feature`, `start`)
   each route to `protocols/<name>.md`: execute that one protocol
   exactly; behaviors live there, not here.
3. Exception: when invoked as `map`, topic names win over
   subcommand words: `map architecture` regenerates
   `01-architecture.md` and never starts the architecture interview.
4. `help`: run `../scripts/help.sh` via bash and output its stdout
   verbatim; nothing else.
5. No argument at all → `protocols/start.md`, the bare-"capstone"
   entry.
