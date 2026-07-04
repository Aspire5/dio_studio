# Changelog

All notable changes to dio_more are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/0.9.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.0] - 2026-07-04

### Added
- **Initial Public Preview** focusing on API Endpoint Registry Management and Beautiful Console Logging.
- Zero-configuration console request/response logging using static predefined `Logging` presets (`Logging.all`, [Logging.errorsOnly], [Logging.none]).
- Idempotent `Dio.enableStudio()` chained setup API for simple cascade configuration.
- Internalized plugin registration logic, removing manual configurations from public bootstrap API parameters.
- High-performance logging plugins utilizing native line-by-line `print` statements to bypass OS log truncations.
- Auto-redaction of sensitive header credentials (`Authorization`, `Cookie`, `Set-Cookie`, `ApiKey`, `X-API-Key`).
- Safe payload size guard omitting bodies over 100 KB, and metadata logs for binary or stream responses.
- Immutable `ApiRegistry` and `ApiRegistryBuilder` supporting environment management, multiple services, and pre-compiled endpoint path template segments.
- Compile-time safe identifier extension types: `EnvironmentId`, `ServiceId`, and `EndpointId`.
- Options extension helper method `Options.withPathParams()` for cleanly passing path parameter arguments.

### Changed
- Configured repository to use the official MIT License for public release under the copyright holder "Shagun Kumar".

> [!NOTE]
> This is the initial public preview release of `dio_more`. Community feedback may result in minor breaking API changes before the official stable 1.0.0 release.

## [0.0.2] - 2026-07-01

### Added
- Immutable `ApiRegistry` and `ApiRegistryBuilder` supporting environment management, multiple services with base URL prefixing, and pre-compiled endpoint path template segments.
- Compile-time safe identifier extension types: `EnvironmentId`, `ServiceId`, and `EndpointId`.
- Options extension helper method `Options.withPathParams()` for cleanly passing path parameter arguments.
- Core interceptor plugin (`ApiRegistryPlugin`) delivering O(1) direct map lookup resolution.
- Plugin Integration Contract to attach compiled metadata configurations directly to `RequestOptions.extra`.

## [0.0.1] - 2026-06-30

### Added
- Project documentation system (`docs/` directory) with architecture, decisions, roadmap, coding guidelines, plugin design, and development log.
- AI collaboration rules (`.agents/AGENTS.md`) for consistent development across sessions.
- Architectural decision records (ADR-001 through ADR-004) establishing core design principles.
- Project README with goals, design principles, and documentation links.
- Initial `lib/src/` directory structure.
- Feature roadmap with planned features.

## [0.0.1] - 2026-06-30

### Added
- Initial project scaffold.
