# Autonomous Agent Workflow for Claude Code

A project-independent, multi-agent engineering workflow that turns a single objective into researched, architected, planned, implemented, and verified code — autonomously.

## What is this?

This is a template repository containing a full autonomous engineering "organization" built on Claude Code's agent system. When you run `/dev-team`, it launches a pipeline of 20+ specialized AI agents organized into 6 teams:

```
   OBJECTIVE
       │
       ▼
  ┌─────────────────────────────────────────────────────┐
  │                  ORCHESTRATOR                       │
  │  Drives the pipeline, enforces gates, handles       │
  │  failures, manages state                            │
  └─┬───────────┬───────────┬───────────┬───────────┬───┘
    │           │           │           │           │
    ▼           ▼           ▼           ▼           ▼
 RESEARCH → ARCHITECTURE → PLANNING → IMPLEMENT → VERIFY → RELEASE
  5 agents    5 agents     1 agent     4 agents    5 agents  2 agents
```

Each phase has a **hard gate** — it must pass before the next starts. Failed verifications trigger fix rounds (max 3), then architectural replanning (max 2), then escalation to you.

## Installation

### For a new project

```bash
# Option 1: Use as GitHub template
# Click "Use this template" on GitHub, then start coding

# Option 2: Clone and copy
git clone https://github.com/YOUR_USERNAME/automate-agents.git
cd automate-agents
./install.sh /path/to/your/new/project
```

### For an existing project

```bash
# From this template's directory:
./install.sh /path/to/your/existing/project

# On Windows (PowerShell):
.\install.ps1 -Target C:\path\to\your\existing\project
```

The installer copies agent definitions and creates the project memory structure without touching your existing code. It will NOT overwrite existing files.

### What gets installed

```
your-project/
├── .claude/
│   ├── commands/
│   │   └── dev-team.md          ← the /dev-team entry point
│   └── agents/
│       ├── project-orchestrator.md
│       ├── common-agent-contract.md
│       ├── research-lead.md
│       ├── repo-researcher.md
│       ├── domain-researcher.md
│       ├── dependency-researcher.md
│       ├── benchmark-researcher.md
│       ├── risk-researcher.md
│       ├── chief-architect.md
│       ├── system-designer.md
│       ├── reliability-reviewer.md
│       ├── security-reviewer.md
│       ├── data-architect.md
│       ├── integration-architect.md
│       ├── technical-planner.md
│       ├── implementation-lead.md
│       ├── implementation-engineer.md
│       ├── backend-engineer.md
│       ├── frontend-engineer.md
│       ├── test-engineer.md
│       ├── verification-lead.md
│       ├── functional-tester.md
│       ├── regression-tester.md
│       ├── performance-tester.md
│       ├── security-tester.md
│       ├── evaluator.md
│       ├── release-engineer.md
│       └── knowledge-curator.md
├── project_memory/
│   ├── active_objective.md      ← write your goal here
│   ├── module_status.md         ← auto-updated after runs
│   ├── architecture/
│   ├── adrs/
│   ├── contracts/
│   ├── schemas/
│   └── known_issues/
├── checkpoints/                 ← auto-generated run history
└── CLAUDE.md                    ← project config
```

## Usage

### Quick start

```bash
# Open your project in Claude Code, then:
/dev-team Build a REST API for managing bookmarks with user auth

# Or set the objective first:
# Edit project_memory/active_objective.md, then:
/dev-team
```

### What happens

1. **Research** — agents analyze your codebase (if existing), domain, dependencies, and risks
2. **Architecture** — agents design the solution, write ADRs, define API contracts
3. **Planning** — the planner converts architecture into an ordered task graph
4. **Implementation** — engineer agents write the actual code, task by task
5. **Verification** — independent testers verify everything works (tests, security, quality)
6. **Release** — creates a checkpoint, updates project memory, suggests commit message

If verification fails, the system automatically:
- Tries fix rounds (up to 3)
- Falls back to architectural replanning (up to 2)
- Escalates to you if it's still stuck

### For new projects

Just create an empty directory and install:

```bash
mkdir my-new-app && cd my-new-app
git init
/path/to/automate-agents/install.sh .
# Then in Claude Code:
/dev-team Build a full-stack todo app with React, Express, and PostgreSQL
```

The agents will scaffold everything from scratch — project structure, configs, dependencies, code, and tests.

### For existing projects

Install into your project and run:

```bash
cd /path/to/my-existing-project
/path/to/automate-agents/install.sh .
# Then in Claude Code:
/dev-team Add rate limiting to all API endpoints
```

The research phase will analyze your existing codebase and conventions before designing changes.

## Customization

### Adding project-specific skills

Create `.claude/skills/` files for patterns specific to your project:

```markdown
<!-- .claude/skills/api-patterns.md -->
When creating API endpoints in this project:
- Use Express router with /api/v1 prefix
- Validate with zod schemas
- Return { data, error, meta } envelope
- Auth middleware on all routes except /health
```

### Modifying agent behavior

Each agent in `.claude/agents/` is a markdown file with a YAML frontmatter. You can:
- Change the `model` (opus for critical thinking, sonnet for speed)
- Adjust available `tools`
- Modify the agent's instructions

### Skipping phases

For small changes, you may not need the full pipeline. The orchestrator reads the objective — if it's a simple bug fix, it can compress the research and architecture phases.

## Architecture

### State machine

```
ORIENTING → RESEARCHING → ARCHITECTING → PLANNING → IMPLEMENTING → VERIFYING
                                                                        │
                                                     ┌──────────────────┤
                                                     ▼                  ▼
                                                  FIXING            RELEASING
                                                     │                  │
                                                (max 3 rounds)     COMPLETE
                                                     │
                                              REPLANNING (→ back to ARCHITECTING)
                                                     │
                                                (max 2 replans)
                                                     │
                                            BLOCKED / ESCALATED
```

### Failure classification

| Class | Action | Example |
|-------|--------|---------|
| TRANSIENT | Retry same phase (max 2) | Network timeout, flaky test |
| RECOVERABLE | Fix round (max 3) | Wrong approach, missing edge case |
| BLOCKING | Replan from architecture (max 2) | Fundamental design problem |
| FATAL | Stop, report to user | Impossible constraint, security violation |

### Persistent state

Every run creates `checkpoints/run/<run_id>/` with:
- `state.json` — current phase, fix/replan counts, status
- Phase artifacts (research.md, architecture.md, etc.)
- ADRs, contracts, schemas
- Test results, reviews

If a session crashes, a new `/dev-team` invocation can resume from the last checkpoint.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI, desktop app, or VS Code extension)
- A Claude API key with access to Opus and Sonnet models

## License

MIT
