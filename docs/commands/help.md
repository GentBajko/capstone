# `help`

Arguments, outputs and ledger keys: [the command
reference](../commands.md#help).

## What it does

`help` prints the usage block: every command, its arguments, where the
output lands, and the config keys.

In Claude Code a hook answers it before the model is ever invoked, so
it costs zero tokens and returns instantly. The text comes from
`skills/core/scripts/help.sh`, which is the single source of truth for
it; every other harness runs the same script and prints its output
verbatim.

## When to reach for it

`/capstone:help`, or `capstone help` on a harness that routes through
the dispatcher. It reads nothing and writes nothing.

Reach for [`docs/commands.md`](../commands.md) when you want arguments
and outputs in full, and the page you are reading now when you want to
know which command to pick.

## Common questions

**It answered instantly and my usage did not move.** That is the hook
doing its job. The zero-token path is Claude Code only; on other
harnesses the model runs the script and echoes it, which costs a
little.

**Can I get a bare `/capstone` instead of `/capstone:help`?** Yes, by
dropping a small command file into `~/.claude/commands/capstone.md`
that routes the first argument to the matching skill. The README's
"Installing on other agents" section carries the exact file.

## It's working if

The usage block comes back listing every installed command, including
the ones added by the release you are on. A command missing from that
list is missing from your install rather than from the plugin, which
matters because updates are additive and never delete a retired skill
for you.
