# API Stability & Classifications

Every public-facing class, constructor, property, and method in `dio_more` is tracked and classified under one of the stability categories defined below.

---

## API Stability Classifications

### 1. Stable
Stable APIs are fully supported. They are safe to use in any codebase.
- **Rule:** Breaking changes to Stable APIs are strictly prohibited under a minor or patch version update. Major version bumps (post-0.9.0) are required for breaking revisions.

### 2. Experimental
Experimental APIs are introduced to gather feedback. They are functional but subject to iteration.
- **Rule:** May change or be removed entirely in upcoming minor releases. Avoid using these in critical paths without planning for potential updates.

### 3. Deprecated
APIs marked for removal in future versions.
- **Rule:** Supported with warning messages. Transition guides must specify the replacement path. Deprecated items are removed in the subsequent minor or major release.

### 4. Removed
APIs that have been deleted. Their signatures and histories are tracked here for developer migration reference.

---

## API Classifications Catalog

### Stable APIs

| Symbol | Package Location | Stability Version | Notes |
| ------ | ---------------- | ----------------- | ----- |
| `DioStudio` | `package:dio_more/dio_more.dart` | `0.0.1` | Main controller interface |
| `DioStudioConfig` | `package:dio_more/dio_more.dart` | `0.0.1` | Configuration options model |
| `DioStudioPlugin` | `package:dio_more/dio_more.dart` | `0.0.1` | Abstract base plugin class |
| `StudioContext` | `package:dio_more/dio_more.dart` | `0.0.1` | Typed plugin service provider |
| `StorageAdapter` | `package:dio_more/dio_more.dart` | `0.0.1` | Generic storage abstraction |
| `RequestPlugin` | `package:dio_more/dio_more.dart` | `0.0.1` | Request interception mixin |
| `ResponsePlugin` | `package:dio_more/dio_more.dart` | `0.0.1` | Response interception mixin |
| `ErrorPlugin` | `package:dio_more/dio_more.dart` | `0.0.1` | Error interception mixin |
| `LifecyclePlugin` | `package:dio_more/dio_more.dart` | `0.0.1` | Lifecycle hooks mixin |
| `DioStudioExtension` | `package:dio_more/dio_more.dart` | `0.0.1` | Extension methods on `Dio` |

### Experimental APIs
- *None currently.*

### Deprecated APIs
- *None currently.*

### Removed APIs
- *None currently.*
