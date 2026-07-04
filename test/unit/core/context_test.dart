import 'package:dio_more/dio_more.dart';
import 'package:dio_more/src/core/context.dart';
import 'package:dio_more/src/core/event_bus.dart';
import 'package:dio_more/src/core/logger.dart';
import 'package:test/test.dart';

void main() {
  group('StudioContext', () {
    test('initializes all fields correctly', () {
      final dio = Dio();
      const config = DioStudioConfig();
      final logger = StudioLogger();
      final eventBus = StudioEventBus();

      final context = StudioContext(
        dio: dio,
        config: config,
        logger: logger,
        eventBus: eventBus,
      );

      expect(context.dio, equals(dio));
      expect(context.config, equals(config));
      expect(context.logger, equals(logger));
      expect(context.eventBus, equals(eventBus));
    });
  });
}
