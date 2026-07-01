import 'package:dio/dio.dart';
import 'request_events.dart';

/// Fired when a network request is throttled or latency is injected.
class ConnectionThrottledEvent extends StudioEvent {
  /// Create a [ConnectionThrottledEvent] wrapping options and duration.
  const ConnectionThrottledEvent(this.options, this.duration);

  /// Target request options.
  final RequestOptions options;

  /// Latency duration injected.
  final Duration duration;
}
