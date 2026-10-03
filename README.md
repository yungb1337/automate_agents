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

## Quick Start & How to Use

### Option 1: Download ZIP from GitHub (easiest)

1. Go to the [GitHub repo](https://github.com/yungb1337/automate_agents) and click **Code → Download ZIP**
2. Extract the zip anywhere on your machine — this is the **template** (the thing you downloaded)
3. Open a terminal and run the installer, pointing it at your **target project** (the project you want to add the workflow to):

```bash
# Linux/macOS/Git Bash:
bash <path-to-template>/install.sh <path-to-your-project>

# Windows PowerShell:
<path-to-template>\install.ps1 -Target <path-to-your-project>
```

**Example** — template extracted to `C:\Users\You\automate_agents`, installing into `C:\Users\You\projects\my-app`:

```powershell
# PowerShell
C:\Users\You\automate_agents\install.ps1 -Target "C:\Users\You\projects\my-app"
```
```bash
# Git Bash
bash /c/Users/You/automate_agents/install.sh /c/Users/You/projects/my-app
```

4. Open your project in Claude Code and run `/dev-team` — that's it.

**What the installer does:** copies `.claude/agents/`, `.claude/commands/`, and `project_memory/` templates into your project. It **skips** any files that already exist (won't overwrite your `CLAUDE.md`, existing `project_memory/`, etc.) and appends the workflow entries to your `.gitignore`. It never touches your existing code.

---

### Option 2: Clone & install into a new project

```bash
# 1. Create your new project
mkdir my-new-app && cd my-new-app
git init

# 2. Clone the template somewhere (one-time)
git clone https://github.com/yungb1337/automate_agents.git ~/automate_agents

# 3. Run the installer pointing at your new project
# Linux/macOS/Git Bash:
bash ~/automate_agents/install.sh .

# Windows PowerShell:
~\automate_agents\install.ps1 -Target .

# 4. Open in Claude Code (terminal, VS Code, or desktop app)
claude .

# 5. Run the workflow — either pass the objective inline:
/dev-team Build a REST API with user auth using FastAPI and PostgreSQL

# Or edit the objective file first, then run:
#   Edit project_memory/active_objective.md with your goal
#   Then: /dev-team
```

That's it. The agents will scaffold the entire project — structure, configs, dependencies, code, and tests.

---

### Option 3: Install into an existing/mature project

```bash
# 1. cd into your existing project
cd ~/projects/my-existing-app

# 2. Run the installer (assumes you cloned or downloaded the template already)
# Linux/macOS/Git Bash:
bash ~/automate_agents/install.sh .

# Windows PowerShell:
~\automate_agents\install.ps1 -Target .

# 3. Open in Claude Code
claude .

# 4. Run it
/dev-team Add rate limiting and request throttling to all API endpoints
```

The installer only adds `.claude/agents/`, `.claude/commands/`, `project_memory/`, and `checkpoints/`. It never touches your existing code. If you already have a `CLAUDE.md`, it skips that too and tells you to merge manually.

---

## Installation Details

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

## How It Works

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
