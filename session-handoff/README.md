# Session Handoff

Claude Code has no memory between sessions. Every new conversation is a complete reset. If your last session ended mid-task, the AI has no idea what you were doing, what decisions were made, or what's next.

The cost: across 92 sessions, rebuilding context manually would have wasted ~23 hours (15 minutes per session). Worse, verbal rebuilding is error-prone — the AI might redo work, contradict earlier decisions, or lose track of what's been tested.

These hooks automate the handoff:

## session-startup.sh (SessionStart)

Automatically loads `docs/session-state.md` into context when a new session starts. The AI picks up exactly where it left off — no "read the last handoff document" needed.

## handoff-check.sh (Stop)

Validates `session-state.md` when the AI updates it during a handoff. Checks for:

- **Latest commit hash** — so the next session knows the exact code state
- **Session Summary section** — what was accomplished
- **Next Steps section** — what to do next

Only activates when `session-state.md` was modified in the last 60 seconds (i.e., a handoff is in progress). Silent otherwise.

## session-state-template.md

A blank template with the standard structure:

- **Current Status** — branch, commit, test baseline, build status
- **Session Summary** — what was done (be specific, future-you needs this)
- **Next Steps** — prioritized, one per line
- **Blocked** — what can't proceed and why
- **References** — pointers to relevant docs/files

See `examples/session-state-example.md` for a filled-in example from a real project.

## Setup

1. Copy scripts to your project's `scripts/` folder
2. Copy the template to `docs/session-state.md`
3. Add hooks to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/session-startup.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/handoff-check.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

4. Add session management instructions to your `CLAUDE.md` (see the walkthrough).

## Custom path

Set `SESSION_STATE_PATH` to use a different file location:

```bash
SESSION_STATE_PATH=my-docs/state.md bash scripts/session-startup.sh
```

Both scripts respect this variable.
