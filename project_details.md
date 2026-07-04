# Dio Studio - Package Architecture & API Registry Guide

Welcome to package development! This guide is designed for developers who are new to building Dart/Flutter packages. It explains how packages are structured, how code navigates under the hood, and how the newly implemented **API Registry** works.

---

## 1. How a Dart/Flutter Package Works

A Dart package is a reusable module of code. When you build a package, there are specific conventions regarding how you structure your files and how you expose code to the developers using your package.

### File Structure and Visibility Boundaries
A standard package has a `lib/` directory:
```
dio_studio/
|-- lib/
|   |-- dio_studio.dart        # The entry/barrel file (Public API)
|   |-- src/                   # Implementation files (Hidden/Private)
```

1. **The Entry / Barrel File (`lib/dio_studio.dart`):**
   * This is the only file that developers import when using the package:
     ```dart
     import 'package:dio_studio/dio_studio.dart';
     ```
   * It uses `export` statements to expose public classes, methods, and extensions. If a file or class is not exported here, developers importing your package cannot access or see it.

2. **The Private Implementation (`lib/src/`):**
   * By convention, everything inside `lib/src/` is private to the package. 
   * External applications cannot directly import anything under `lib/src/`. This keeps the API clean and allows you to change internal implementation details later without breaking the user's code.

---

## 2. How `dio_studio` Navigates Under the Hood

When a developer attaches `dio_studio` to their `Dio` client, here is the lifecycle and execution path:

```
                  ┌───────────────────────────────┐
                  │          Dio Client           │
                  └───────────────┬───────────────┘
                                  │
                   .enableStudio() / .studio
                                  │
                  ┌───────────────▼───────────────┐
                  │          DioStudio            │
                  │   (Holds Context & Config)    │
                  └───────────────┬───────────────┘
                                  │
                                  │ registers & runs
                                  ▼
                  ┌───────────────────────────────┐
                  │       StudioInterceptor       │
                  │ (Inserted in Dio interceptors)│
                  └───────────────┬───────────────┘
                                  │
                                  │ request flow
                                  ▼
   ┌─────────────────────────────────────────────────────────────┐
   │                       Plugin Pipeline                       │
   │                                                             │
   │  ┌───────────────────────┐       ┌───────────────────────┐  │
   │  │  ApiRegistryPlugin    │──────▶│  (Future Mocks/Recs)  │  │
   │  │ (O(1) URL Resolution) │       │                       │  │
   │  └───────────────────────┘       └───────────────────────┘  │
   └──────────────────────────────┬──────────────────────────────┘
                                  │
                                  ▼
                         To Target Backend
```

### 1. Attachment via Extensions
We define an extension on `Dio` (found in `lib/src/extensions/dio_extensions.dart`). This adds a `.studio` getter and `.enableStudio()` method directly to any standard `Dio` instance:
* Under the hood, it uses a Dart `Expando` (a weak-reference map) to attach a unique `DioStudio` controller class to the `Dio` instance without leaking memory.

### 2. The Interception Hook
When `enable()` is called on `DioStudio`, it inserts a custom `StudioInterceptor` into the `Dio` instance's `interceptors` list.
* Standard `Dio` requests now flow through this interceptor before hitting the internet.

### 3. Topological Plugin Execution
The interceptor delegates control to a list of registered plugins via a `PluginManager`.
* Plugins are sorted based on their dependencies (e.g. `runBefore` / `runAfter`).
* When a request is made, `StudioInterceptor` executes each plugin in sequence (such as the registry plugin, followed by future mock or recording plugins) to modify request options, short-circuit responses, or log errors.

---

## 3. Deep Dive: The API Registry Module

The **API Registry Module** is the foundational registry created under Phase 2. Its goal is to replace raw string URLs with strongly typed constants while preserving the standard Dio developer experience.

### A. The Compile-Time Type System
To prevent developer typos, we declare custom **extension types** on `String`:
* `EnvironmentId`: Identifies the target environment (e.g. `EnvironmentId.production`, `EnvironmentId.staging`).
* `ServiceId`: Identifies a microservice path prefix (e.g. `Services.auth`, `Services.user`).
* `EndpointId`: Identifies a specific endpoint (e.g. `Api.user.profile`).

*Why use extension types?*
Dart 3.3 extension types compile directly down to primitive `String` types at runtime. They have **zero performance penalty** (no wrapper object allocations), yet they provide compile-time safety and autocomplete inside your editor.

### B. Pre-Compilation & Validation (Initialization Phase)
When the application starts, the developer configures the registry using `ApiRegistryBuilder`.
* **Path Parsing:** Instead of evaluating path templates like `/profile/:id` dynamically using slow regular expressions during request execution, we compile them into segment structures (`LiteralSegment`, `ParamSegment`) when `.build()` is run.
* **Structural Validation:** The builder performs verification checks before the app starts:
  - Rejects duplicate service paths or endpoint keys.
  - Ensures endpoints only reference registered services.
  - Rejects duplicate parameters in path templates.

### C. Runtime URL Resolution & Contract (Hot Path)
When a request is executed (e.g., `dio.get(Api.user.profile)`):
1. **O(1) Map Lookup:** The registry plugin receives the request path (`user.profile`) and performs a constant-time lookup in the precomputed registry map. If it is not found, the interceptor immediately continues down the chain (allowing standard raw URL paths to work).
2. **Path Parameter Substitution:** If the endpoint expects parameters, it retrieves them from the `RequestOptions.extra` map (passed by the developer via `options: Options().withPathParams(...)`). It substitutes placeholders with parameters in a quick loop over the pre-compiled segments.
3. **URL Normalization:** The base URL (from the active environment), the service path, and the resolved relative path are joined, stripping out duplicate slashes.
4. **Plugin Integration Contract:** The registry plugin attaches the resolved `EndpointDefinition` metadata to `RequestOptions.extra[StudioExtra.endpointDefinition]`. Downstream plugins (such as a future Mock Engine or Request Recorder) look for this field to identify which endpoint is executing, keeping them decoupled.
