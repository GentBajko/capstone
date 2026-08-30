---
name: help
description: Use when asked what the capstone plugin can do - prints the usage block.
---

# Capstone: help

Run exactly one tool call and nothing else, from this skill's base
directory:

```sh
bash <base>/../core/scripts/help.sh
```

Bash on every platform; on Windows that means Git Bash, which ships
with Git for Windows.

The script's stdout IS the help. Do not restate, summarize, or add any
text; if the harness requires a reply, output the script's stdout
verbatim and stop.
