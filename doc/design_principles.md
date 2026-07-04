# Design Principles

This document outlines the core architectural and implementation tenets of `dio_more`. Every design decision and pull request must align with these principles.

---

## 1. Dio First, Never Replace Dio
`dio_more` is designed to extend and support the existing [Dio](https://pub.dev/packages/dio) HTTP client. It must never attempt to wrap, hide, or replace standard Dio classes (like `Dio`, `Response`, `RequestOptions`, `DioException`). Users continue to use standard Dio as their primary interface.

## 2. Minimal Migration Effort
Adopting `dio_more` should require as close to zero changes in existing user codebases as possible.
- **Unified Entry Point:** Re-export `package:dio/dio.dart` directly from `package:dio_more/dio_more.dart`.
- **Extension Methods:** Hook into `Dio` lifecycle using extensions like `dio.enableStudio()`.

## 3. Opt-In Functionality
No feature in `dio_more` is active by default. Simply initializing or adding the library to a `Dio` instance must not alter network behaviors or degrade execution performance.

## 4. Performance First (Negligible Overhead)
Performance is a core differentiator:
- When the package is installed but disabled, the runtime overhead must be limited to a single boolean check.
- During active interceptor pipelines, hot execution paths must avoid allocations of temporary lists, maps, closures, and reflections.
- Event dispatch systems must be lazy; event models should not be constructed if no active subscriptions exist.

## 5. Stable Public Boundaries
Expose only high-level controller and configuration definitions in the public API. Keep low-level systems (such as `PluginManager`, `StudioEventBus`, and `StudioLogger`) encapsulated internally. This ensures internal details can be refactored without breaking downstream consumers.

## 6. Composition Over Inheritance
Extend the functionality of the package through modular plugins (`DioStudioPlugin` interfaces) rather than subclassing controllers or core clients.

## 7. Documentation-Synchronous Development
No code changes are considered complete until their related documentation files are synchronized. Maintain the roadmap, public API registries, and directory structure documents dynamically.

## 8. Every Major Architectural Decision Must Be Documented
Whenever an architectural choice is finalized, record it sequentially inside `docs/decisions.md` following the ADR (Architectural Decision Record) format.
