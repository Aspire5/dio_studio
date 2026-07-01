/// Internal diagnostic logger tier.
enum StudioLogLevel {
  /// Debug tracking information.
  debug,

  /// General operational flow logs.
  info,

  /// Non-fatal warnings.
  warning,

  /// System failures.
  error,
}

/// Logging callback definition for custom redirect handlers.
typedef LoggerCallback = void Function(StudioLogLevel level, String message, Object? error, StackTrace? stackTrace);

/// Internal diagnostics logging utility for [DioStudio].
class StudioLogger {
  /// Create a new [StudioLogger] interface.
  StudioLogger({
    LoggerCallback? onLog,
  }) : _onLog = onLog;

  final LoggerCallback? _onLog;

  /// Log debug telemetry.
  void debug(String message) => _log(StudioLogLevel.debug, message);

  /// Log general lifecycle information.
  void info(String message) => _log(StudioLogLevel.info, message);

  /// Log warning signs.
  void warning(String message) => _log(StudioLogLevel.warning, message);

  /// Log system failures.
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(StudioLogLevel.error, message, error, stackTrace);

  void _log(
    StudioLogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (_onLog != null) {
      _onLog(level, message, error, stackTrace);
    } else {
      // Default fallback console print
      final tag = '[DioStudio:${level.name.toUpperCase()}]';
      final formatted = '$tag $message';
      if (error != null) {
        // ignore: avoid_print
        print('$formatted\nError: $error${stackTrace != null ? '\n$stackTrace' : ''}');
      } else {
        // ignore: avoid_print
        print(formatted);
      }
    }
  }
}
