import 'package:dio/dio.dart';
import '../core/studio.dart';
import '../features/logging/logging_presets.dart';
import '../features/registry/endpoint.dart';
import '../features/registry/registry.dart';

/// Extension methods for attaching [DioStudio] directly to [Dio] client instances.
extension DioStudioExtension on Dio {
  static final Expando<DioStudio> _studios = Expando<DioStudio>();

  /// Returns the [DioStudio] controller instance bound to this [Dio] client.
  ///
  /// This getter creates the [DioStudio] instance lazily if it is not already
  /// linked. State is garbage collected together with the [Dio] instance.
  DioStudio get studio {
    var instance = _studios[this];
    if (instance == null) {
      instance = DioStudio.create(this);
      _studios[this] = instance;
    }
    return instance;
  }

  /// Convenience initializer to configure and enable dio_studio on this client.
  ///
  /// Safe to call multiple times (idempotent).
  /// Returns the [Dio] instance for cascade chaining.
  Dio enableStudio({
    ApiRegistry? registry,
    Logging logging = Logging.all,
    Set<EndpointId> logOnly = const {},
  }) {
    if (studio.isInitialized) {
      return this;
    }
    studio.initialize(
      registry: registry,
      logging: logging,
      logOnly: logOnly,
    );
    return this;
  }
}
