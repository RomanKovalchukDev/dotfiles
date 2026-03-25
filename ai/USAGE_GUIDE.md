# Using Everything Claude Code with Your Development Stack

This guide shows how to leverage Everything Claude Code (ECC) for your multi-language development workflow.

## What ECC Provides

Based on your installation, you have access to:

**General-Purpose ECC Resources:**
- **60+ commands**: `/plan`, `/tdd`, `/code-review`, `/build-fix`, `/security-review`, etc.
- **28 agents**: planner, code-reviewer, security-reviewer, test-runner, etc.
- **119 skills**: TDD patterns, security practices, testing strategies, etc.

**Language-Specific Rules** (already configured):
- TypeScript/JavaScript (for tooling/build scripts)
- Python
- Go
- Swift
- C#
- Kotlin
- Rust/C++ (combined ruleset)

## Recommended Workflow by Language

### C# / WPF Desktop Development

**ECC Commands to Use:**
- `/everything-claude-code:plan` - Plan MVVM architecture changes
- `/everything-claude-code:tdd` - Write tests for ViewModels and business logic
- `/everything-claude-code:code-review` - Review data binding implementations
- `/everything-claude-code:security-review` - Check for security issues in desktop apps

**Custom Skills You Should Create:**
- `wpf-mvvm-pattern` - MVVM architecture patterns and best practices
- `wpf-data-binding` - INotifyPropertyChanged, RelayCommand implementations
- `wpf-dependency-injection` - Setting up Microsoft.Extensions.DependencyInjection
- `csharp-async-patterns` - async/await patterns for WPF apps

### Go Development

**ECC Commands to Use:**
- `/everything-claude-code:tdd` - Table-driven tests
- `/everything-claude-code:build-fix` - Fix build errors
- `/everything-claude-code:security-review` - Check for common Go security issues

**Custom Skills You Should Create:**
- `go-error-handling` - Idiomatic error wrapping and handling
- `go-table-driven-tests` - Test patterns with subtests
- `go-context-patterns` - Context usage for cancellation/timeouts
- `go-interface-design` - Small, focused interface patterns

### Swift Development

**ECC Commands to Use:**
- `/everything-claude-code:plan` - Plan iOS/macOS features
- `/everything-claude-code:tdd` - Write XCTest tests
- `/everything-claude-code:code-review` - Review Swift code quality

**Custom Skills You Should Create:**
- `swift-protocol-oriented` - Protocol-oriented design patterns
- `swift-value-types` - When to use struct vs class
- `swift-async-await` - Modern Swift Concurrency patterns
- `swift-swiftui-patterns` - SwiftUI best practices (if you use it)

### Flutter / Dart

**ECC Commands to Use:**
- `/everything-claude-code:plan` - Plan widget architecture
- `/everything-claude-code:tdd` - Widget and unit tests
- `/everything-claude-code:code-review` - Review state management

**Custom Skills You Should Create:**
- `flutter-bloc-pattern` - BLoC state management patterns
- `flutter-widget-composition` - Widget composition strategies
- `flutter-navigation` - Navigation 2.0 patterns
- `flutter-performance` - Const constructors, build optimization

### Kotlin

**ECC Commands to Use:**
- `/everything-claude-code:tdd` - Unit tests with coroutines
- `/everything-claude-code:security-review` - Check Kotlin-specific issues

**Custom Skills You Should Create:**
- `kotlin-coroutines` - Coroutine patterns and best practices
- `kotlin-dsl` - Building type-safe DSLs
- `kotlin-multiplatform` - KMP setup and patterns (if applicable)
- `kotlin-flow` - Flow patterns for reactive streams

### C++

**ECC Commands to Use:**
- `/everything-claude-code:security-review` - Memory safety, buffer overflows
- `/everything-claude-code:code-review` - Check modern C++ usage

**Custom Skills You Should Create:**
- `cpp-raii-pattern` - RAII resource management
- `cpp-smart-pointers` - unique_ptr, shared_ptr, weak_ptr usage
- `cpp-modern-features` - C++17/20 feature adoption
- `cpp-rule-of-five` - Proper copy/move semantics

### Python

**ECC Commands to Use:**
- `/everything-claude-code:tdd` - pytest patterns
- `/everything-claude-code:security-review` - Check for injection vulnerabilities

