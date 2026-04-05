# claude-code-session-kit

**Your AI has amnesia between sessions and can't tell when it's running out of context. These hooks fix both problems.**

Claude Code resets completely between sessions — no memory of what you did, what decisions were made, or what's next. And during long sessions, context silently fills up until earlier details get compressed away, taking unsaved progress with them.

This kit provides 4 hooks and a set of templates that give Claude Code session continuity and context awareness. Developed across 92 sessions and 128 hours of real project work.

## What's inside

### [Context Lifecycle](context-lifecycle/)

Two hooks that monitor context usage and prevent silent progress loss:

| Hook | Event | What it does |
|------|-------|-------------|
| `context-monitor.sh` | PostToolUse | Three-tier context alerts at 40% / 60% / 70%. Hard stop at 70% forces handoff. |
| `pre-compact-reminder.sh` | PreCompact | Reminds AI to save state before context compression. |

### [Session Handoff](session-handoff/)

Two hooks + a template that automate session continuity:

| Hook | Event | What it does |
|------|-------|-------------|
| `session-startup.sh` | SessionStart | Auto-loads previous session state into context. |
| `handoff-check.sh` | Stop | Validates handoff document has commit hash, summary, and next steps. |
| `session-state-template.md` | — | Blank template for your session state document. |

### [CLAUDE.md Templates](claude-md-templates/)

Battle-tested `CLAUDE.md` templates for three levels:

| Template | For whom |
|----------|---------|
| `solo-beginner.md` | New to AI coding tools |
| `solo-intermediate.md` | Comfortable with AI, want session continuity |
| `multi-agent.md` | Running multi-agent hub-and-spoke systems |

## Quick Start

**Minimal install (5 minutes):**

```bash
# Clone
git clone https://github.com/shihchengwei-lab/claude-code-session-kit.git

# Copy hooks to your project
mkdir -p your-project/scripts your-project/docs
cp claude-code-session-kit/context-lifecycle/*.sh your-project/scripts/
cp claude-code-session-kit/session-handoff/*.sh your-project/scripts/
cp claude-code-session-kit/session-handoff/session-state-template.md your-project/docs/session-state.md
chmod +x your-project/scripts/*.sh

# Copy the hook config
cp claude-code-session-kit/config/settings-local-example.json your-project/.claude/settings.local.json
```

Then add session management instructions to your `CLAUDE.md`. See [full-walkthrough.md](examples/full-walkthrough.md) for step-by-step details.

**Pick and choose:** Each component works independently. You can install just the context monitor, just the session handoff, or both. See individual READMEs for standalone setup.

## Real numbers

These hooks were developed during a real project — a mobile game built from scratch by a non-engineer working with Claude Code across 92 sessions:

- **23 hours saved** — estimated time that would have been lost to manual context rebuilding (15 min × 92 sessions)
- **10+ forgotten handoffs caught** — the handoff validator flagged incomplete session-state.md files that would have caused the next session to start blind
- **3 hard stops** — the context monitor forced handoffs at 70% that would otherwise have lost in-progress work to context truncation

## How it works

```
┌─ Session Start ──────────────────────────────────┐
│  session-startup.sh loads session-state.md       │
│  → AI knows exactly where last session left off  │
└──────────────────────────────────────────────────┘
                      ↓
┌─ During Session ─────────────────────────────────┐
│  context-monitor.sh checks every 10 tool calls   │
│  → 40%: "start wrapping up"                      │
│  → 60%: "save progress now"                      │
│  → 70%: "STOP. hand off. now."                   │
└──────────────────────────────────────────────────┘
                      ↓
┌─ Context Compression ────────────────────────────┐
│  pre-compact-reminder.sh fires                   │
│  → "save state before compression wipes details" │
└──────────────────────────────────────────────────┘
                      ↓
┌─ Session End ────────────────────────────────────┐
│  handoff-check.sh validates session-state.md     │
│  → Commit hash present? Summary written?         │
│  → Next steps documented?                        │
└──────────────────────────────────────────────────┘
```

## Requirements

- Claude Code CLI
- Bash (Git Bash on Windows, native on macOS/Linux)
- Git (for commit hash validation in handoff-check.sh)

## Related

- [claude-code-creative-toolkit](https://github.com/shihchengwei-lab/claude-code-creative-toolkit) — Design integrity guards, token conservation, and non-engineering agent templates
- [cinder-capture](https://github.com/shihchengwei-lab/cinder-capture) — Capture Claude Code's companion (Cinder) speech bubbles via UIAutomation

## License

MIT
