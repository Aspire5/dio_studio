import '../features/logging/logging_presets.dart';
import '../features/registry/registry.dart';
import '../features/registry/endpoint.dart';

/// Feature identifiers to toggle specific plugin sets.
class StudioFeature {
  /// Create a new [StudioFeature] with target [id].
  const StudioFeature(this.id);

  /// Unique identifier of the feature module.
  final String id;
}

/// Namespace container for core features.
abstract final class StudioFeatures {
  /// Mocking features identifier.
  static const mock = StudioFeature('core.mock');

  /// Recording/replay features identifier.
  static const record = StudioFeature('core.record');

  /// Latency/error simulation features identifier.
  static const network = StudioFeature('core.network');

  /// Request inspection features identifier.
  static const inspector = StudioFeature('core.inspector');
}

class DioStudioConfig {
  /// Create a new [DioStudioConfig] options instance.
  const DioStudioConfig({
    this.enabledFeatures = const {},
    this.registry,
    this.logging = Logging.all,
    this.logOnly = const {},
  });

  /// Active feature set to tree-shake or toggle capabilities at startup.
  final Set<StudioFeature> enabledFeatures;

  /// The compile-time safe URL registry.
  final ApiRegistry? registry;

  /// Active logging preset configuration.
  final Logging logging;

  /// Set of endpoint IDs for focus logging.
  final Set<EndpointId> logOnly;

  /// Creates a copy of this config with the given fields replaced.
  DioStudioConfig copyWith({
    Set<StudioFeature>? enabledFeatures,
    ApiRegistry? registry,
    Logging? logging,
    Set<EndpointId>? logOnly,
  }) {
    return DioStudioConfig(
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      registry: registry ?? this.registry,
      logging: logging ?? this.logging,
      logOnly: logOnly ?? this.logOnly,
    );
  }
}
