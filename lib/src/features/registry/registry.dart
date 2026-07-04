import 'package:dio/dio.dart';
import 'endpoint.dart';

/// Static identity representing an execution environment.
///
/// Under the hood, this compiles to a primitive [String] with zero runtime allocations.
extension type const EnvironmentId(String value) implements String {
  /// Production environment configuration key.
  static const production = EnvironmentId('production');

  /// Staging environment configuration key.
  static const staging = EnvironmentId('staging');

  /// QA environment configuration key.
  static const qa = EnvironmentId('qa');

  /// Development environment configuration key.
  static const development = EnvironmentId('development');

  /// Local environment configuration key.
  static const local = EnvironmentId('local');
}

/// Static identity representing a service.
///
/// Under the hood, this compiles to a primitive [String] with zero runtime allocations.
extension type const ServiceId(String value) implements String {}

/// Immutable registry containing API configuration mapping across environments and services.
class ApiRegistry {
  ApiRegistry._({
    required this.activeEnvironment,
    required Map<EnvironmentId, String> environments,
    required Map<ServiceId, String> services,
    required Map<EndpointId, EndpointDefinition> endpoints,
  }) : _environments = Map.unmodifiable(environments),
       _services = Map.unmodifiable(services),
       endpoints = Map.unmodifiable(endpoints);

  /// Currently active environment.
  final EnvironmentId activeEnvironment;

  final Map<EnvironmentId, String> _environments;
  final Map<ServiceId, String> _services;

  /// Compiled constant-time endpoints map.
  final Map<EndpointId, EndpointDefinition> endpoints;

  /// Get the builder instance to construct a new registry.
  static ApiRegistryBuilder builder() => ApiRegistryBuilder();

  /// Retrieve the base URL for the active environment.
  String get activeBaseUrl {
    final url = _environments[activeEnvironment];
    if (url == null) {
      throw StateError(
        'Active environment "$activeEnvironment" is not configured.',
      );
    }
    return url;
  }

  /// Retrieve the relative path for a service identifier.
  String? getServicePath(ServiceId serviceId) => _services[serviceId];
}

/// Builder providing validation and compilation of api configurations.
class ApiRegistryBuilder {
  final Map<EnvironmentId, String> _environments = {};
  final Map<ServiceId, String> _services = {};
  final List<EndpointDefinition> _endpoints = [];

  /// Register a new environment with its [baseUrl].
  ApiRegistryBuilder environment(EnvironmentId id, {required String baseUrl}) {
    _environments[id] = baseUrl;
    return this;
  }

  /// Register a new service relative [path] prefix.
  ApiRegistryBuilder service(ServiceId id, {required String path}) {
    _services[id] = path;
    return this;
  }

  /// Register an endpoint configuration.
  ApiRegistryBuilder endpoint({
    required EndpointId id,
    required String path,
    required ServiceId service,
    Duration? timeout,
    bool requiresAuthentication = false,
    Map<String, String>? defaultHeaders,
  }) {
    _endpoints.add(
      EndpointDefinition(
        id: id,
        pathTemplate: path,
        service: service,
        timeout: timeout,
        requiresAuthentication: requiresAuthentication,
        defaultHeaders: defaultHeaders,
      ),
    );
    return this;
  }

  /// Validate inputs, compile templates, and build a frozen immutable [ApiRegistry].
  ApiRegistry build(EnvironmentId activeEnv) {
    if (!_environments.containsKey(activeEnv)) {
      throw ArgumentError('Active environment "$activeEnv" is not defined.');
    }

    // Validate duplicate services and endpoints
    final Set<ServiceId> registeredServices = {};
    for (final serviceId in _services.keys) {
      if (!registeredServices.add(serviceId)) {
        throw ArgumentError(
          'Duplicate service identifier registered: "$serviceId"',
        );
      }
    }

    final Map<EndpointId, EndpointDefinition> compiledEndpoints = {};
    final Set<String> pathTemplates = {};

    for (final ep in _endpoints) {
      if (compiledEndpoints.containsKey(ep.id)) {
        throw ArgumentError(
          'Duplicate endpoint identifier registered: "${ep.id}"',
        );
      }

      if (!_services.containsKey(ep.service)) {
        throw ArgumentError(
          'Endpoint "${ep.id}" references an unregistered service "${ep.service}".',
        );
      }

      final uniquePathKey = '${ep.service}::${ep.pathTemplate}';
      if (!pathTemplates.add(uniquePathKey)) {
        throw ArgumentError(
          'Duplicate path template "${ep.pathTemplate}" registered under service "${ep.service}".',
        );
      }

      final Set<String> paramNames = {};
      for (final segment in ep.compiledSegments) {
        if (segment is ParamSegment) {
          if (segment.name.isEmpty) {
            throw ArgumentError(
              'Empty placeholder name in endpoint "${ep.id}" path template.',
            );
          }
          if (!paramNames.add(segment.name)) {
            throw ArgumentError(
              'Duplicate placeholder parameter name "${segment.name}" in endpoint "${ep.id}" path template.',
            );
          }
        }
      }

      compiledEndpoints[ep.id] = ep;
    }

    return ApiRegistry._(
      activeEnvironment: activeEnv,
      environments: _environments,
      services: _services,
      endpoints: compiledEndpoints,
    );
  }
}

/// Centralized internal extra keys used within RequestOptions.extra.
abstract class StudioExtra {
  /// Key for the resolved [EndpointDefinition].
  static const endpointDefinition = 'dio_more.endpoint_definition';

  /// Key for path parameters map.
  static const pathParameters = 'dio_more.path_parameters';

  /// Key for the [ApiRegistry] context instance.
  static const registry = 'dio_more.registry';
}

/// Helper extension on [Options] to easily define path parameters in standard Dio requests.
extension OptionsStudioExtension on Options {
  /// Bind dynamic path parameters for url template replacement.
  Options withPathParams(Map<String, Object?> params) {
    final extraMap = Map<String, dynamic>.from(extra ?? {});
    extraMap[StudioExtra.pathParameters] = params;
    return copyWith(extra: extraMap);
  }
}
