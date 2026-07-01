import 'package:dio/dio.dart';
import 'config.dart';
import 'event_bus.dart';
import 'logger.dart';

/// Provider containing core framework capabilities for plugin usage.
class StudioContext {
  /// Create a new [StudioContext] dependency instance.
  StudioContext({
    required this.dio,
    required this.config,
    required this.logger,
    required this.eventBus,
  });

  /// The active [Dio] instance this context is bound to.
  final Dio dio;

  /// Core configuration options.
  DioStudioConfig config;

  /// Internal logger instance for plugin diagnostics.
  final StudioLogger logger;

  /// Internal event coordinator.
  final StudioEventBus eventBus;
}
