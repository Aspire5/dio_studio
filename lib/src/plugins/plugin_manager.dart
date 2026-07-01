import '../core/context.dart';
import '../core/events/plugin_events.dart';
import 'plugin.dart';

/// Topological sorter and execution manager for active plugins.
class PluginManager {
  /// Create a new [PluginManager] sorting target [plugins].
  PluginManager(List<DioStudioPlugin> plugins) {
    _initializePipelines(plugins);
  }

  final List<DioStudioPlugin> _allPlugins = [];
  final List<RequestPlugin> _requestPipeline = [];
  final List<ResponsePlugin> _responsePipeline = [];
  final List<ErrorPlugin> _errorPipeline = [];
  final List<LifecyclePlugin> _lifecyclePipeline = [];

  bool _initialized = false;
  late final StudioContext _context;

  /// Flat execution pipeline for request modification.
  List<RequestPlugin> get requestPipeline => _requestPipeline;

  /// Flat execution pipeline for response modification.
  List<ResponsePlugin> get responsePipeline => _responsePipeline;

  /// Flat execution pipeline for error handling.
  List<ErrorPlugin> get errorPipeline => _errorPipeline;

  /// Initialize context bindings across lifecycle-enabled plugins.
  void init(StudioContext context) {
    if (_initialized) return;
    _context = context;
    _initialized = true;

    for (var i = 0; i < _lifecyclePipeline.length; i++) {
      try {
        _lifecyclePipeline[i].onInit(_context);
      } catch (e, stack) {
        _context.logger.error('Failed to initialize plugin: ${_lifecyclePipeline[i].runtimeType}', e, stack);
      }
    }
  }

  /// Enable all plugins.
  void enableAll() {
    for (var i = 0; i < _lifecyclePipeline.length; i++) {
      try {
        _lifecyclePipeline[i].onEnable();
        _context.eventBus.fire(PluginStateChangedEvent(_lifecyclePipeline[i] as DioStudioPlugin, true));
      } catch (e, stack) {
        _context.logger.error('Failed to enable plugin: ${_lifecyclePipeline[i].runtimeType}', e, stack);
      }
    }
  }

  /// Disable all plugins.
  void disableAll() {
    for (var i = 0; i < _lifecyclePipeline.length; i++) {
      try {
        _lifecyclePipeline[i].onDisable();
        _context.eventBus.fire(PluginStateChangedEvent(_lifecyclePipeline[i] as DioStudioPlugin, false));
      } catch (e, stack) {
        _context.logger.error('Failed to disable plugin: ${_lifecyclePipeline[i].runtimeType}', e, stack);
      }
    }
  }

  /// Release plugin resources.
  void dispose() {
    for (var i = 0; i < _lifecyclePipeline.length; i++) {
      try {
        _lifecyclePipeline[i].onDispose();
      } catch (e, stack) {
        if (_initialized) {
          _context.logger.error('Failed to dispose plugin: ${_lifecyclePipeline[i].runtimeType}', e, stack);
        }
      }
    }
    _allPlugins.clear();
    _requestPipeline.clear();
    _responsePipeline.clear();
    _errorPipeline.clear();
    _lifecyclePipeline.clear();
  }

  void _initializePipelines(List<DioStudioPlugin> plugins) {
    final sorted = _sortPlugins(plugins);

    for (var i = 0; i < sorted.length; i++) {
      final plugin = sorted[i];
      _allPlugins.add(plugin);

      if (plugin is RequestPlugin) {
        _requestPipeline.add(plugin as RequestPlugin);
      }
      if (plugin is ResponsePlugin) {
        _responsePipeline.add(plugin as ResponsePlugin);
      }
      if (plugin is ErrorPlugin) {
        _errorPipeline.add(plugin as ErrorPlugin);
      }
      if (plugin is LifecyclePlugin) {
        _lifecyclePipeline.add(plugin as LifecyclePlugin);
      }
    }
  }

  List<DioStudioPlugin> _sortPlugins(List<DioStudioPlugin> plugins) {
    if (plugins.isEmpty) return const [];

    final Map<String, DioStudioPlugin> pluginMap = {
      for (final p in plugins) p.metadata.id: p
    };

    // Build dependency graph
    final Map<String, Set<String>> graph = {
      for (final p in plugins) p.metadata.id: <String>{}
    };

    for (final p in plugins) {
      final id = p.metadata.id;

      // 1. dependsOn constraints
      for (final dep in p.dependsOn) {
        if (!pluginMap.containsKey(dep)) {
          throw StateError('Missing required dependency "$dep" for plugin "$id"');
        }
        graph[dep]!.add(id); // dep runs before id (dep -> id edge)
      }

      // 2. runAfter constraints
      for (final target in p.runAfter) {
        if (pluginMap.containsKey(target)) {
          graph[target]!.add(id); // target runs before id (target -> id edge)
        }
      }

      // 3. runBefore constraints
      for (final target in p.runBefore) {
        if (pluginMap.containsKey(target)) {
          graph[id]!.add(target); // id runs before target (id -> target edge)
        }
      }
    }

    // Topological Sort (Kahn's algorithm)
    final Map<String, int> inDegree = {
      for (final id in graph.keys) id: 0
    };

    for (final edges in graph.values) {
      for (final target in edges) {
        inDegree[target] = (inDegree[target] ?? 0) + 1;
      }
    }

    final List<String> queue = [];
    // Sort keys alphabetically to keep sorting stable and deterministic
    final sortedIds = inDegree.keys.toList()..sort();
    for (final id in sortedIds) {
      if (inDegree[id] == 0) {
        queue.add(id);
      }
    }

    final List<DioStudioPlugin> result = [];
    while (queue.isNotEmpty) {
      // Sort queue to keep sorting stable and deterministic
      queue.sort();
      final current = queue.removeAt(0);
      result.add(pluginMap[current]!);

      final edges = graph[current] ?? const {};
      for (final target in edges) {
        inDegree[target] = (inDegree[target] ?? 0) - 1;
        if (inDegree[target] == 0) {
          queue.add(target);
        }
      }
    }

    if (result.length != plugins.length) {
      throw StateError('Circular dependency detected in plugin registration configuration.');
    }

    return result;
  }
}
