# Architectural Decision Records

This file is the project's permanent memory. Every significant technical decision is recorded here so future development remains consistent.

Before making architectural changes, read this file first.

---

## ADR-001: dio_studio extends Dio, never replaces it

**Date:** 2026-06-30

**Decision:**
dio_studio is a developer toolkit built on top of Dio. It attaches to existing Dio instances and provides additional capabilities. It never wraps, hides, or replaces Dio.

**Reasoning:**
Dio is a mature, well-tested HTTP client. Replacing it would mean re-implementing HTTP logic, losing community trust, and creating migration pain. Extending it lets developers keep their existing Dio setup and adopt dio_studio features incrementally.

**Alternatives considered:**
1. Build a standalone HTTP client with all features built in.
   - Rejected: Massive scope, duplicates existing work, and forces migration.
2. Fork Dio and add features directly.
   - Rejected: Creates maintenance burden tracking upstream changes.

**Pros:**
- Developers keep their existing Dio knowledge and setup.
- dio_studio can be added or removed without changing the HTTP layer.
- Smaller scope, faster development.
- Leverages Dio's interceptor system for clean integration.

**Cons:**
- Constrained by Dio's API surface and interceptor model.
- Breaking changes in Dio could affect dio_studio.

**Impact:**
All features must integrate through Dio's public API (interceptors, adapters, transformers). No internal Dio hacking.

---

## ADR-002: All features are opt-in

**Date:** 2026-06-30

**Decision:**
Every dio_studio feature is opt-in. Attaching dio_studio to a Dio instance does nothing by default. Developers explicitly enable the features they want.

**Reasoning:**
Developers have different needs. A developer who only wants mocking should not pay the cost (runtime or cognitive) of recording, replay, or inspection features.

**Alternatives considered:**
1. Enable all features by default with opt-out flags.
   - Rejected: Adds unexpected overhead. Violates principle of least surprise.

**Pros:**
- Small surface area for simple use cases.
- No performance overhead for unused features.
- Clear, explicit configuration.

**Cons:**
- Slightly more setup code for developers who want everything.

**Impact:**
Each feature must be independently activatable. No feature should depend on another being enabled unless explicitly documented.

---

## ADR-003: Plugin-based extensibility

**Date:** 2026-06-30

**Decision:**
dio_studio uses a plugin architecture for extensibility. Third-party developers can create plugins that hook into dio_studio's lifecycle.

**Reasoning:**
We cannot anticipate every use case. A plugin system lets the community extend dio_studio without forking or modifying core code.

**Alternatives considered:**
1. Monolithic design with all features hardcoded.
   - Rejected: Does not scale. Every new use case requires a core change.
2. Callback-based hooks without formal plugin structure.
   - Rejected: Leads to spaghetti configuration. Plugins provide structure and discoverability.

**Pros:**
- Community can extend the toolkit.
- Core stays focused and maintainable.
- Features can be developed and released independently.

**Cons:**
- Plugin API must be carefully designed; breaking it affects the ecosystem.
- Adds some complexity to the core.

**Impact:**
A stable plugin interface must be defined early. Changes to the plugin API are breaking changes and must be treated with care.

---

## ADR-004: No global state

**Date:** 2026-06-30

**Decision:**
All state is scoped to a dio_studio instance. There is no global singleton, no static configuration, no ambient state.

**Reasoning:**
Global state makes testing difficult, creates hidden dependencies between components, and breaks when multiple Dio instances are in use.

**Alternatives considered:**
1. Singleton pattern for convenience.
   - Rejected: Breaks testability and multi-instance scenarios.

**Pros:**
- Fully testable.
- Multiple independent instances can coexist.
- No hidden coupling.

**Cons:**
- Developers must pass the instance around (standard dependency injection).

**Impact:**
All internal code must accept dependencies through constructors or method parameters. No `static` mutable state.

---

## ADR-005: Re-exporting Dio Package

**Date:** 2026-06-30

**Decision:**
Re-export the underlying `package:dio/dio.dart` dependency directly from the single unified entry point `package:dio_studio/dio_studio.dart`.

**Reasoning:**
This aligns with the goal of minimizing migration efforts. Instead of managing separate imports for standard Dio requests and dio_studio configurations, developers swap their import to `dio_studio` and all core symbols (`Dio`, `Response`, `DioException`, etc.) remain accessible.

**Alternatives considered:**
1. Require double imports: `import 'package:dio/dio.dart';` and `import 'package:dio_studio/dio_studio.dart';`.
   - Rejected: Decreases developer integration experience.

**Pros:**
- Drop-in migration experience.
- Single import manages the entire network toolkit client context.

**Cons:**
- Tight coupling to major Dio versions; a breaking change in Dio requires coordinating updates to dio_studio exports.

---

## ADR-006: Studio Context over Service Locator

**Date:** 2026-06-30

**Decision:**
Replace dynamic runtime map lookups (Service Locator pattern) with a strongly-typed, compile-time checked `StudioContext` passed to plugins during initialization.

**Reasoning:**
Using `locator.get<Service>()` introduces risk of runtime errors (missing registration), lacks editor autocomplete, and makes writing unit test stubs complex. A strongly-typed `StudioContext` exposes core requirements directly as properties.