**Custom Skills You Should Create:**
- `python-type-hints` - Type annotation patterns
- `python-async` - asyncio patterns and pitfalls
- `python-dataclasses` - Dataclass vs NamedTuple vs dict
- `python-context-managers` - Resource cleanup patterns

## Getting Started

### 1. Install the Setup

```bash
cd ~/Documents/dotfiles
machine-setup/unix/install-ai.sh
```

This will:
- Install ECC plugin via Claude Code
- Copy language-specific rules for your tech stack
- Symlink personal configs from dotfiles to ~/.claude/

### 2. Test ECC Commands

```bash
cd ~/path/to/your-project
claude
# In Claude Code:
/everything-claude-code:plan "Add feature X"
```

### 3. Create Your First Custom Skill

Start with your primary development language. For example, if C#/WPF is your main stack:

```bash
mkdir -p ~/Documents/dotfiles/ai/.claude/skills/wpf-mvvm-pattern
vim ~/Documents/dotfiles/ai/.claude/skills/wpf-mvvm-pattern/SKILL.md
```

Use `SKILL_TEMPLATE.md` as a guide. Include:
- MVVM architecture patterns
- ViewModelBase implementation examples
- INotifyPropertyChanged best practices
- RelayCommand patterns

### 4. Symlink Your New Skill

```bash
cd ~/Documents/dotfiles
machine-setup/unix/install-ai.sh
```

### 5. Use It in Your Workflow

- **Planning features**: `/everything-claude-code:plan "Add user authentication"`
- **Writing code**: Mention your custom skills in prompts ("Use wpf-mvvm-pattern")
- **Code review**: `/everything-claude-code:code-review`
- **Testing**: `/everything-claude-code:tdd`
- **Security**: `/everything-claude-code:security-review`

## Cross-Language Patterns

These ECC features work across all your languages:

- **Security skills**: SQL injection, XSS, authentication patterns
- **Testing patterns**: TDD, test organization, mocking strategies
- **Design patterns**: SOLID principles, dependency injection
- **Git workflow**: Commit conventions, PR descriptions
- **Documentation**: README generation, API docs

## Command Reference

### Most Useful ECC Commands

```bash
# Planning and architecture
/everything-claude-code:plan "Feature description"

# Test-driven development
/everything-claude-code:tdd

# Code quality
/everything-claude-code:code-review
/everything-claude-code:refactor

# Building and fixing
/everything-claude-code:build-fix
/everything-claude-code:test-fix

# Security
/everything-claude-code:security-review

# Documentation
/everything-claude-code:docs
```

### Updating ECC

**Update ECC plugin:**
```bash
claude <<EOF
/plugin update everything-claude-code@everything-claude-code
EOF
```

**Update ECC rules:**
```bash
cd ~/Documents/PersonalProjects/setup/everything-claude-code
git pull
~/Documents/dotfiles/machine-setup/unix/install-ai.sh
```

## Tips and Best Practices

1. **Use namespaced commands**: ECC commands are namespaced as `/everything-claude-code:command-name`

2. **Combine ECC with custom skills**: Reference your custom skills in prompts for domain-specific guidance

3. **Create skills incrementally**: Start with one skill for your most common pattern, then expand

4. **Leverage hooks**: ECC includes hooks for auto-formatting, typechecking, etc. (configured via plugin)

5. **Security-first**: Your settings.json has a deny list for dangerous operations. Review before allowing any blocked commands.

6. **Statusline awareness**: Monitor your context usage (shown in statusline) to avoid running out of context

## Troubleshooting

**ECC commands not found:**
```bash
claude <<EOF
/plugin list
EOF
```

If not installed, re-run `install-ai.sh`.

**Custom skills not loading:**
```bash
# Verify symlinks
ls -la ~/.claude/skills/

# Recreate if needed
~/Documents/dotfiles/machine-setup/unix/install-ai.sh
```

**Language rules not applied:**

Check that rules are copied:
```bash
ls ~/.claude/rules/
```

Re-run install-ai.sh if rules are missing.

## Next Steps

1. Install the configuration: `machine-setup/unix/install-ai.sh`
2. Test ECC in a real project
3. Create your first custom skill for your primary language
4. Add more skills as you identify recurring patterns
5. Customize agents for domain-specific workflows (optional)

See `SKILL_TEMPLATE.md` for detailed examples of creating custom skills.
