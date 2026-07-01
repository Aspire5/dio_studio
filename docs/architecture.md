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
+-------------------------------------------------------------------+
|                           Public API                              |
|   (package:dio_studio/dio_studio.dart)                            |
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

To allow plugins to mutate requests and mock responses predictably, request-response execution runs **synchronously and in sequential order** managed by `PluginManager`.

```
[Dio Request]
      ↓
[StudioInterceptor]
      ↓
[PluginManager]  ─── (Executes plugins in topological & priority order)
      ↓
[Plugin A (e.g. Mocking)]  ─── (Can return mock response and short-circuit)
      ↓
[Plugin B (e.g. Latency Simulation)]  ─── (Injects artificial delay)
      ↓
[Target Server / Client]
```

The internal `StudioEventBus` operates in the background strictly for non-mutating side effects (such as updating telemetry, logs, or diagnostic UI components) and relies on lazy dispatch logic to avoid runtime memory allocations when no listeners are active.

## Design Decisions

- dio_studio attaches to Dio via Dio's interceptor system.
- All features are opt-in. Nothing is forced on the developer.
- The plugin system allows third-party extensions.
- Recording and replay are separate concerns with separate APIs.
- Context and storage adapters are isolated from the core network pipeline.

## Layers

### Public API Layer
The top-level classes and functions developers interact with. Exported from a single entry point: `lib/dio_studio.dart`.

### Plugin Layer
The extension system. Plugins are registered using mixin interfaces for type-safe execution.

### Interceptor Layer
Dio interceptors that bridge dio_studio's features into Dio's pipeline.

### Core Layer
Internal utilities, data models, event bus, diagnostic logger, and shared logic. Not exported publicly.

## Constraints

- No global state. All state is scoped to a dio_studio instance.
- No monkey-patching of Dio internals.
- Minimal external dependencies.
- Virtually zero overhead when features are disabled.

---

Last updated: 2026-06-30