**Alternatives considered:**
1. Simple internal service locator.
   - Rejected: Adds unnecessary lookup overhead and lacks compile-time safety.

**Pros:**
- Full editor support, type-safety, and autocomplete.
- Simpler stubs for testing.
- Predictable dependency graph.

**Cons:**
- Adding a new core service requires modifying the `StudioContext` interface (minor API update).

---

## ADR-007: Sequential Pipeline Interception

**Date:** 2026-06-30

**Decision:**
Execute request, response, and error modification cycles synchronously and sequentially using dedicated interface pipelines in `PluginManager` rather than asynchronously via the Event Bus.

**Reasoning:**
An Event Bus operates on an asynchronous fire-and-forget loop. This makes short-circuiting requests (such as serving mock responses) or injecting latency transformations extremely difficult. Direct interface pipelines ensure execution order is predictable and synchronous.

**Alternatives considered:**
1. Asynchronous event-driven interceptor handlers.
   - Rejected: Leads to race conditions and makes interceptor chaining complex.

**Pros:**
- High predictability.
- Easy short-circuiting (e.g. delivering mocks).
- Bypasses event object allocations on hot paths.

**Cons:**
- Relies on plugins implementing specific interface mixins (`RequestPlugin`, `ResponsePlugin`).

---

## ADR-008: Unopinionated Storage Abstraction

**Date:** 2026-06-30

**Decision:**
Do not couple Core to any specific storage implementation. Instead, expose a generic `StorageAdapter` interface, letting individual features decide which engine they require.

**Reasoning:**
Forcing dependency on specific engines (Hive, Isar, file system) limits usage flexibility (e.g. running in pure Web contexts, memory-only servers, or high-performance file systems) and increases binary size unnecessarily.

**Alternatives considered:**
1. Hardcode SQLite or Hive directly in core package.
   - Rejected: Opinionated and forces unwanted transitive dependencies.

**Pros:**
- Fully decoupled.
- Allows memory-only configurations.
- Custom storage backends can be injected.

**Cons:**
- Feature plugins must implement or request their own storage bindings.

## ADR-009: API Registry System Architecture

**Date:** 2026-07-01

**Decision:**
Implement an immutable API Registry system mapping business-identity endpoint constants (`EndpointId`) to compile-time parsed configurations (`EndpointDefinition`). The identity and configuration of endpoints remain independent of runtime parameters, which are provided separately using standard Dio `Options` with a custom extension (`withPathParams`).

**Reasoning:**
Separating endpoint configuration from parameter injection ensures that endpoint identities are stable and easily referenced by downstream plugins. Replacing raw string configurations with Dart 3.3 extension types (`EnvironmentId`, `ServiceId`, `EndpointId`) guarantees type-safety and autocomplete at compile time with zero runtime allocation overhead. Pre-compiling URL templates at initialization eliminates regular expression parsing inside the hot interceptor path.

**Alternatives considered:**
1. Dynamically matching patterns at runtime using standard regex scans.
   - Rejected: Introduces substantial performance overhead.
2. Embedding path parameters inside `EndpointId` strings (e.g., `Api.user.profile.withParams(...)`).
   - Rejected: Mutates the unique business identity string and introduces extra string allocations on the request hot path.

**Pros:**
- Complete compile-time type-safety and autocomplete for environments, services, and endpoints.
- High performance via O(1) direct map lookup and pre-compiled segment loops.
- Clean separation of concerns between static identities and runtime values.
- Seamless optional adoption for traditional URL requests.

**Cons:**
- Requires Dart 3.3+ for extension type support.

---

## ADR-010: Built-in Logging Presets & Chained API Attachment

**Date:** 2026-07-04

**Decision:**
Introduce zero-configuration console request/response logging enabled automatically in debug mode via a cascade initializer method (`Dio()..enableStudio()`). Predefine logging behaviors using immutable `Logging` presets (such as `Logging.all`, `Logging.errorsOnly`, and `Logging.none`). Register all plugins internally, removing direct plugin configuration array exposure from the public API.

**Reasoning:**
- **Zero-Ripple Migration:** Chaining `enableStudio` directly on the standard `Dio` instance lets developers integrate `dio_studio` without modifying type annotations or constructor signatures across their codebases.
- **Improved DX/AI Autocomplete:** Using strongly typed constant presets instead of generic string/map configurations or `dynamic` values provides outstanding autocomplete features inside IDEs and maximizes success rates for automated code generators.
- **Git Noise Reduction:** Consuming an optional local focus file (`lib/dio_logging.dart` via `logOnly`) prevents developers from polluting `main.dart` or bootstrap configurations with temporary debugging states.
- **Performance Safeguard:** Splitting long messages and printing them line-by-line using native `print()` bypasses OS buffer truncation (such as logcat's 4KB block limits) and retains cross-platform support without requiring external package dependencies.

**Pros:**
- Tiny, discoverable public API boundary.
- Guaranteed idempotent initialization.
- Maximum IDE code completion and type safety.
- Complete performance preservation and tree-shaking in release mode.

**Cons:**
- Developers cannot easily pass ad-hoc plugin instances during bootstrap (though custom plugin registrations can still be exposed via internal properties when needed).

---

_Add new decisions above this line. Use sequential numbering: ADR-009, ADR-010, etc._
