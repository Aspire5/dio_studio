# dio_more

[![pub package](https://img.shields.io/pub/v/dio_more.svg)](https://pub.dev/packages/dio_more)
[![Build Status](https://github.com/Aspire5/dio_more/workflows/Dart%20CI/badge.svg)](https://github.com/Aspire5/dio_more/actions)
[![Platform Support](https://img.shields.io/badge/platform-flutter%20%7C%20dart-blue.svg)](https://pub.dev/packages/dio_more)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A developer toolkit built on top of [Dio](https://pub.dev/packages/dio) for structured console logging and type-safe API endpoint management.

`dio_more` is **not** a replacement HTTP client. It attaches to your existing `Dio` instance as a clean sidecar, boosting your debugging and URL routing workflow with zero code-generation.

---

## Why dio_more?

| Feature | Plain Dio | `pretty_dio_logger` | `dio_more` |
| :--- | :--- | :--- | :--- |
| **Console Formatting** | No standard format | Unicode boxes | Unicode boxes + line-by-line printing |
| **Line Truncation Protection**| No | No (logs get truncated on Android/OS limits) | **Yes** (split-printed, preserves alignment) |
| **Payload Size Protection** | No | No (causes terminal hang on large payloads) | **Yes** (bodies > 100 KB are automatically summarized) |
| **Security Redaction** | No | No | **Yes** (masks keys, cookie data, auth tokens) |
| **Endpoint Registry** | String-only URLs | String-only URLs | **Yes** (O(1) compiled paths and parameters resolution) |
| **Onboarding Cost** | N/A | Add Interceptor | **Cascade method:** `Dio()..enableStudio()` |

---

## Installation

Add `dio_more` to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
  dio_more: ^0.9.0
```

Or run:

```bash
dart pub add dio_more
```

---

## Quick Start

Enable visual console logging with default presets using cascade setup:

```dart
import 'package:dio_more/dio_more.dart';

void main() async {
  final dio = Dio()..enableStudio();

  // Your request logs will print as aligned, readable visual boxes in the console
  await dio.get('https://pub.dev/api/packages/dio_more');
}
```

---

## Migration from Dio

Since `dio_more` extends `Dio` via extensions, **no changes** are required to your existing network requests code. Simply add `..enableStudio()` to your client initialization:

```diff
- final dio = Dio();
+ final dio = Dio()..enableStudio();
```

---

## Feature Overview

### 1. API Endpoint Registry

Stop managing raw URL strings across your views or repositories. Compile paths with templates and route parameters safely in constant time.

```dart
// 1. Define logical endpoint IDs
const getPackage = EndpointId('pub.get_package');

// 2. Build the API registry compiling path templates
final registry = ApiRegistry.builder()
    .environment(EnvironmentId('production'), baseUrl: 'https://pub.dev')
    .service(const ServiceId('pub_api'), path: '/api')
    .endpoint(
      id: getPackage,
      path: '/packages/{name}',
      service: const ServiceId('pub_api'),
    )
    .build(EnvironmentId('production'));

// 3. Attach it to your Dio instance
final dio = Dio()..enableStudio(registry: registry);

// 4. Fire requests using the logical Endpoint ID in place of the path
await dio.get(
  'pub.get_package',
  options: Options()..withPathParams({'name': 'dio_more'}),
);
```

### 2. Beautiful Built-in Logging

Outputs premium box layouts. Correlation indexes (`[Req#001]`, `[Res#001]`) allow you to track async operations without confusion.

#### Configuration Presets
- `Logging.all`: Logs request details, response details, errors, and round-trip durations (default).
- `Logging.errorsOnly`: Logs only failing requests, leaving successful ones silent in the console.
- `Logging.none`: Disables console logging output completely.

```dart
final dio = Dio()
  ..enableStudio(
    logging: Logging.errorsOnly, // Log errors only
  );
```

#### Focused Endpoint Logging
Only print console logs for specific endpoints you are currently debugging by defining the `logOnly` focus set:

```dart
final dio = Dio()
  ..enableStudio(
    registry: registry,
    logOnly: {getPackage}, // Logs from other endpoints are silenced
  );
```

---

## Example Outputs

### Request Log
```text
┌── [Req#001] GET https://pub.dev/api/packages/dio_more
│   Endpoint: pub.get_package (Environment: production)
│   Headers:
│     Authorization: ******
│   Body:
│     [Empty Body]
└──────────────────────────────────────────────────────────
```

### Response Log
```text
┌── [Res#001] 200 OK (180ms)
│   Headers:
│     content-type: application/json; charset=utf-8
│   Body:
│     {
│       "name": "dio_more",
│       "version": "0.9.0"
│     }
│   Performance:
│     Duration: 180 ms
│     Payload Size: 45 B
└──────────────────────────────────────────────────────────
```

---

## Examples

Check out the executable standalone examples inside the `example/bin/` directory:
- [01_zero_setup.dart](example/bin/01_zero_setup.dart): Drop-in cascade logger setup.
- [02_endpoint_registry.dart](example/bin/02_endpoint_registry.dart): Compiling template paths and resolving parameters.
- [03_log_only.dart](example/bin/03_log_only.dart): Focused debugging using logOnly filters.
- [04_error_logging.dart](example/bin/04_error_logging.dart): Redirecting logging levels to track errors only.

---

## FAQ

#### Does this impact production performance?
No. `dio_more` uses compile-time checks (`dart.vm.product` / `dart.vm.profile`) to completely tree-shake and strip out logging code, formats, and writers from release builds, guaranteeing **zero runtime overhead** in production.

#### Does this replace Dio?
No. It attaches onto any standard `Dio` instance without overriding the default core behaviors of your client.

---

## API Stability

`dio_more` is currently in **Public Preview (0.9.0)**:
- We aim to keep the core API stable, but community feedback during this preview phase may result in minor breaking changes before the 1.0.0 stable release.
- Releases will follow Semantic Versioning (SemVer) principles to track changes clearly.

---

## Contributing

We welcome contributions! Please review our [CONTRIBUTING.md](CONTRIBUTING.md) and [architecture guidelines](doc/architecture.md) before submitting pull requests.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
