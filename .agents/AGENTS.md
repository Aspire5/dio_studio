# dio_more - AI Collaboration Rules

These rules apply to all AI-assisted development on the dio_more project.

## Project Identity

- Package name: `dio_more`
- Type: Flutter/Dart package
- Purpose: Developer toolkit built on top of Dio for API integration, mocking, recording, replay, network simulation, testing, and request inspection.
- This package does NOT replace Dio. It extends Dio.

## Mandatory Documentation Sync

Every code change MUST be accompanied by documentation updates. No exceptions.

- Architecture changes -> update `docs/architecture.md`
- Folder structure changes -> update `docs/folder_structure.md`
- Public API changes -> update `docs/public_api.md`
- Major decisions -> update `docs/decisions.md`
- Feature completions -> update `docs/roadmap.md`
- Any meaningful change -> add entry to `docs/development_log.md`
- Any meaningful change -> add entry to `CHANGELOG.md`

Before making architectural changes, consult `docs/decisions.md` for prior decisions.

## Coding Style

- Write code like a senior engineer. Avoid AI-flavored coding patterns.
- Prefer readability over brevity.
- Use meaningful, descriptive variable and function names.
- Keep functions focused on a single responsibility.
- Follow SOLID principles where appropriate.
- Prefer composition over inheritance.
- Keep files reasonably small. Split responsibilities cleanly.
- Avoid excessive abstraction and unnecessary cleverness.
- Never duplicate logic. Prefer reusable components.

## Comments

- Write comments that explain WHY, not WHAT.
- Do not explain obvious code.
- Do not write comments that simply restate the code.
- Good: `// Register plugins before interceptors so plugins can modify interceptor behavior during initialization.`
- Bad: `// Create a list` above `List plugins = [];`

## Tone and Language

Do NOT use in code comments, documentation, or commit messages:

- Emojis or decorative symbols
- ASCII art or fancy separators
- Marketing language
- Overused AI buzzwords: "robust", "seamless", "powerful", "enterprise", "production-ready", "cutting-edge", "state-of-the-art", "leverages", "harnesses"

Keep everything professional, direct, and natural.

## Consistency

- Never rename public APIs without documented justification in `docs/decisions.md`.
- Never change architecture without updating documentation.
- If introducing technical debt intentionally, document it in `docs/decisions.md` with a rationale and cleanup plan.

## Testing

- All public APIs must have corresponding tests.
- Test file names mirror source file names: `lib/src/foo.dart` -> `test/src/foo_test.dart`.
- Tests should be readable and serve as usage examples.
- Prefer focused unit tests over broad integration tests during early development.

## File Organization

- The `lib/dio_more.dart` barrel file exports only the public API.
- All implementation lives under `lib/src/`.
- Do not put implementation code directly in `lib/`.
- Group related files into feature directories under `lib/src/`.

## Dependencies

- Minimize external dependencies. Each new dependency needs justification.
- Dio is the primary dependency. Do not introduce alternative HTTP clients.
- Prefer Dart-native solutions over third-party packages when the complexity is comparable.

## Pull Request Discipline

- Each feature should be self-contained with its own tests and documentation updates.
- Do not mix unrelated changes in a single session.

## Decision Tracking

When making important decisions that future sessions should follow:

1. Add a full entry to `docs/decisions.md` with reasoning, alternatives, pros/cons, and implications.
2. Reference the decision in `docs/development_log.md`.
3. Follow established decisions in all future work unless explicitly overridden by the user.
