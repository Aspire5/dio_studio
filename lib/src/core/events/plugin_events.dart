import '../../plugins/plugin.dart';
import 'request_events.dart';

/// Fired when a plugin changes state.
class PluginStateChangedEvent extends StudioEvent {
  /// Create a [PluginStateChangedEvent] detailing state alterations.
  const PluginStateChangedEvent(this.plugin, this.isEnabled);

  /// Target plugin details.
  final DioStudioPlugin plugin;

  /// Current enabled state.
  final bool isEnabled;
}
