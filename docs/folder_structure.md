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
|
|-- lib/
|   |-- dio_studio.dart        # Barrel file. Exports the public API only
|   |-- src/                   # All implementation code lives here
|       |-- (feature dirs)     # Grouped by feature: core/, plugins/, recording/, etc.
|
|-- test/
|   |-- (mirrors lib/src/)     # Test files mirror source structure
|
|-- example/                   # Usage examples (added when features exist)
|
|-- CHANGELOG.md               # Version-by-version changelog
|-- README.md                  # Package README for pub.dev
|-- pubspec.yaml               # Dart package configuration
|-- analysis_options.yaml      # Lint and analysis rules
|-- LICENSE                    # License file
|-- .gitignore                 # Git ignore rules
```

## Conventions

- `lib/dio_studio.dart` is the single barrel file. It exports only public API symbols.
- All implementation goes inside `lib/src/`. Never place implementation files directly in `lib/`.
- Feature directories inside `lib/src/` group related files. Examples: `core/`, `plugins/`, `recording/`, `inspector/`, `mock/`, `simulation/`.
- Test file paths mirror source file paths: `lib/src/core/config.dart` -> `test/src/core/config_test.dart`.
- Documentation lives in `docs/` and is always kept in sync with the codebase.

---

Last updated: 2026-06-30
