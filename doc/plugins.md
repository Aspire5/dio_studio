# Plugin System

## Overview

dio_more uses a plugin architecture to keep the core small and allow extensibility. Plugins can hook into the request/response lifecycle and add custom behavior.

## Design Goals

- Plugins are self-contained units of functionality.
- Plugins can be first-party (shipped with dio_more) or third-party (community-built).
- Plugins are registered explicitly by the developer. No auto-discovery.
- Plugins have access to lifecycle hooks but cannot break core functionality.
- Plugin order matters. Plugins execute in registration order.

## Plugin Interface

_Not yet implemented. This section will be updated when the plugin interface is designed._

The plugin interface will likely include:

- `onInit` - Called when the plugin is registered.
- `onRequest` - Called before a request is sent.
- `onResponse` - Called after a response is received.
- `onError` - Called when an error occurs.
- `onDispose` - Called when dio_more is disposed.

## Plugin Registration

_Not yet implemented._

Plugins will be registered through the DioStudio configuration:

```dart
// Planned API (subject to change)
final studio = DioStudio(
  dio: myDioInstance,
  plugins: [
    MockPlugin(...),
    RecorderPlugin(...),
    InspectorPlugin(...),
  ],
);
```

## First-Party Plugins

These plugins will ship with dio_more:

| Plugin | Purpose | Status |
| ------ | ------- | ------ |
| MockPlugin | Provide mock responses | Planned |
| RecorderPlugin | Record API traffic | Planned |
| ReplayPlugin | Replay recorded traffic | Planned |
| SimulatorPlugin | Simulate network conditions | Planned |
| InspectorPlugin | Inspect request/response details | Planned |

## Third-Party Plugin Guidelines

_Will be documented when the plugin API stabilizes._

Guidelines will cover:
- How to implement the plugin interface.
- How to package and distribute plugins.
- Best practices for plugin development.
- Testing recommendations.

---

Last updated: 2026-06-30
