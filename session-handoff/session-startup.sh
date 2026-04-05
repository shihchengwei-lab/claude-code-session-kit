#!/usr/bin/env bash
# session-startup.sh — SessionStart hook
# Automatically loads the previous session's state into context,
# so the AI picks up exactly where it left off.
#
# Set SESSION_STATE_PATH to customize the file location.
# Default: docs/session-state.md
#
# Hook type: SessionStart (matcher: "startup")
# Timeout: 10s

SESSION_STATE="${SESSION_STATE_PATH:-docs/session-state.md}"

if [ -f "$SESSION_STATE" ]; then
  CONTENT=$(cat "$SESSION_STATE")
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "decision": {
      "additionalContext": "Previous session state loaded automatically:\\n$CONTENT"
    }
  }
}
EOF
fi

exit 0
