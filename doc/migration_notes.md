# Migration Notes

This document provides migration guidance for developers upgrading between versions of dio_more.

---

## General Migration Approach

When a breaking change is introduced:
1. The breaking change is documented here with the affected version range.
2. Before/after code examples are provided.
3. The reasoning behind the change is explained.
4. An automated migration path is provided when feasible.

---

### Migrating to API Registry (Version 0.0.2+)

**Changes:**
- Introduces `ApiRegistry` and `ApiRegistryBuilder` to model environments, services, and endpoints.
- Replaces raw string URL parameters in Dio calls with strongly typed compile-time `EndpointId` constants.
- Passes runtime path parameters separately using `Options.withPathParams`.

**Why this changed:**
Improves compile-time type-safety, centralizes endpoint configurations, and pre-compiles path templates to eliminate regular expression matching overhead on the request hot path.

**Before:**
```dart
final response = await dio.get('https://api.myapp.com/user/profile/$userId');
```

**After:**
```dart
// 1. Define endpoint constants
abstract class Services {
  static const user = ServiceId('user');
}

abstract class Api {
  static const user = _User();
}

class _User {
  const _User();
  final profile = const EndpointId('user.profile');
}

// 2. Configure and build registry
final registry = ApiRegistry.builder()
    .environment(EnvironmentId.production, baseUrl: 'https://api.myapp.com')
    .service(Services.user, path: '/user')
    .endpoint(
      id: Api.user.profile,
      path: '/profile/:id',
      service: Services.user,
    )
    .build(EnvironmentId.production);

dio.enableStudio(
  config: DioStudioConfig(
    enabled: true,
    registry: registry,
  ),
);

// 3. Invoke request with parameter extension
final response = await dio.get(
  Api.user.profile,
  options: Options().withPathParams({'id': userId}),
);
```

**Steps:**
1. Declare your `ServiceId` and `EndpointId` identifiers using standard static constants.
2. Initialize `ApiRegistry` using `ApiRegistry.builder()`.
3. Pass the built registry instance during `dio.enableStudio()` configuration.
4. Replace raw string URL paths in Dio request invocations with the corresponding `EndpointId` constants, passing path parameters inside `Options().withPathParams()`.

---

_Migration entries will follow this format._

---

Last updated: 2026-07-01
