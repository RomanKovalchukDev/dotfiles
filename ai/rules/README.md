# Rules

Always-follow coding guidelines organized by language, inspired by everything-claude-code.

## Structure

```
rules/
├── common/          # Universal principles (always install these)
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── testing.md
│   └── security.md
├── typescript/      # TypeScript/JavaScript specific
├── python/          # Python specific
├── swift/           # Swift/iOS specific
└── php/             # PHP/Laravel specific
```

## Installation

### User-Level (Applies to All Projects)

```bash
# Install common rules (recommended for everyone)
mkdir -p ~/.claude/rules
cp -r ai/rules/common/* ~/.claude/rules/

# Add language-specific rules for your stack
cp -r ai/rules/typescript/* ~/.claude/rules/
cp -r ai/rules/python/* ~/.claude/rules/
cp -r ai/rules/swift/* ~/.claude/rules/
cp -r ai/rules/php/* ~/.claude/rules/
```

### Project-Level (Applies to Specific Project)

```bash
# Install to project directory
mkdir -p .claude/rules
cp -r ai/rules/common/* .claude/rules/
cp -r ai/rules/typescript/* .claude/rules/   # Pick your project stack
```

## Common Rules

Universal principles that apply to all languages:

### coding-style.md
- Immutability preferences
- File organization
- Naming conventions
- Code structure

### git-workflow.md
- Commit message format
- Branch naming
- PR process
- Code review guidelines

### testing.md
- TDD workflow
- Coverage requirements (80%+)
- Test structure
- Mocking patterns

### security.md
- Input validation
- Secret management
- OWASP Top 10
- Security checks

## Language-Specific Rules

### TypeScript/JavaScript (typescript/)
- Type safety (strict mode)
- React patterns (hooks, components)
- Next.js conventions
- Testing (Jest, Playwright)
- Linting (ESLint, Prettier)

### Python (python/)
- PEP 8 compliance
- Type hints
- Django/FastAPI patterns
- Testing (pytest)
- Virtual environments

### Swift (swift/)
- Swift concurrency
- SwiftUI patterns
- Protocol-oriented design
- Testing patterns
- Memory management

### PHP (php/)
- PSR standards
- Laravel conventions
- Type declarations
- PHPUnit testing
- Composer dependencies

## Creating New Rules

### Rule File Format

```markdown
# Rule Category

Brief description of what this rule enforces.

## When This Applies

- Use case 1
- Use case 2

## Guidelines

1. Guideline 1
   - Example
   - Counter-example

2. Guideline 2
   - Example

## Examples

### Good
\`\`\`typescript
// Good example
\`\`\`

### Bad
\`\`\`typescript
// Bad example
\`\`\`

## Exceptions

When it's okay to break this rule:
- Exception 1
- Exception 2
```

### Adding a New Rule

1. **Choose category**: common, typescript, python, swift, php
2. **Create file**: `ai/rules/category/my-rule.md`
3. **Write content**: Follow format above
4. **Test**: Install to ~/.claude/rules and test
5. **Commit**: Add to repo

## Rule Priority

When rules conflict, priority order:

1. **Project-level rules** (.claude/rules/) - Highest priority
2. **User-level rules** (~/.claude/rules/)
3. **Language-specific rules** (typescript/, python/, etc.)
4. **Common rules** (common/)

## Disabling Rules

### Temporarily

```bash
# Move rule out of ~/.claude/rules temporarily
mv ~/.claude/rules/strict-rule.md ~/.claude/rules/.disabled/
```

### Permanently

```bash
# Remove rule
rm ~/.claude/rules/unwanted-rule.md
```

### Per-Project

Create project-level rule that overrides:

```markdown
# .claude/rules/override.md

# Override: Relaxed Testing

For this project, 60% coverage is acceptable due to legacy code.
```

## Validation

### Check Active Rules

```bash
# List all active rules
ls -la ~/.claude/rules/

# Check specific rule
cat ~/.claude/rules/testing.md
```

### Test Rules

Start Claude Code session and verify:
1. Rules appear in system prompt
2. Claude follows guidelines
3. Violations are caught

## Maintenance

### Update Rules

```bash
# Pull latest
cd ~/.dotfiles
git pull

# Re-install rules
cp -r ai/rules/common/* ~/.claude/rules/
cp -r ai/rules/typescript/* ~/.claude/rules/
```

### Sync Across Projects

```bash
# Create sync script
cat > ~/sync-rules.sh << 'EOF'
#!/bin/bash
cp -r ~/.dotfiles/ai/rules/common/* ~/.claude/rules/
cp -r ~/.dotfiles/ai/rules/typescript/* ~/.claude/rules/
echo "Rules synced"
EOF

chmod +x ~/sync-rules.sh
./sync-rules.sh
```

## Best Practices

1. **Start with common rules** - Install common/ first
2. **Pick your languages** - Only install what you use
3. **Customize per-project** - Override at project level when needed
4. **Keep rules concise** - Clear, actionable guidelines
5. **Include examples** - Show good and bad patterns
6. **Review regularly** - Update as practices evolve

## Examples

### Installing for Full-Stack TypeScript/Python Project

```bash
# User-level
mkdir -p ~/.claude/rules
cp -r ai/rules/common/* ~/.claude/rules/
cp -r ai/rules/typescript/* ~/.claude/rules/
cp -r ai/rules/python/* ~/.claude/rules/
```

### Installing for iOS Project

```bash
# User-level
mkdir -p ~/.claude/rules
cp -r ai/rules/common/* ~/.claude/rules/
cp -r ai/rules/swift/* ~/.claude/rules/
```

### Installing for Laravel Project

```bash
# User-level
mkdir -p ~/.claude/rules
cp -r ai/rules/common/* ~/.claude/rules/
cp -r ai/rules/php/* ~/.claude/rules/
```

## Troubleshooting

### Rules Not Being Followed

```bash
# Verify rules installed
ls ~/.claude/rules/

# Check rule content
cat ~/.claude/rules/testing.md

# Try project-level rules for stronger enforcement
mkdir -p .claude/rules
cp ~/.claude/rules/testing.md .claude/rules/
```

### Too Many Rules (Context Limit)

```bash
# Remove unused language rules
rm -rf ~/.claude/rules/python/  # If not using Python
rm -rf ~/.claude/rules/swift/   # If not using Swift

# Or install only essential rules
mkdir -p ~/.claude/rules
cp ai/rules/common/security.md ~/.claude/rules/
cp ai/rules/common/testing.md ~/.claude/rules/
```

### Conflicting Rules

```bash
# Check for conflicts
grep -r "pattern" ~/.claude/rules/

# Remove conflicting rule
rm ~/.claude/rules/conflicting-rule.md
```

## Resources

- **everything-claude-code rules**: https://github.com/affaan-m/everything-claude-code/tree/main/rules
- **Claude Code docs**: https://docs.claude.com/en/docs/claude-code
- **Common rules reference**: `ai/rules/common/`
