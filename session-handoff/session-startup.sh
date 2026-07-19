#!/usr/bin/env bash
# session-startup.sh — SessionStart hook
# Automatically loads the previous session's state into context,
# so the AI picks up exactly where it left off.
#
# SessionStart adds plain stdout to context directly, so no JSON envelope is
# needed — this also avoids escaping issues with arbitrary file content.
#
# Set SESSION_STATE_PATH to customize the file location.
# Default: docs/session-state.md
#
# Hook type: SessionStart (matcher: "startup")
# Timeout: 10s

SESSION_STATE="${SESSION_STATE_PATH:-docs/session-state.md}"

if [ -f "$SESSION_STATE" ]; then
  echo "Previous session state (auto-loaded from $SESSION_STATE):"
  echo ""
  cat "$SESSION_STATE"
fi

exit 0
