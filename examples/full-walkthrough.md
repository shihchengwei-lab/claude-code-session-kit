# Full Setup Walkthrough

From zero to a fully managed Claude Code project in 10 minutes.

## Prerequisites

- Claude Code CLI installed and working
- A project directory with git initialized
- Bash available (Git Bash on Windows, native on macOS/Linux)

## Step 1: Create the scripts directory

```bash
mkdir -p scripts docs
```

## Step 2: Copy the hook scripts

Copy all four scripts into your project's `scripts/` folder:

```bash
# From the session-kit repo:
cp context-lifecycle/context-monitor.sh    your-project/scripts/
cp context-lifecycle/pre-compact-reminder.sh your-project/scripts/
cp session-handoff/session-startup.sh      your-project/scripts/
cp session-handoff/handoff-check.sh        your-project/scripts/
```

Make them executable:

```bash
chmod +x scripts/*.sh
```

## Step 3: Create your session-state.md

Copy the template into your docs folder:

```bash
cp session-handoff/session-state-template.md your-project/docs/session-state.md
```

Fill in the initial state — at minimum:
- Branch name
- Test baseline (0/0 if no tests yet)
- One sentence describing what the project is

## Step 4: Configure hooks

Create `.claude/settings.local.json` in your project root:

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

## Step 5: Add session management instructions to CLAUDE.md

Add these lines to your project's `CLAUDE.md`:

```markdown
## Session Management

- At session start, read `docs/session-state.md` for context from the previous session.
- Before ending a session, update `docs/session-state.md` with:
  - What was completed (with commit hashes)
  - Current status (tests, build)
  - Prioritized next steps
- session-state.md is the memory bridge — treat it as the single source of continuity.
```

## Step 6: Test it

1. **Start a new Claude Code session** in your project directory. You should see the session state loaded automatically.

2. **Work normally.** The context monitor runs silently in the background. You won't see anything until you hit 40%.

3. **End the session** by asking Claude to update session-state.md and wrap up. The handoff check will validate the document has the required sections and latest commit hash.

4. **Start a new session.** Claude should immediately know where you left off.

## Minimal Install

Don't want everything? Pick what you need:

**Context monitoring only:**
- Copy `context-monitor.sh` and `pre-compact-reminder.sh`
- Add the `PostToolUse` and `PreCompact` hooks to settings.local.json

**Session handoff only:**
- Copy `session-startup.sh`, `handoff-check.sh`, and the session-state template
- Add the `SessionStart` and `Stop` hooks to settings.local.json
- Add the session management instructions to CLAUDE.md

## Customization

**Change session-state.md location:**

Set the `SESSION_STATE_PATH` environment variable:

```json
{
  "type": "command",
  "command": "SESSION_STATE_PATH=my-docs/state.md bash scripts/session-startup.sh",
  "timeout": 10
}
```

**Adjust context thresholds:**

Edit `context-monitor.sh` lines 38-40:
```bash
WARN_THRESHOLD=400000    # 40% — early warning
ALERT_THRESHOLD=600000   # 60% — wrap up soon
STOP_THRESHOLD=700000    # 70% — hard stop, must hand off
```

**Change handoff validation sections:**

Edit `handoff-check.sh` to match your preferred section headers:
```bash
grep -q "## Session Summary"   # change to your header
grep -q "## Next Steps"        # change to your header
```
