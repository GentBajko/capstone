# Install and invoke Capstone

Install Capstone in the coding agent you use to open the target repository. Take **all skills, including `core`**: the wrapper skills load shared rules and protocols from it. Installing only `map` or `feature` leaves their referenced files missing.

## Installation routes documented by this version

In Claude Code, run these in the agent:

```text
/plugin marketplace add GentBajko/capstone
/plugin install capstone@capstone-marketplace
```

With GitHub Copilot, run this in a terminal:

```sh
gh skill install GentBajko/capstone --all --agent github-copilot
```

The alternative Copilot CLI marketplace route is:

```sh
copilot plugin marketplace add GentBajko/capstone
copilot plugin install capstone@capstone-marketplace
```

For agents supported by the skills CLI, including setups that load local `SKILL.md` files:

```sh
npx skills add GentBajko/capstone
```

Select your agent and all skills in the installer. This route needs Node/npm to run `npx`; the skills themselves are plain files. The source includes a Codex plugin manifest but does not document a separate Codex-native installation command, so this manual does not invent one.

Other documented routes:

```sh
gemini extensions install https://github.com/GentBajko/capstone
agy plugin install https://github.com/GentBajko/capstone
```

For OpenCode, add this entry to the `plugin` array in your existing `opencode.json`, then restart OpenCode:

```json
{
  "plugin": ["capstone@git+https://github.com/GentBajko/capstone.git"]
}
```

These are commands shipped in the inspected Capstone version. Agent installers have their own versions and behavior; inspect their errors rather than treating a failed install as a problem with your project's documentation.

## Verify the installation

Open a repository with code and invoke:

```text
/capstone:help
```

Then use `/capstone:map`, or ask the agent to use its Capstone map skill to generate the architecture reference. The exact command-selection UI depends on the harness. Namespaced examples in this manual follow Capstone's documented invocation convention. Gemini's `GEMINI.md` imports the dispatcher, which routes arguments to the same protocols.

Arguments are positional words: `map check`, `map models`, `review be`, `stack refresh`. They are not CLI flags such as `--check`. A bare `capstone` request starts the greenfield pipeline. Use `map` explicitly for existing code.

For a bare `/capstone` shortcut in Claude Code, the README provides a custom command-file recipe. It is optional; the namespaced commands need no such alias. In `map architecture`, the topic wins: this refreshes `01-architecture.md`, whereas `/capstone:architecture` starts the design interview.

## Bash and global settings

Capstone's scripts target Bash 3.2 or later with portable shell utilities and Git where source stamps are available. Windows needs Git Bash for those scripts; PowerShell by itself does not execute them. The repository notes limited Windows field testing.

The Claude Code SessionStart hook creates the global configuration when absent. It does not map the current repository. Harnesses without that hook can run the initializer from their installed copy:

```sh
bash /absolute/path/to/capstone/skills/core/scripts/init-config.sh --global
```

Replace the installation path. For direct script use outside Claude, select the desired config directory explicitly, for example:

```sh
CAPSTONE_GLOBAL_DIR="$HOME/.codex" bash /absolute/path/to/capstone/skills/core/scripts/init-config.sh --global
```

The script resolves `CAPSTONE_GLOBAL_DIR`, then `CLAUDE_CONFIG_DIR`, then `$HOME/.claude`. It does not infer `.codex` or `.gemini` from the current agent. Use the same environment when running check scripts that should read that configuration. See [configuration](08-configuration.md).

## Update an installation

| Original installation | Update |
| --- | --- |
| Claude Code plugin | `claude plugin marketplace update capstone-marketplace`, then `claude plugin update capstone@capstone-marketplace`; restart |
| GitHub skills CLI | `gh skill update capstone` |
| Skills CLI | `npx skills update` |

The two Claude commands update different things: the marketplace checkout, then the installed plugin. The README also documents enabling marketplace auto-update from Claude Code's plugin UI. It does not provide a version-specific update command for every other harness.

Skills CLI updates can leave retired skills on disk. After a release removes a command, compare `gh skill list` or `npx skills list` with the installed Capstone help and remove retired entries using that installer's normal removal flow. An update is not evidence that old skill files were deleted.

`help` runs the bundled `help.sh`. Its no-model shortcut is specifically the Claude Code `UserPromptExpansion` hook; do not generalize that zero-token behavior to other harnesses. Help and the internal `core` help route do not create a reference or a changelog entry.

Sources: [installation and update commands](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/README.md), [hooks](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/hooks/hooks.json), [initializer](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/skills/core/scripts/init-config.sh), [OpenCode installation](https://github.com/GentBajko/capstone/blob/4210f6cab09dc5c3b742147d8714795b026e1cd9/.opencode/INSTALL.md).
