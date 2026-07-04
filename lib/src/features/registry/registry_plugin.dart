import 'package:dio/dio.dart';
import '../../core/context.dart';
import '../../plugins/plugin.dart';
import 'endpoint.dart';
import 'registry.dart';

/// Core plugin resolving registered endpoints, base URLs, and path parameters in O(1) time.
class ApiRegistryPlugin extends DioStudioPlugin
    implements RequestPlugin, LifecyclePlugin {
  /// Create a new [ApiRegistryPlugin] instance.
  ApiRegistryPlugin();

  late final StudioContext _context;

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'dio_more.registry',
    name: 'API Registry Plugin',
    version: '0.9.0',
    author: 'Antigravity Team',
    description:
        'Resolves registry endpoint paths, base URLs, and path parameters in constant time.',
    minStudioVersion: '0.9.0',
    supportedDioVersion: '5.x.x',
  );

  @override
  void onInit(StudioContext context) {
    _context = context;
  }

  @override
  void onEnable() {}

  @override
  void onDisable() {}

  @override
  void onDispose() {}

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final registry = _context.registry;
    if (registry == null) {
      return;
    }

    final endpointKey = EndpointId(options.path);
    final definition = registry.endpoints[endpointKey];

    if (definition == null) {
      // Optional Adoption: If not found in registry, treat as standard raw path.
      return;
    }

    // Attach resolved registry and endpoint definition to extra parameters (Plugin Integration Contract)
    options.extra[StudioExtra.registry] = registry;
    options.extra[StudioExtra.endpointDefinition] = definition;

    // Retrieve path parameters passed via Options extension
    final pathParams =
        (options.extra[StudioExtra.pathParameters] as Map<String, Object?>?) ??
        const {};

    // Validate path parameters and resolve the relative path
    final relativePath = _resolveAndValidatePath(definition, pathParams);

    // Resolve base URL for the active environment and service path prefix
    final baseUrl = registry.activeBaseUrl;
    final servicePath = registry.getServicePath(definition.service) ?? '';

    // URL Normalization: Combine baseUrl + servicePath + relativePath
    final finalUrl = _normalizeUrl(baseUrl, servicePath, relativePath);

    // Update request path and base URL
    options.path = finalUrl;
    options.baseUrl = '';

    // Apply endpoint-specific options (e.g. timeout) if configured
    if (definition.timeout != null) {
      options.sendTimeout = definition.timeout;
      options.receiveTimeout = definition.timeout;
      options.connectTimeout = definition.timeout;
    }

    // Apply default headers if configured
    if (definition.defaultHeaders != null) {
      options.headers.addAll(definition.defaultHeaders!);
    }
  }

  String _resolveAndValidatePath(
    EndpointDefinition definition,
    Map<String, Object?> pathParams,
  ) {
    // Check for unknown parameters passed to the endpoint
    for (final paramKey in pathParams.keys) {
      final isParamInTemplate = definition.compiledSegments
          .whereType<ParamSegment>()
          .any((p) => p.name == paramKey);
      if (!isParamInTemplate) {
        throw ArgumentError(
          'Unknown path parameter "$paramKey" provided for endpoint "${definition.id}".',
        );
      }
    }

    final buffer = StringBuffer();

    for (final segment in definition.compiledSegments) {
      if (segment is LiteralSegment) {
        buffer.write(segment.text);
      } else if (segment is ParamSegment) {
        final paramName = segment.name;
        if (!pathParams.containsKey(paramName)) {
          throw ArgumentError(
            'Missing required path parameter "$paramName" for endpoint "${definition.id}".',
          );
        }
        final value = pathParams[paramName];
        if (value == null) {
          throw ArgumentError(
            'Path parameter "$paramName" for endpoint "${definition.id}" cannot be null.',
          );
        }
        buffer.write(Uri.encodeComponent(value.toString()));
      }
    }

    return buffer.toString();
  }

  String _normalizeUrl(
    String baseUrl,
    String servicePath,
    String relativePath,
  ) {
    var base = baseUrl.trim();
    var service = servicePath.trim();
    var relative = relativePath.trim();

    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    if (service.isNotEmpty && !service.startsWith('/')) {
      service = '/$service';
    }
    if (service.endsWith('/')) {
      service = service.substring(0, service.length - 1);
    }

    if (relative.isNotEmpty && !relative.startsWith('/')) {
      relative = '/$relative';
    }

    return '$base$service$relative';
  }
}
