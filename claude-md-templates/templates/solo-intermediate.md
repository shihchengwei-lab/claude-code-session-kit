# CLAUDE.md — Solo Intermediate Template

## Language

- Respond in English by default.

## Rules

- Read files before modifying them.
- Run tests after every change.
- Do not refactor or add features unless asked.
- Keep responses concise — skip preamble, lead with the action.

## Session Management

- At session start, read `docs/session-state.md` for context from the previous session.
- Before ending a session, update `docs/session-state.md` with:
  - What was completed (with commit hashes)
  - Current status (tests passing, build status)
  - Prioritized next steps
- session-state.md is the memory bridge across sessions — treat it as the single source of continuity.

## Context Awareness

- When context gets large, proactively summarize progress and suggest a handoff.
- If the context monitor fires a warning, prioritize wrapping up over starting new work.
- After context compression, re-read session-state.md to recover key details.

## About Me

- I can read code and error messages but prefer not to debug alone.
- I make the product decisions; you handle the implementation.
- When I describe something vaguely, ask one clarifying question before proceeding.
