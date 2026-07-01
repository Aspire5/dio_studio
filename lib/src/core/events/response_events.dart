import 'package:dio/dio.dart';
import 'request_events.dart';

/// Fired when an HTTP response is successfully received.
class AfterResponseEvent extends StudioEvent {
  /// Create an [AfterResponseEvent] wrapping [response].
  const AfterResponseEvent(this.response);

  /// Intercepted HTTP response.
  final Response<dynamic> response;
}
