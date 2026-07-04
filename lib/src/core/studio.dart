import 'package:dio/dio.dart';
import 'config.dart';
import 'context.dart';
import 'event_bus.dart';
import 'logger.dart';
import '../features/registry/registry_plugin.dart';
import '../features/registry/endpoint.dart';
import '../features/registry/registry.dart';
import '../features/logging/logging_presets.dart';
import '../features/logging/logging_plugin.dart';
import '../interceptors/studio_interceptor.dart';
import '../plugins/plugin.dart';
import '../plugins/plugin_manager.dart';

/// Master manager controlling integration, configuration, and plugins.
class DioStudio {
  DioStudio._(this.dio, this._pluginManager, this._eventBus, this._logger)
      : _config = const DioStudioConfig(),
        _context = StudioContext(
          dio: dio,
          config: const DioStudioConfig(),
          logger: _logger,
          eventBus: _eventBus,
        ) {
    _interceptor = StudioInterceptor(_context, _pluginManager);
  }

  /// Create a new [DioStudio] controller instance bound to [dio].
  factory DioStudio.create(Dio dio) {
    final eventBus = StudioEventBus();
    final logger = StudioLogger();
    final pluginManager = PluginManager(const []);
    return DioStudio._(dio, pluginManager, eventBus, logger);
  }

  /// Target HTTP client.
  final Dio dio;

  PluginManager _pluginManager;
  final StudioEventBus _eventBus;
  final StudioLogger _logger;

  final StudioContext _context;
  late StudioInterceptor _interceptor;

  DioStudioConfig _config;
  bool _initialized = false;
  bool _attached = false;
  bool _disposed = false;

  /// Retrieves the current configuration options.
  DioStudioConfig get config => _config;

  /// Direct verification check if initialized.
  bool get isInitialized => _initialized;

  /// Initialize context bindings, register plugins, and attach interceptor.
  ///
  /// Safe to call multiple times (idempotent).
  void initialize({
    ApiRegistry? registry,
    Logging logging = Logging.all,
    Set<EndpointId> logOnly = const {},
  }) {
    if (_disposed) throw StateError('Cannot initialize a disposed DioStudio instance.');
    if (_initialized) return;
    _initialized = true;

    // Apply configuration
    _config = _config.copyWith(
      registry: registry,
      logging: logging,
      logOnly: logOnly,
    );
    _context.config = _config;

    // Build internal plugins list
    final activePlugins = <DioStudioPlugin>[
      ApiRegistryPlugin(),
    ];

    const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
    const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
    const bool kDebugMode = !kReleaseMode && !kProfileMode;

    if (kDebugMode && logging != Logging.none) {
      activePlugins.add(RequestLoggingPlugin());
    }

    // Rebuild plugin manager and interceptor
    _pluginManager.dispose();
    _pluginManager = PluginManager(activePlugins);
    _interceptor = StudioInterceptor(_context, _pluginManager);

    _pluginManager.init(_context);
    _attachInterceptor();
    _pluginManager.enableAll();
    _logger.info('DioStudio successfully initialized.');
  }

  /// Release resources.
  void dispose() {
    if (_disposed) return;
    _pluginManager.disableAll();
    _detachInterceptor();
    _eventBus.dispose();
    _pluginManager.dispose();
    _disposed = true;
  }

  void _attachInterceptor() {
    if (_attached) return;
    dio.interceptors.add(_interceptor);
    _attached = true;
  }

  void _detachInterceptor() {
    if (!_attached) return;
    dio.interceptors.remove(_interceptor);
    _attached = false;
  }
}
