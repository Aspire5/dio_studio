import 'package:dio/dio.dart';
import '../core/context.dart';

/// Strongly-typed metadata registration model for all plugins.
class PluginMetadata {
  /// Create a new [PluginMetadata] details block.
  const PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.minStudioVersion,
    required this.supportedDioVersion,
  });

  /// Unique identifier key.
  final String id;

  /// Human-readable plugin name.
  final String name;

  /// Semantic version description.
  final String version;

  /// Author details.
  final String author;

  /// Description of what the plugin does.
  final String description;

  /// Minimum package sdk requirement.
  final String minStudioVersion;

  /// Supported upstream HTTP package scope.
  final String supportedDioVersion;
}

/// Abstract base plugin definition for all developer toolkit features.
abstract class DioStudioPlugin {
  /// Create a new [DioStudioPlugin].
  const DioStudioPlugin();

  /// Immutable registration options.
  PluginMetadata get metadata;

  /// Topological dependency requirements.
  Set<String> get dependsOn => const {};

  /// Relational ordering constraints indicating this should execute before another.
  Set<String> get runBefore => const {};

  /// Relational ordering constraints indicating this should execute after another.
  Set<String> get runAfter => const {};
}

/// Mixin interface hooking into the request interception hot path.
abstract interface class RequestPlugin {
  /// Invoked before HTTP requests are sent to downstream hosts.
  void onRequest(RequestOptions options, RequestInterceptorHandler handler);
}

/// Mixin interface hooking into the response interception hot path.
abstract interface class ResponsePlugin {
  /// Invoked when responses are returned to callers.
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler);
}

/// Mixin interface hooking into the error interception hot path.
abstract interface class ErrorPlugin {
  /// Invoked when exceptions or network errors are encountered.
  void onError(DioException err, ErrorInterceptorHandler handler);
}

/// Mixin interface providing plugin status changes and lifecycle notifications.
abstract interface class LifecyclePlugin {
  /// Invoked when context properties are loaded.
  void onInit(StudioContext context);

  /// Invoked when feature transitions to enabled state.
  void onEnable();

  /// Invoked when feature transitions to disabled state.
  void onDisable();

  /// Invoked during package resource release.
  void onDispose();
}
