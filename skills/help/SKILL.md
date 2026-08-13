---
name: help
description: Use when asked what the capstone plugin can do - prints the usage block.
---

# Capstone: help

Run exactly one tool call and nothing else — the platform-appropriate
variant (both live in `../core/scripts/` relative to this skill's
base directory):

```
bash <base>/../core/scripts/help.sh                                  # macOS/Linux/Git Bash
powershell -ExecutionPolicy Bypass -File <base>\..\core\scripts\help.ps1  # Windows
```

The script's stdout IS the help. Do not restate, summarize, or add any
text; if the harness requires a reply, output the script's stdout
verbatim and stop.
