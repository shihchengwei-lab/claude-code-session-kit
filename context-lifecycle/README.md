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

Fires when Claude Code is about to compress context. Reminds the AI to save critical state to `session-state.md` before compression wipes early conversation details.

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

The 400/600/700KB thresholds are based on observed transcript sizes across dozens of sessions. They're conservative — you'll get warnings before things get critical. If you're using a model with a larger context window, you may want to raise them.
