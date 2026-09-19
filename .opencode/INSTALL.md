# Installing Capstone for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add capstone to the `plugin` array in your `opencode.json` (global or
project-level):

```json
{
  "plugin": ["capstone@git+https://github.com/GentBajko/capstone.git"]
}
```

Restart OpenCode. The plugin registers all nine capstone skills (map,
doctor, review, groom, plan, implement,
feature, start, help). The pipeline stages (mockup, logic, uiux,
architecture, standards, stack, build) are not skills of their own -
reach each one as `start <stage>` - and neither is the session review
(retro), which is `review retro`.

Verify by asking: "Generate the architecture reference for this codebase."
