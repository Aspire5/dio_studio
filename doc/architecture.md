# Architecture

## Overview

`dio_more` is a developer toolkit built on top of Dio. It does not replace Dio. It extends Dio with features for API endpoint registry management and console logging.

## Core Principle

Dio handles HTTP. `dio_more` handles the developer experience around HTTP.

Developers should be able to:
- Attach `dio_more` to any existing Dio instance.
- Use only the features they need.
- Remove `dio_more` without changing their HTTP layer.

## High-Level Architecture

```
+-------------------------------------------------------------------+
|                           Public API                              |
|   (package:dio_more/dio_more.dart)                                |
|   - Re-exports package:dio/dio.dart                               |
|   - DioStudio (high-level controller)                             |
|   - DioStudioConfig (immutable configuration)                     |
|   - DioStudioExtension (extension methods on Dio)                 |
+-----------------------------------+-------------------------------+
                                    |
                                    v
+-----------------------------------+-------------------------------+
|                           Plugin API                              |
|   - DioStudioPlugin (abstract base class)                         |
|   - StudioContext (strongly-typed service provider)               |
|   - Mixin interfaces: RequestPlugin, ResponsePlugin, etc.         |
+-----------------------------------+-------------------------------+
                                    |
                                    v
+-----------------------------------+-------------------------------+
|                          Internal API                             |
|   (lib/src/core/ - Hidden from outside consumers)                 |
|   - StudioEventBus (lazy event dispatcher)                        |
|   - PluginManager (topological plugin runner)                     |
|   - StudioInterceptor (Dio-level bridge)                          |
|   - StudioLogger (internal diagnostics framework)                 |
+-------------------------------------------------------------------+
```

## Request Interception Pipeline

To allow plugins to run predictably, request-response execution runs **synchronously and in sequential order** managed by `PluginManager`.

```
[Dio Request]
      ↓
[StudioInterceptor]
      ↓
[PluginManager]  ─── (Executes plugins in topological & priority order)
      ↓
[Plugin A (e.g. Registry)]  ─── (Resolves path parameters in O(1))
      ↓
[Plugin B (e.g. Logging)]  ─── (Outputs structured console logs)
      ↓
[Target Server / Client]
```

## Design Decisions

- `dio_more` attaches to Dio via Dio's interceptor system and standard extensions.
- Zero-configuration built-in logging is active in debug mode by default and automatically tree-shaken in production.
- Plugins are registered internally during the idempotent initialization phase.

## Constraints

- No global state. All state is scoped to a `dio_more` instance.
- No monkey-patching of Dio internals.
- Minimal external dependencies.
- Virtually zero overhead in release builds.

---

Last updated: 2026-07-04
