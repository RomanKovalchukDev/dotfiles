# Skill Template

Copy this template to create your own custom skills.

## How to Create a Skill

1. **Create a directory** in `ai/.claude/skills/my-skill-name/`
2. **Create SKILL.md** with YAML frontmatter
3. **Run install-ai.sh** to symlink to `~/.claude/skills/`

## Skill Structure

```markdown
---
name: my-skill-name
description: Brief description of what this skill does
tags: [tag1, tag2, tag3]
---

# My Skill Name

Brief overview of what this skill is for.

## When to Use

Describe when Claude should use this skill:
- Scenario 1
- Scenario 2
- Scenario 3

## How It Works

Step-by-step workflow:

1. **Step 1**: Description
2. **Step 2**: Description
3. **Step 3**: Description

## Examples

### Example 1: Use Case Name

**Input:**
```
User request or scenario
```

**Output:**
```
Expected result
```

### Example 2: Another Use Case

**Input:**
```
Another scenario
```

**Output:**
```
Expected result
```

## Best Practices

- Best practice 1
- Best practice 2
- Best practice 3

## Common Pitfalls

- Avoid X because Y
- Watch out for Z

## Related Skills

- Link to related skill 1
- Link to related skill 2
```

## Example Skill Ideas

### C# WPF Desktop
- **wpf-mvvm-pattern** - MVVM architecture for WPF apps
- **wpf-data-binding** - INotifyPropertyChanged implementation
- **wpf-dependency-injection** - DI setup with Microsoft.Extensions

### Go
- **go-error-handling** - Idiomatic error handling patterns
- **go-table-driven-tests** - Table-driven test patterns
- **go-context-patterns** - Context usage for cancellation

### Swift
- **swift-protocol-oriented** - Protocol-oriented design patterns
- **swift-value-types** - When to use struct vs class
- **swift-async-await** - Modern concurrency patterns

### Flutter/Dart
- **flutter-bloc-pattern** - BLoC state management
- **flutter-widget-composition** - Widget composition strategies
- **flutter-navigation** - Navigation patterns

### Kotlin
- **kotlin-coroutines** - Coroutine patterns and best practices
- **kotlin-dsl** - Building type-safe DSLs
- **kotlin-multiplatform** - KMP setup and patterns

### C++
- **cpp-raii-pattern** - RAII resource management
- **cpp-smart-pointers** - Smart pointer usage
- **cpp-modern-features** - C++17/20 feature adoption

### Python
- **python-type-hints** - Type annotation patterns
- **python-async** - asyncio patterns
- **python-dataclasses** - Dataclass usage patterns

## Naming Conventions

- Use lowercase with hyphens: `my-skill-name`
- Be specific: `wpf-mvvm-pattern` not `mvvm`
- Use prefixes for language: `go-`, `swift-`, `flutter-`, etc.
