import '../config.dart';
import 'request_events.dart';

/// Fired when the master [DioStudio] instance initializes.
class StudioInitializedEvent extends StudioEvent {
  /// Create a [StudioInitializedEvent].
  const StudioInitializedEvent();
}

/// Fired when configuration changes occur dynamically.
class ConfigChangedEvent extends StudioEvent {
  /// Create a [ConfigChangedEvent] representing state modifications.
  const ConfigChangedEvent(this.oldConfig, this.newConfig);

  /// Previous configuration state.
  final DioStudioConfig oldConfig;

  /// Fresh configuration state.
  final DioStudioConfig newConfig;
}
