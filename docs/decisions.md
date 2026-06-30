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

**Future implications:**
If Dio's interceptor model proves insufficient for a feature, we document the limitation and explore alternatives (custom adapters, wrappers for specific features) without abandoning the core principle.

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

**Future implications:**
Feature presets (e.g., "debug mode" that enables inspector + recording) can be added later as convenience shortcuts without violating this principle.

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

**Future implications:**
First-party features (recording, mocking, inspection) should themselves be implemented as plugins where possible. This validates the plugin API and keeps the architecture honest.

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

**Future implications:**
This naturally supports testing and makes the package compatible with any dependency injection approach the developer uses.

---

_Add new decisions above this line. Use sequential numbering: ADR-005, ADR-006, etc._
