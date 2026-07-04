import 'package:dio_more/dio_more.dart';
import 'package:dio_more/src/core/context.dart';
import 'package:dio_more/src/core/event_bus.dart';
import 'package:dio_more/src/core/logger.dart';
import 'package:dio_more/src/interceptors/studio_interceptor.dart';
import 'package:dio_more/src/plugins/plugin.dart';
import 'package:dio_more/src/plugins/plugin_manager.dart';
import 'package:test/test.dart';

class StubRequestPlugin extends DioStudioPlugin implements RequestPlugin {
  StubRequestPlugin({required this.onRequestCallback, String id = 'test.stub'})
    : metadata = PluginMetadata(
        id: id,
        name: 'Stub',
        version: '0.9.0',
        author: 'test',
        description: 'test',
        minStudioVersion: '0.0.1',
        supportedDioVersion: '5.x.x',
      );

  final void Function(RequestOptions options, RequestInterceptorHandler handler)
  onRequestCallback;

  @override
  final PluginMetadata metadata;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    onRequestCallback(options, handler);
  }
}

void main() {
  group('StudioInterceptor', () {
    test('forwards to pipeline if attached', () async {
      final dio = Dio();
      const config = DioStudioConfig();
      final logger = StudioLogger();
      final eventBus = StudioEventBus();

      var intercepted = false;
      final stub = StubRequestPlugin(
        onRequestCallback: (options, handler) {
          intercepted = true;
          // In dio_more, plugins do not need to call handler.next
        },
      );

      final pluginManager = PluginManager([stub]);
      final context = StudioContext(
        dio: dio,
        config: config,
        logger: logger,
        eventBus: eventBus,
      );

      pluginManager.init(context);
      final interceptor = StudioInterceptor(context, pluginManager);
      dio.interceptors.add(interceptor);

      try {
        await dio.get('https://example.com');
      } catch (_) {
        // Ignore real network errors
      }

      expect(intercepted, isTrue);
    });

    test(
      'runs multiple request plugins sequentially and does not skip subsequent plugins',
      () async {
        final dio = Dio();
        const config = DioStudioConfig();
        final logger = StudioLogger();
        final eventBus = StudioEventBus();

        final list = <int>[];

        final stub1 = StubRequestPlugin(
          id: 'test.stub1',
          onRequestCallback: (options, handler) {
            list.add(1);
          },
        );

        final stub2 = StubRequestPlugin(
          id: 'test.stub2',
          onRequestCallback: (options, handler) {
            list.add(2);
          },
        );

        final pluginManager = PluginManager([stub1, stub2]);
        final context = StudioContext(
          dio: dio,
          config: config,
          logger: logger,
          eventBus: eventBus,
        );

        pluginManager.init(context);
        final interceptor = StudioInterceptor(context, pluginManager);
        dio.interceptors.add(interceptor);

        try {
          await dio.get('https://example.com');
        } catch (_) {}

        expect(list, equals([1, 2]));
      },
    );
  });
}
