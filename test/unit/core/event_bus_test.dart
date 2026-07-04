import 'package:dio_more/src/core/event_bus.dart';
import 'package:dio_more/src/core/events/request_events.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';

void main() {
  group('StudioEventBus', () {
    test('lazy checking returns false if no subscribers', () {
      final eventBus = StudioEventBus();
      expect(eventBus.hasSubscribers(BeforeRequestEvent), isFalse);
    });

    test('lazy checking returns true when subscribed', () async {
      final eventBus = StudioEventBus();
      final subscription = eventBus.on<BeforeRequestEvent>().listen((event) {});

      expect(eventBus.hasSubscribers(BeforeRequestEvent), isTrue);

      await subscription.cancel();
      expect(eventBus.hasSubscribers(BeforeRequestEvent), isFalse);
    });

    test('fires events only to correct subscribers', () async {
      final eventBus = StudioEventBus();
      final events = <BeforeRequestEvent>[];
      final subscription = eventBus.on<BeforeRequestEvent>().listen(events.add);

      final mockEvent = BeforeRequestEvent(RequestOptions(path: '/test'));
      eventBus.fire(mockEvent);

      // Verify delivery
      await pumpEventQueue();
      expect(events, hasLength(1));
      expect(events.first.options.path, equals('/test'));

      await subscription.cancel();
    });
  });
}
