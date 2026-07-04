# Coding Guidelines

Standards and conventions for all code in dio_more.

## Dart Style

Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines with the additions below.

## Naming

- Classes: `PascalCase` (e.g., `DioStudio`, `MockPlugin`)
- Files: `snake_case` (e.g., `dio_more.dart`, `mock_plugin.dart`)
- Variables and functions: `camelCase` (e.g., `requestCount`, `attachTo`)
- Constants: `camelCase` (e.g., `defaultTimeout`, not `DEFAULT_TIMEOUT`)
- Private members: prefix with `_` (e.g., `_interceptors`)
- Boolean variables: use `is`, `has`, `should`, `can` prefixes (e.g., `isRecording`, `hasPlugins`)

## File Organization

Each file should have a single primary responsibility. A file can contain:
- One public class and its closely related private helpers.
- One set of closely related extension methods.
- One set of closely related typedefs.

Do not put multiple unrelated public classes in the same file.

## Import Order

Organize imports in this order, separated by blank lines:

1. `dart:` imports
2. `package:` imports (external packages)
3. Relative imports (project files)

```dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/config.dart';
import 'plugin_interface.dart';
```

## Documentation

- All public APIs must have dartdoc comments (`///`).
- Use `///` for documentation comments, not `/* */`.
- Include usage examples in dartdoc for non-trivial APIs.
- Document parameters, return values, and thrown exceptions for public methods.

```dart
/// Attaches dio_more to the given [dio] instance.
///
/// This registers all configured plugins and interceptors.
/// Call [detach] to remove dio_more from the Dio instance.
///
/// Throws [StateError] if already attached to a Dio instance.
void attach(Dio dio) { ... }
```

## Error Handling

- Use specific exception types, not generic `Exception`.
- Define custom exception classes in a dedicated file when needed.
- Document which exceptions a method can throw.
- Never catch and silently swallow exceptions.
- Use `assert` for development-time invariant checks.

## Testing

- Test file names mirror source files: `foo.dart` -> `foo_test.dart`.
- Test directory structure mirrors `lib/src/`.
- Each test file should have a top-level `group()` matching the class or feature name.
- Write descriptive test names that read like specifications.
- Arrange-Act-Assert pattern for test structure.

```dart
test('attach throws StateError when already attached', () {
  // Arrange
  final studio = DioStudio();
  studio.attach(Dio());

  // Act & Assert
  expect(() => studio.attach(Dio()), throwsStateError);
});
```

## Null Safety

- Prefer non-nullable types. Use nullable types only when null is a meaningful value.
- Use `late` sparingly and only when initialization is guaranteed before access.
- Prefer `final` for variables that are assigned once.

## Const

- Use `const` constructors where possible.
- Use `const` for compile-time constant values.

## Collections

- Prefer `List.unmodifiable()` or `UnmodifiableListView` for exposing internal collections.
- Use typed collections. Never use `dynamic` in collection type parameters without justification.

## Async

- Prefer `Future` and `async/await` over raw `Completer` usage.
- Always handle stream subscriptions (cancel on dispose).
- Document whether a method is synchronous or asynchronous in non-obvious cases.

---

Last updated: 2026-06-30
