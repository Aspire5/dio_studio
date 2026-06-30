# dio_studio

A developer toolkit built on top of [Dio](https://pub.dev/packages/dio).

dio_studio is **not** another HTTP client. It extends Dio with tools for API integration, mocking, recording, replay, network simulation, testing, and request inspection.

## Status

This package is in early development. The public API is not yet stable.

## Goals

- Improve developer experience when working with HTTP APIs.
- Provide API mocking for development and testing without hitting real servers.
- Record and replay API traffic for reproducible testing.
- Simulate network conditions (latency, errors, throttling).
- Inspect and debug requests and responses.
- Support a plugin architecture for community extensibility.

## Design Principles

- **Extends, never replaces.** dio_studio attaches to your existing Dio instance. Remove it anytime without changing your HTTP layer.
- **Opt-in features.** Nothing is enabled by default. Use only what you need.
- **No global state.** All state is scoped to a dio_studio instance.
- **Plugin-based.** Extensible through a plugin system for custom behaviors.

## Installation

```yaml
dependencies:
  dio_studio:
    git:
      url: https://github.com/your-org/dio_studio.git
```

_pub.dev publishing will happen when the API stabilizes._

## Usage

_Usage examples will be added as features are implemented._

## Documentation

See the [docs/](docs/) directory for detailed documentation:

- [Architecture](docs/architecture.md)
- [Public API](docs/public_api.md)
- [Folder Structure](docs/folder_structure.md)
- [Decisions](docs/decisions.md)
- [Roadmap](docs/roadmap.md)
- [Plugin System](docs/plugins.md)
- [Coding Guidelines](docs/coding_guidelines.md)
- [Development Log](docs/development_log.md)

## Contributing

This project follows strict documentation and coding standards. Read the following before contributing:

1. [Coding Guidelines](docs/coding_guidelines.md)
2. [Architecture](docs/architecture.md)
3. [Decisions](docs/decisions.md)

Every code change must include corresponding documentation updates.

## License

See [LICENSE](LICENSE) for details.
