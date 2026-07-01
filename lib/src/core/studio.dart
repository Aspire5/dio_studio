import 'package:dio/dio.dart';
import 'config.dart';
import 'context.dart';
import 'event_bus.dart';
import 'logger.dart';
import '../interceptors/studio_interceptor.dart';
import '../plugins/plugin.dart';
import '../plugins/plugin_manager.dart';

/// Master manager controlling integration, configuration, and plugins.
class DioStudio {
  DioStudio._(this.dio, this._pluginManager, this._eventBus, this._logger)
      : _context = StudioContext(
          dio: dio,
          config: const DioStudioConfig(enabled: false),
          logger: _logger,
          eventBus: _eventBus,
        ) {
    _interceptor = StudioInterceptor(_context, _pluginManager);
  }

  /// Create a new [DioStudio] controller instance bound to [dio].
  factory DioStudio.create(Dio dio, {List<DioStudioPlugin> plugins = const []}) {
    final eventBus = StudioEventBus();
    final logger = StudioLogger();
    final pluginManager = PluginManager(plugins);
    return DioStudio._(dio, pluginManager, eventBus, logger);
  }

  /// Target HTTP client.
  final Dio dio;

  PluginManager _pluginManager;
  final StudioEventBus _eventBus;
  final StudioLogger _logger;

  final StudioContext _context;
  late StudioInterceptor _interceptor;

  DioStudioConfig _config = const DioStudioConfig(enabled: false);
  bool _attached = false;
  bool _disposed = false;

  /// Retrieves the current configuration options.
  DioStudioConfig get config => _config;

  /// Direct verification check.
  bool get isEnabled => _config.enabled;

  /// Attach the studio interceptor and initialize plugins.
  void enable() {
    if (_disposed) throw StateError('Cannot enable a disposed DioStudio instance.');
    if (_attached) return;

    _config = DioStudioConfig(
      enabled: true,
      enabledFeatures: _config.enabledFeatures,
    );

    _context.config = _config;

    _pluginManager.init(_context);
    _attachInterceptor();
    _pluginManager.enableAll();
    _logger.info('DioStudio successfully enabled.');
  }

  /// Disable all plugins and bypass interceptors.
  void disable() {
    if (_disposed || !_attached) return;

    _config = DioStudioConfig(
      enabled: false,
      enabledFeatures: _config.enabledFeatures,
    );

    _context.config = _config;

    _pluginManager.disableAll();
    _detachInterceptor();
    _logger.info('DioStudio successfully disabled.');
  }

  /// Configure target features.
  void configure(DioStudioConfig config) {
    if (_disposed) throw StateError('Cannot configure a disposed DioStudio instance.');
    _config = config;
    _context.config = _config;
  }

  /// Register custom feature plugins.
  void registerPlugin(DioStudioPlugin plugin) {
    if (_disposed) throw StateError('Cannot register plugins on a disposed instance.');
    if (_config.enabled) {
      throw StateError('Cannot register plugins while DioStudio is active. Disable it first.');
    }

    final existing = <DioStudioPlugin>[];
    existing.addAll(_pluginManager.requestPipeline.cast<DioStudioPlugin>());
    existing.addAll(_pluginManager.responsePipeline.cast<DioStudioPlugin>());
    existing.addAll(_pluginManager.errorPipeline.cast<DioStudioPlugin>());
    
    final Set<DioStudioPlugin> all = {...existing, plugin};
    
    final wasAttached = _attached;
    if (wasAttached) {
      _detachInterceptor();
    }

    // Rebuild manager and interceptor
    _pluginManager.dispose();
    _pluginManager = PluginManager(all.toList());
    _interceptor = StudioInterceptor(_context, _pluginManager);

    if (wasAttached) {
      _attachInterceptor();
    }
  }

  /// Release resources.
  void dispose() {
    if (_disposed) return;
    disable();
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
