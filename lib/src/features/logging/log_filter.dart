import 'package:dio/dio.dart';
import '../../core/config.dart';
import '../registry/registry.dart';
import '../registry/endpoint.dart';

/// Filtering engine to determine if HTTP cycles should be logged.
///
/// Filters events based on active [Logging] category presets and the [logOnly] focus set.
class LogFilter {
  /// Evaluates if the request segment should be logged.
  static bool shouldLogRequest(RequestOptions options, DioStudioConfig config) {
    if (!config.logging.request) return false;
    return _matchesLogOnly(options, config);
  }

  /// Evaluates if the response segment should be logged.
  static bool shouldLogResponse(RequestOptions options, DioStudioConfig config) {
    if (!config.logging.response) return false;
    return _matchesLogOnly(options, config);
  }

  /// Evaluates if the error segment should be logged.
  static bool shouldLogError(RequestOptions options, DioStudioConfig config) {
    if (!config.logging.error) return false;
    return _matchesLogOnly(options, config);
  }

  static bool _matchesLogOnly(RequestOptions options, DioStudioConfig config) {
    if (config.logOnly.isEmpty) return true;

    final definition = options.extra[StudioExtra.endpointDefinition];
    if (definition is EndpointDefinition) {
      return config.logOnly.contains(definition.id);
    }

    return false; // Endpoint not registered / bypassed registry, filter it out.
  }
}
