#!/bin/bash
# handoff-check.sh — Stop hook
# Validates that session-state.md is complete when a handoff is in progress.
# Only activates when session-state.md was modified in the last 60 seconds
# (i.e., the AI just wrote/updated it). Silent otherwise.
#
# Checks for: latest commit hash, session summary section, next steps section.
#
# Set SESSION_STATE_PATH to customize the file location.
# Default: docs/session-state.md
#
# Hook type: Stop
# Timeout: 10s

INPUT=$(cat)

# If we're already continuing from a previous Stop-hook block, stay silent
# to avoid an infinite block loop.
if echo "$INPUT" | grep -q '"stop_hook_active" *: *true'; then
  exit 0
fi

SESSION_STATE="${SESSION_STATE_PATH:-docs/session-state.md}"

if [ ! -f "$SESSION_STATE" ]; then
  exit 0
fi

# Check if session-state.md was modified in the last 60 seconds
if [ "$(uname -s)" = "Linux" ] || [ "$(uname -o 2>/dev/null)" = "Msys" ] || [ "$(uname -o 2>/dev/null)" = "Cygwin" ]; then
  FILE_MTIME=$(stat -c %Y "$SESSION_STATE" 2>/dev/null || stat -f %m "$SESSION_STATE" 2>/dev/null)
else
  FILE_MTIME=$(stat -f %m "$SESSION_STATE" 2>/dev/null)
fi
NOW=$(date +%s)
AGE=$(( NOW - FILE_MTIME ))

if [ "$AGE" -gt 60 ]; then
  # Not recently modified — not a handoff, stay silent
  exit 0
fi

# session-state.md was just modified — validate content
LATEST_COMMIT=$(git log -1 --format="%h" 2>/dev/null)
ERRORS=""

if [ -n "$LATEST_COMMIT" ]; then
  if ! grep -q "$LATEST_COMMIT" "$SESSION_STATE" 2>/dev/null; then
    ERRORS="${ERRORS}Warning: session-state.md does not contain the latest commit hash ($LATEST_COMMIT)\n"
  fi
fi

if ! grep -q "## Session Summary" "$SESSION_STATE" 2>/dev/null; then
  ERRORS="${ERRORS}Warning: session-state.md is missing a '## Session Summary' section\n"
fi

if ! grep -q "## Next Steps" "$SESSION_STATE" 2>/dev/null; then
  ERRORS="${ERRORS}Warning: session-state.md is missing a '## Next Steps' section\n"
fi

if [ -n "$ERRORS" ]; then
  # Stop-hook stdout with exit 0 never reaches the model.
  # decision:"block" blocks the stop and feeds reason back to Claude.
  printf '{"decision":"block","reason":"Handoff check found issues:\\n%sPlease fix these before ending the session."}\n' "$ERRORS"
fi

exit 0
