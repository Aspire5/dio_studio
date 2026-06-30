# Architecture

## Overview

dio_studio is a developer toolkit built on top of Dio. It does not replace Dio. It extends Dio with features for API integration, mocking, recording, replay, network simulation, testing, and request inspection.

## Core Principle

Dio handles HTTP. dio_studio handles the developer experience around HTTP.

Developers should be able to:
- Attach dio_studio to any existing Dio instance.
- Use only the features they need.
- Remove dio_studio without changing their HTTP layer.

## High-Level Architecture

```
+------------------+
|   Developer App  |
+--------+---------+
         |
         v
+------------------+
|   dio_studio     |  <-- Toolkit layer
|                  |
|  - Interceptors  |
|  - Plugins       |
|  - Recorders     |
|  - Inspectors    |
+--------+---------+
         |
         v
+------------------+
|      Dio         |  <-- HTTP layer (not owned by us)
+------------------+
```

## Design Decisions

- dio_studio attaches to Dio via Dio's interceptor system.
- All features are opt-in. Nothing is forced on the developer.
- The plugin system allows third-party extensions.
- Recording and replay are separate concerns with separate APIs.

## Layers

### Public API Layer
The top-level classes and functions developers interact with. Exported from `lib/dio_studio.dart`.

### Plugin Layer
The extension system. Plugins can hook into request/response lifecycle events. See `docs/plugins.md`.

### Interceptor Layer
Dio interceptors that bridge dio_studio's features into Dio's pipeline.

### Core Layer
Internal utilities, data models, and shared logic. Not exported publicly.

## Constraints

- No global state. All state is scoped to a dio_studio instance.
- No monkey-patching of Dio internals.
- No dependency on Flutter framework (this is a pure Dart package that happens to be in a Flutter project).
- Minimal external dependencies.

---

Last updated: 2026-06-30
