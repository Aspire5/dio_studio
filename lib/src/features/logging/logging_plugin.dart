import 'package:dio/dio.dart';
import '../../core/context.dart';
import '../../plugins/plugin.dart';
import 'log_filter.dart';
import 'log_formatter.dart';
import 'log_writer.dart';

/// Built-in console logging plugin for dio_more.
///
/// Hooks into request, response, and error execution phases, tracking correlation IDs
/// and printing visual debug blocks in the IDE terminal.
class RequestLoggingPlugin extends DioStudioPlugin
    implements RequestPlugin, ResponsePlugin, ErrorPlugin, LifecyclePlugin {
  /// Create a new [RequestLoggingPlugin] instance.
  RequestLoggingPlugin();

  late final StudioContext _context;
  int _transactionCounter = 0;

  // Correlation extra keys
  static const _requestIdKey = 'dio_more.logging.request_id';
  static const _startTimeKey = 'dio_more.logging.start_time';

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'dio_more.logging',
    name: 'Request Logging Plugin',
    version: '0.9.0',
    author: 'Antigravity Team',
    description:
        'Formatted Unicode debug logging for network requests, responses, and errors.',
    minStudioVersion: '0.9.0',
    supportedDioVersion: '5.x.x',
  );

  @override
  Set<String> get runAfter => const {'dio_more.registry'};

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
    final reqId = ++_transactionCounter;
    options.extra[_requestIdKey] = reqId;
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    if (LogFilter.shouldLogRequest(options, _context.config)) {
      final logText = LogFormatter.formatRequest(options, reqId);
      LogWriter.printLog(logText);
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    final reqId = options.extra[_requestIdKey] as int?;

    if (reqId != null &&
        LogFilter.shouldLogResponse(options, _context.config)) {
      final startTime = options.extra[_startTimeKey] as int?;
      final duration = startTime != null
          ? Duration(
              milliseconds: DateTime.now().millisecondsSinceEpoch - startTime,
            )
          : null;

      final logText = LogFormatter.formatResponse(response, reqId, duration);
      LogWriter.printLog(logText);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final reqId = options.extra[_requestIdKey] as int?;

    if (reqId != null && LogFilter.shouldLogError(options, _context.config)) {
      final startTime = options.extra[_startTimeKey] as int?;
      final duration = startTime != null
          ? Duration(
              milliseconds: DateTime.now().millisecondsSinceEpoch - startTime,
            )
          : null;

      final logText = LogFormatter.formatError(err, reqId, duration);
      LogWriter.printLog(logText);
    }
  }
}
