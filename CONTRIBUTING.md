# Contributing Guidelines

Thank you for considering contributing to `dio_studio`!

## Code of Conduct
By participating in this project, you agree to abide by our Code of Conduct.

## Our Development Standard
This project adheres to rigorous coding, documentation, and performance standards. Before writing any code, please review:
1. `docs/design_principles.md`
2. `docs/coding_guidelines.md`
3. `docs/architecture.md`
4. `.agents/AGENTS.md` (AI collaboration guidelines)

## Sync Requirement
Every pull request that changes package execution code MUST update the corresponding documentation files (e.g. `docs/public_api.md`, `docs/folder_structure.md`). PRs that violate this requirement will not be merged.

## Pull Request Lifecycle
1. Fork the repository.
2. Create a feature branch (`git checkout -b feat/my-feature`).
3. Implement the feature and write comprehensive tests mirror the source structure (e.g. `lib/src/foo.dart` -> `test/unit/foo_test.dart`).
4. Keep the request pipeline hot path clear of runtime closures, dynamic map allocations, and reflection.
5. Run verification pipelines locally:
   ```bash
   dart format .
   dart analyze --fatal-warnings
   dart test
   ```
6. Add an entry to `docs/development_log.md` and `CHANGELOG.md`.
7. Submit the pull request.
