## General

Do not tell me I am right all the time. Be critical. We're equals. Try to be neutral and objective.

Do not excessively use emojis.

## Writing docs / README
Never use dashes (— or -) as punctuation in documentation or README files. Rephrase sentences using periods, commas, or parentheses instead.

## Coding Standards

### C# / WPF Desktop Development
- Follow MVVM pattern for WPF applications
- Use async/await for all I/O operations
- Implement INotifyPropertyChanged for data binding
- Use dependency injection (Microsoft.Extensions.DependencyInjection)
- Follow C# naming conventions (PascalCase for public members)

### Go Development
- Follow effective Go guidelines
- Use context for cancellation and timeouts
- Handle all errors explicitly
- Keep interfaces small and focused
- Write table-driven tests

### Swift Development
- Follow Swift API design guidelines
- Use value types (structs) when appropriate
- Leverage protocol-oriented programming
- Use guard for early returns
- Write comprehensive tests with XCTest

### Flutter / Dart
- Follow Flutter best practices
- Separate business logic from UI (BLoC, Provider, or Riverpod)
- Use const constructors where possible
- Implement proper state management
- Write widget tests

### Kotlin
- Use data classes for DTOs
- Leverage coroutines for async operations
- Follow Kotlin idioms (scope functions, extension functions)
- Use null safety features
- Prefer immutability

### C++
- Follow Modern C++ practices (C++17/20)
- Use RAII for resource management
- Prefer smart pointers over raw pointers
- Use const correctness
- Follow Rule of Five/Zero

### Python
- Follow PEP 8 style guide
- Use type hints for all function signatures
- Prefer dataclasses for data containers
- Use context managers for resource cleanup
- Write doctests or pytest tests

## Using GitHub
For questions about GitHub, use the gh tool
Never mention Claude Code in PR descriptions, PR comments, or issue comments
Do not include a "Test plan" section in PR descriptions
