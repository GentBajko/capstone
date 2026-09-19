# Capstone dispatcher - one entry point, many protocols

Read by harnesses whose entry point is a single context file
(GEMINI.md imports this file). Claude-family harnesses route via the
individual wrapper skills instead; both paths land on the same
protocol files.

1. Read `core.md` (same directory) first: hard rules, voice, and
   user config. Then `core-authoring.md`, unless the route below lands
   on `start` or `feature`, which route rather than write.
2. Route on the first argument. Nine command words are the whole
   surface: `map`, `doctor`, `review`, `groom`, `plan`, `implement`,
   `feature`, `start`, `help`. Every other protocol is a stage one of
   them runs, reached as that command's second word.
   The reserved subcommand words - the commands
   `map`, `doctor`, `review`,
   `groom`, `plan`, `implement`, `feature`, `start`, under
   `start` the stage words `mockup`,
   `logic`, `uiux`, `architecture`, `standards`, `stack`, `build`,
   and under `review` the word `retro` -
   each route to `protocols/<name>.md`: execute that one protocol
   exactly; behaviors live there, not here.
3. A subcommand word is reachable only after its command: `start
   mockup` runs `protocols/mockup.md` and `review retro` runs
   `protocols/retro.md`, while a bare `mockup` or `retro` is not a
   command and routes to `start` like any other unrecognized argument.
   `retro` is the one subcommand that is not a stage: it reads a
   finished session rather than the code, and it sits under `review`
   because a session ends under every command, not just the pipeline.
4. Exception: when invoked as `map`, topic names win over
   stage words: `map architecture` regenerates
   `01-architecture.md` and never starts the architecture interview.
   `start architecture` is the interview.
5. `help`: run `../scripts/help.sh` via bash and output its stdout
   verbatim; nothing else.
6. No argument at all → `protocols/start.md`, the bare-"capstone"
   entry.
