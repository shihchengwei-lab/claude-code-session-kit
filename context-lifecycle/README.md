# Context Lifecycle

Claude Code doesn't know how much context it has used. When the window fills up, earlier conversation details get silently compressed or truncated — and any unsaved progress goes with them.

These two hooks add awareness:

## context-monitor.sh (PostToolUse)

Checks transcript size every 10 tool calls (near-zero overhead) and injects warnings at three thresholds:

| Threshold | Level | What happens |
|-----------|-------|-------------|
| 40% (~400KB) | Warning | "Start thinking about wrap-up" |
| 60% (~600KB) | Alert | "Update session-state.md now, finish current task" |
| 70% (~700KB) | **Hard stop** | "Update session-state.md, stop work, tell user to start new session" |

The 70% gate is non-negotiable. Without it, the AI will happily keep working until context truncates and progress is silently lost.

## pre-compact-reminder.sh (PreCompact)

Fires when Claude Code is about to compress context. Shows the user a reminder to make sure critical state is saved to `session-state.md` before compression wipes early conversation details. (PreCompact can't inject context into the model, so the reminder targets the user — the one channel this event actually supports.)

## Setup

Add to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/context-monitor.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/pre-compact-reminder.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## How thresholds were calibrated

The 400/600/700KB base thresholds are based on observed transcript sizes across dozens of sessions, calibrated for a ~200k-token context window. They're conservative — you'll get warnings before things get critical.

Two caveats worth knowing:

- **Larger context windows**: set `WINDOW_SCALE` in `context-monitor.sh` to match your model (e.g. `5` for a 1M-token window). Left at `1`, the hard gate fires while real usage is still low — observed in practice: ~18% actual usage flagged as "over 70%" on a 1M-window session.
- **Compaction**: the transcript file never shrinks — `/compact` frees the model's context but keeps appending to the same file. `pre-compact-reminder.sh` records the file size at each compaction and `context-monitor.sh` subtracts it, so alerts measure growth since the last compaction instead of firing forever once the raw file passes a threshold. This only works if both hooks are installed.
