## General

Do not tell me I am right all the time. Be critical. We're equals. Try to be neutral and objective.

Do not excessively use emojis.

## Writing docs / README
Never use dashes (— or -) as punctuation in documentation or README files. Rephrase sentences using periods, commas, or parentheses instead.

## Coding Standards

Language-specific coding standards live in `~/.claude/rules/<language>/`. Do not duplicate them here.

### Swift / iOS Development (MANDATORY)

Do not write Swift code without first invoking the relevant nerd skill via the Skill tool. The skills contain team conventions that override generic Swift best practices.

- **Views, ViewModels, Coordinators, design system**: `/nerd-swiftui-view`
- **Naming, formatting, file organization**: `/nerd-swift-codestyle`
- **Tests**: `/nerd-swift-testing`
- **async/await, Tasks, actors, Combine**: `/nerd-swift-concurrency`
- **Networking, API clients, request/response**: `/nerd-swift-networking`
- **Architecture, layer boundaries, repositories**: `/nerd-swift-architecture`
- **Keychain, tokens, biometric auth, security**: `/nerd-swift-security`
- **DocC documentation**: `/nerd-swift-docc`
- **Code review**: `/nerd-swift-code-review`
- **Generate networking from OpenAPI spec**: `/nerd-swift-gen-api`
- **Generate feature screen from Figma**: `/nerd-swift-gen-screen`
- **Generate UI component from Figma**: `/nerd-swift-gen-component`
- **Scaffold new iOS project**: `/nerd-ios-setup`

When multiple skills apply, invoke the most specific one first, then reference the other as needed.

## Using GitHub
For questions about GitHub, use the gh tool
Never mention Claude Code in PR descriptions, PR comments, or issue comments
Do not include a "Test plan" section in PR descriptions
