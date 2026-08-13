#!/usr/bin/env bash
# UserPromptExpansion hook: answers /capstone:help without invoking the model.
# hooks.json's matcher targets command_name "capstone:help"; the stdin check
# below is a second guard so a broad matcher can never hijack other commands.
# Verified payload fields: hook_event_name, expansion_type, command_name,
# command_args, command_source, prompt.
# JSON encoding below is complete for any text: backslashes, quotes, CR.
INPUT="$(cat)"
if printf '%s' "$INPUT" | grep -q '"command_name":"capstone:help"'; then
  HELP="$(bash "$(dirname "$0")/help.sh" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\r' | awk '{printf "%s\\n", $0}')"
  # Fenced so markdown-rendering surfaces (VS Code extension chat) keep the
  # column alignment; terminals just show the fence lines. Empty HELP means
  # help.sh broke — pass through so the model path answers instead.
  if [ -n "$HELP" ]; then
    printf '{"decision": "block", "reason": "```\\n%s```"}' "$HELP"
  fi
fi
exit 0
