#!/usr/bin/env bash
# context-monitor.sh — PostToolUse hook
# Periodically checks transcript size and injects context warnings.
# Three-tier alert system: 40% (warn) → 60% (alert) → 70% (hard stop).
#
# The 70% hard gate forces a session handoff — no exceptions.
# Thresholds calibrated from transcript sizes observed across dozens of sessions.
#
# Hook type: PostToolUse (matcher: ".*")
# Timeout: 5s

INPUT=$(cat)

# Session-level counter file
COUNTER_FILE="/tmp/claude-context-monitor-counter"
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Only check every 10 calls (skip the first 3, then every 10th)
# This keeps overhead near zero — most tool calls exit immediately.
if [ "$COUNT" -lt 3 ] || [ $((COUNT % 10)) -ne 0 ]; then
  exit 0
fi

TRANSCRIPT=$(echo "$INPUT" | sed -n 's/.*"transcript_path" *: *"\([^"]*\)".*/\1/p' | head -1 | tr '\\\\' '/' 2>/dev/null)

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Get file size in bytes
SIZE=$(wc -c < "$TRANSCRIPT" 2>/dev/null || echo 0)

# The transcript file never shrinks — /compact frees the model's context but
# keeps appending to the same file. Subtract the baseline recorded by
# pre-compact-reminder.sh at the last compaction so we measure growth since
# then. Without this, alerts fire forever once the raw file passes a
# threshold, even right after a compaction. No baseline file (no compaction
# yet this session) means the full size is used, which is correct.
BASELINE_FILE="/tmp/claude-context-baseline-$(basename "$TRANSCRIPT" .jsonl)"
BASELINE=$(cat "$BASELINE_FILE" 2>/dev/null || echo 0)
case "$BASELINE" in
  ''|*[!0-9]*) BASELINE=0 ;;
esac
if [ "$BASELINE" -gt 0 ] && [ "$SIZE" -gt "$BASELINE" ]; then
  SIZE=$((SIZE - BASELINE))
fi

# Thresholds (rough estimates based on observed context usage):
#   400KB ≈ 40% of context window
#   600KB ≈ 60% of context window
#   700KB ≈ 70% of context window
# Base values are calibrated for a ~200k-token context window.
# IMPORTANT: set WINDOW_SCALE to match your model — e.g. 5 for a 1M-token
# window. Left at 1 on a large-window session, the hard gate fires while
# actual usage is still low (observed: ~18% real usage flagged as "over 70%").
# Also note: this measures transcript file size, not real token usage —
# /compact frees the model's context but the transcript file never shrinks,
# so alerts do not reset after compaction.
WINDOW_SCALE=1
WARN_THRESHOLD=$((400000 * WINDOW_SCALE))
ALERT_THRESHOLD=$((600000 * WINDOW_SCALE))
STOP_THRESHOLD=$((700000 * WINDOW_SCALE))

# additionalContext must sit directly under hookSpecificOutput —
# any other nesting is silently ignored by the schema.
if [ "$SIZE" -gt "$STOP_THRESHOLD" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "HARD STOP — Context exceeds 70%. You MUST do the following immediately. Do NOT continue any other work:\n1. Update session-state.md with current progress, decisions made, and next steps\n2. Stop all generation/development work\n3. Tell the user: 'Context is full. I recommend starting a new session. session-state.md has been updated.'\n\nThis is a hard gate. Continuing past this point risks losing work to context truncation."
  }
}
EOF
elif [ "$SIZE" -gt "$ALERT_THRESHOLD" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Context is past 60%. Update session-state.md now to preserve progress. Finish your current task, then hand off. Do not start new tasks."
  }
}
EOF
elif [ "$SIZE" -gt "$WARN_THRESHOLD" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Context is past 40%. Start thinking about wrap-up timing. Finish your current task and consider whether to hand off soon."
  }
}
EOF
fi

exit 0
