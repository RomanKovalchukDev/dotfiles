# Agents

Agent definitions for Claude Code and cross-tool compatibility.

## Available Agents

### task-planner

**Purpose:** Breaks down complex tasks into actionable steps

**When to use:**
- Planning new features
- Decomposing large projects
- Creating implementation roadmaps
- Sequencing dependencies

**Model:** opus
**Color:** blue
**Tools:** Read, Grep, Glob, Bash

**Responsibilities:**
- Analyze requirements and constraints
- Break down into logical steps
- Identify dependencies
- Create structured plans
- Suggest implementation order

### laravel-debugger

**Purpose:** Laravel-specific debugging assistance

**When to use:**
- Debugging Laravel errors
- Analyzing stack traces
- Understanding Laravel internals
- Troubleshooting application issues

**Model:** haiku
**Color:** red
**Tools:** Read, Grep, Glob, Bash

**Responsibilities:**
- Analyze Laravel error messages
- Trace through application flow
- Identify common pitfalls
- Suggest fixes
- Explain Laravel-specific concepts

## Usage

### In Claude Code

Agents are invoked automatically via the Task tool when Claude determines delegation would help.

You can also explicitly request an agent:
```
Please use the task-planner agent to break down this feature.
```

### Agent Files

Agent definitions are stored as Markdown files with YAML frontmatter:

```markdown
---
name: agent-name
description: What this agent does
tools: ["Read", "Grep", "Glob", "Bash"]
model: opus
color: blue
---

You are a specialized agent...
```

**Location:** `ai/claude/agents/*.md`
**Symlinked to:** `~/.claude/agents/*.md`

## Adding New Agents

### 1. Create Agent File

```bash
cat > ai/claude/agents/my-agent.md << 'EOF'
---
name: my-agent
description: Brief description of what this agent does
tools: ["Read", "Grep"]
model: sonnet
color: green
---

You are a specialized agent for [specific purpose].

## Responsibilities
- Responsibility 1
- Responsibility 2

## How to Work
1. Step 1
2. Step 2

## Guidelines
- Guideline 1
- Guideline 2
EOF
```

### 2. Install Agent

```bash
./ai/claude/install.sh
```

### 3. Verify

```bash
ls -la ~/.claude/agents/my-agent.md
```

## Agent Best Practices

### When to Create an Agent

**Good use cases:**
- Specialized domain knowledge (Laravel, iOS, specific framework)
- Focused workflow (code review, testing, documentation)
- Limited tool access (read-only analysis)
- Specific model needs (haiku for speed, opus for reasoning)

**Bad use cases:**
- General-purpose tasks (use main Claude instead)
- Tasks requiring broad context
- One-off operations

### Model Selection

| Model | When to Use | Cost |
|-------|-------------|------|
| haiku | Fast, simple tasks | Lowest |
| sonnet | Most coding tasks | Medium |
| opus | Complex reasoning, architecture | Highest |

### Tool Selection

Common tool combinations:

```markdown
# Read-only analysis
tools: ["Read", "Grep", "Glob"]

# Code modification
tools: ["Read", "Edit", "Grep", "Glob"]

# Testing and execution
tools: ["Read", "Bash", "Grep"]

# Full access
tools: ["Read", "Edit", "Write", "Bash", "Grep", "Glob"]
```

### Color Coding

Colors help identify agents visually:

- **blue** - Planning, architecture
- **red** - Debugging, error handling
- **green** - Testing, validation
- **yellow** - Documentation, writing
- **purple** - Research, exploration

## Cross-Tool Compatibility

This AGENTS.md file is compatible with:
- **Claude Code** - Native support
- **Cursor** - Reads AGENTS.md
- **Codex** - Reads AGENTS.md
- **OpenCode** - Agents via plugin system

## Maintenance

### Update Agents

```bash
# Edit agent file
vim ai/claude/agents/task-planner.md

# Re-install
./ai/claude/install.sh
```

### Remove Agent

```bash
# Remove from repo
rm ai/claude/agents/unwanted-agent.md

# Remove symlink
rm ~/.claude/agents/unwanted-agent.md
```

### List Active Agents

```bash
ls -la ~/.claude/agents/
```

## Examples

### Code Review Agent

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: ["Read", "Grep", "Glob"]
model: sonnet
color: green
---

You are a senior code reviewer...

## Review Checklist
- Code style and conventions
- Security vulnerabilities
- Performance issues
- Test coverage
- Documentation
```

### Documentation Agent

```markdown
---
name: doc-writer
description: Writes and updates documentation
tools: ["Read", "Write", "Grep"]
model: sonnet
color: yellow
---

You are a technical documentation specialist...

## Documentation Standards
- Clear, concise language
- Code examples
- Use cases
- Troubleshooting sections
```

## Resources

- **Claude Code Agents**: https://docs.claude.com/en/docs/claude-code/agents
- **everything-claude-code**: https://github.com/affaan-m/everything-claude-code
- **Agent Files**: `ai/claude/agents/`
