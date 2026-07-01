# Public API

This document tracks all public-facing APIs exported from `lib/dio_studio.dart`.

Every addition, modification, or removal of a public API must be reflected here.

## Exported Classes

| Class | Purpose |
| ----- | ------- |
| `DioStudio` | Main controller for attaching and configuring developer features. |
| `DioStudioConfig` | Immutable configuration options container. |
| `DioStudioPlugin` | Base class for constructing custom extensions. |
| `StudioContext` | Execution context interface exposed to plugins during initialization. |
| `PluginMetadata` | Registration model containing plugin description and compatibility. |

## Exported Interface Mixins

| Mixin Interface | Purpose |
| --------------- | ------- |
| `RequestPlugin` | Hooks into request interception hot path. |
| `ResponsePlugin` | Hooks into response interception hot path. |
| `ErrorPlugin` | Hooks into error interception hot path. |
| `LifecyclePlugin` | Provides initialization, state changes, and disposal notifications. |

## Exported Extensions

| Extension | Target | Purpose |
| --------- | ------ | ------- |
| `DioStudioExtension` | `Dio` | Attaches `.studio` property and `.enableStudio()` initializer. |

## Exported Types / Enums

| Type | Target | Purpose |
| ---- | ------ | ------- |
| `StorageAdapter` | `interface class` | Unopinionated key-value storage abstraction. |

## Deprecated APIs

_None._

---

Last updated: 2026-06-30
