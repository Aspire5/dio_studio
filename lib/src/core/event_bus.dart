import 'dart:async';
import 'events/request_events.dart';

/// Internal event coordination bus utilizing lazy checks to avoid allocations.
class StudioEventBus {
  final _controller = StreamController<StudioEvent>.broadcast();
  final Map<Type, int> _subscribers = {};

  /// Publishes an event to all subscribers if any exist.
  void fire(StudioEvent event) {
    if (hasSubscribers(event.runtimeType)) {
      _controller.add(event);
    }
  }

  /// Subscribes to events of type [T].
  Stream<T> on<T extends StudioEvent>() {
    return _controller.stream
        .where((event) => event is T)
        .cast<T>()
        .transform(StreamTransformer<T, T>.fromHandlers(
          handleData: (data, sink) => sink.add(data),
          handleDone: (sink) => sink.close(),
        ))
        .asBroadcastStream(
          onListen: (_) => _subscribers[T] = (_subscribers[T] ?? 0) + 1,
          onCancel: (_) {
            final count = _subscribers[T] ?? 0;
            if (count > 1) {
              _subscribers[T] = count - 1;
            } else {
              _subscribers.remove(T);
            }
          },
        );
  }

  /// Diagnostic check to avoid event allocation if no listeners exist.
  bool hasSubscribers(Type type) => _subscribers.containsKey(type);

  /// Close the event pipeline.
  void dispose() {
    _controller.close();
    _subscribers.clear();
  }
}
