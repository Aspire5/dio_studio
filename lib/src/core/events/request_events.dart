import 'package:dio/dio.dart';

/// Base class for all internal framework events.
abstract class StudioEvent {
  /// Create a new [StudioEvent].
  const StudioEvent();
}

/// Fired before standard HTTP requests are processed.
class BeforeRequestEvent extends StudioEvent {
  /// Create a [BeforeRequestEvent] tracking [options].
  const BeforeRequestEvent(this.options);

  /// Request configuration options.
  final RequestOptions options;
}
