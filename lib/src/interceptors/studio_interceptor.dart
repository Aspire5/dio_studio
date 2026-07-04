import 'package:dio/dio.dart';
import '../core/events/request_events.dart';
import '../core/events/response_events.dart';
import '../plugins/plugin_manager.dart';
import '../core/context.dart';

/// Dio interceptor coordinating synchronous pipeline runs.
class StudioInterceptor extends Interceptor {
  /// Create a new [StudioInterceptor] tracking [context] and [pluginManager].
  StudioInterceptor(this._context, this._pluginManager);

  final StudioContext _context;
  final PluginManager _pluginManager;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Lazy Event Bus dispatch
    if (_context.eventBus.hasSubscribers(BeforeRequestEvent)) {
      _context.eventBus.fire(BeforeRequestEvent(options));
    }

    final pipeline = _pluginManager.requestPipeline;
    for (var i = 0; i < pipeline.length; i++) {
      pipeline[i].onRequest(options, handler);
      if (handler.isCompleted) return; // Short-circuit response delivery
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // Lazy Event Bus dispatch
    if (_context.eventBus.hasSubscribers(AfterResponseEvent)) {
      _context.eventBus.fire(AfterResponseEvent(response));
    }

    final pipeline = _pluginManager.responsePipeline;
    for (var i = 0; i < pipeline.length; i++) {
      pipeline[i].onResponse(response, handler);
      if (handler.isCompleted) return;
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final pipeline = _pluginManager.errorPipeline;
    for (var i = 0; i < pipeline.length; i++) {
      pipeline[i].onError(err, handler);
      if (handler.isCompleted) return;
    }

    handler.next(err);
  }
}
