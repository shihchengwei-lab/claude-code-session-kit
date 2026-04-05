# CLAUDE.md Templates

`CLAUDE.md` is the instruction file Claude Code reads at the start of every session. It's the most powerful configuration you have — but most people either skip it or write one that's too vague to be useful.

These templates are extracted from real projects (dozens of sessions across game development, financial analysis, and multi-agent systems). They're opinionated and practical.

## Which template to use

| Template | You are... | Sessions so far |
|----------|-----------|-----------------|
| **solo-beginner** | New to AI coding tools. Want guardrails. | 0-10 |
| **solo-intermediate** | Comfortable with AI. Want session continuity. | 10+ |
| **multi-agent** | Running multiple specialist agents. Need coordination. | 20+ |

## How to use

1. Pick a template from `templates/`
2. Copy it to your project root as `CLAUDE.md`
3. Customize: change language, add your project's specific rules, describe yourself
4. Iterate: add rules when you notice the AI repeating mistakes

## Key principles

These templates follow three principles learned the hard way:

1. **Rules, not wishes.** "Be concise" is a wish. "Keep responses under 3 sentences unless I ask for detail" is a rule.

2. **Tell the AI about yourself.** "I'm a PM with no coding background" changes how the AI explains things, what it assumes, and when it asks for help.

3. **Session management instructions belong here.** If you're using the session-handoff hooks, add the reading/writing instructions to CLAUDE.md so the AI knows what to do with session-state.md.
