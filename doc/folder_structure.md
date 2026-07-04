# Folder Structure

This document describes the project layout. Update this whenever directories or files are added, moved, or removed.

```
dio_studio/
|
|-- .agents/
|   |-- AGENTS.md              # AI collaboration rules for this project
|
|-- docs/
|   |-- architecture.md        # High-level architecture and design
|   |-- public_api.md          # Catalog of all exported public APIs
|   |-- folder_structure.md    # This file. Project layout reference
|   |-- decisions.md           # Architectural decision records
|   |-- roadmap.md             # Feature roadmap and status tracking
|   |-- plugins.md             # Plugin system design and documentation
|   |-- coding_guidelines.md   # Coding standards and conventions
|   |-- development_log.md     # Chronological log of development activity
|   |-- future_ideas.md        # Ideas for future exploration (not committed to)
|   |-- migration_notes.md     # Notes for users migrating between versions
|   |-- design_principles.md   # Core design principles of dio_studio
|   |-- vision.md              # Mission, success criteria, and non-goals
|   |-- api_stability.md       # API stability categorization references
|
|-- benchmarks/                # Performance benchmarks
|   |-- results/               # Cached benchmark reports for comparison
|
|-- lib/
|   |-- dio_studio.dart        # Unified entry point (exports public symbols & re-exports Dio)
|   |-- src/                   # All implementation code lives here
|       |-- core/              # Shared core (context, Event Bus, logging, events)
|           |-- events/        # Modular event categories
|       |-- compatibility/     # Isolated version-specific layers
|           |-- README.md      # Guidelines for future adapters
|       |-- plugins/           # Base plugin structures and managers
|       |-- features/          # Feature modules (isolated compile units)
|           |-- registry/      # Compile-time safe API Registry modules
|           |-- mock/          # Mock engine modules
|           |-- record/        # Recording/replay modules
|           |-- network/       # Simulator modules
|           |-- inspector/     # Inspector diagnostic tools
|
|-- test/
|   |-- unit/                  # Standard unit tests
|   |-- integration/           # Lifecycle integration tests
|   |-- performance/           # Stress and memory testing
|   |-- compatibility/         # Drop-in upgrade validation
|
|-- example/                   # Showcase command-line / basic example
|
|-- CHANGELOG.md               # Version-by-version changelog
|-- README.md                  # Package README for pub.dev
|-- pubspec.yaml               # Dart package configuration
|-- analysis_options.yaml      # Lint and analysis rules
|-- LICENSE                    # License file
|-- .gitignore                 # Git ignore rules
```

## Conventions

- `lib/dio_studio.dart` is the single barrel file. It exports only public API symbols and re-exports `package:dio/dio.dart`.
- All implementation goes inside `lib/src/`. Never place implementation files directly in `lib/`.
- Feature directories inside `lib/src/features/` group related files.
- Test file paths mirror source file paths under their respective subdirectories: `lib/src/core/context.dart` -> `test/unit/core/context_test.dart`.
- Documentation lives in `docs/` and is always kept in sync with the codebase.

---

Last updated: 2026-06-30
