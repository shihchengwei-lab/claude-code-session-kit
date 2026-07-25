#!/usr/bin/env bash
# pre-compact-reminder.sh — PreCompact hook
# Fires when context is about to be compressed.
#
# PreCompact does not deliver hookSpecificOutput.additionalContext to the
# model, so this uses top-level systemMessage instead: the reminder is shown
# to the USER, who can confirm session-state.md is current before compression.
#
# Hook type: PreCompact (matcher: "")
# Timeout: 5s

INPUT=$(cat)

# Record the transcript size at compaction time as a baseline.
# The transcript file only ever grows — /compact frees the model's context
# but never shrinks the file. context-monitor.sh subtracts this baseline so
# its alerts measure growth since the last compaction instead of firing
# forever once the raw file passes a threshold.
TRANSCRIPT=$(echo "$INPUT" | sed -n 's/.*"transcript_path" *: *"\([^"]*\)".*/\1/p' | head -1 | tr '\\\\' '/' 2>/dev/null)
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  wc -c < "$TRANSCRIPT" > "/tmp/claude-context-baseline-$(basename "$TRANSCRIPT" .jsonl)" 2>/dev/null
fi

cat <<'EOF'
{"systemMessage":"Context is about to be compacted. Before it happens, check:\n1. Important decisions and progress are written to session-state.md\n2. Unpushed commits are recorded\n3. Next steps are documented\nAfter compaction, early conversation details are lost — session-state.md is the memory bridge."}
EOF

exit 0
