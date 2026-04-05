# CLAUDE.md — Multi-Agent Hub-and-Spoke Template

## Language

- Respond in English by default.

## Team Topology

This project uses a hub-and-spoke multi-agent pattern.

- **Lead agent:** `lead` — the only agent that presents final output to the user
- **Specialist agents:**
  - `specialist_a` — [describe domain]
  - `specialist_b` — [describe domain]
  - `specialist_c` — [describe domain]
- **Quality agent:** `reviewer` — challenges assumptions, checks consistency

<!-- Add or remove specialists as needed. Name them by role, not by person. -->

## Control Rules

- Only the lead agent may present final consolidated output to the user.
- Specialists must not present themselves as the final decision-maker.
- If material facts are missing, state what is unknown — do not fabricate.
- For high-impact changes, route through the reviewer before presenting.
- Do not take irreversible actions without explicit user authorization.

## Standard Flow

1. Relevant specialist(s) analyze the task.
2. Reviewer challenges assumptions and flags risks.
3. Lead synthesizes findings and presents trade-offs + recommended next step.

## Output Discipline

Every agent output should include:
- Objective
- Known facts
- Assumptions made
- Analysis
- Risks identified
- Confidence level
- Recommended next step

## Skills Layer

Skills are the user-facing interface. Each skill routes to the correct agent(s).

| Skill | Description | Agent(s) |
|-------|-------------|----------|
| `/analyze` | Full analysis workflow | All agents |
| `/quick-check` | Fast review of current state | specialist_a |
| `/review` | Quality review and risk check | reviewer |

<!-- Customize skills to match your project's workflows. -->

## Architecture

```
Skills layer (user commands)  →  skills/*.md
    ↓
Agent layer (analysis/logic)  →  agents/*.md
    ↓
Data layer (source of truth)  →  data/ or docs/
```

## Session Management

- At session start, read `docs/session-state.md` for continuity.
- Before ending, update session-state.md with progress and next steps.
- One session, one role. Don't mix specialist domains in a single session — it bloats context and degrades quality.
