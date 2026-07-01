import 'package:dio_studio/dio_studio.dart';
import 'package:dio_studio/src/core/event_bus.dart';
import 'package:dio_studio/src/core/logger.dart';
import 'package:dio_studio/src/interceptors/studio_interceptor.dart';
import 'package:dio_studio/src/plugins/plugin_manager.dart';
import 'package:test/test.dart';

class StubRequestPlugin extends DioStudioPlugin implements RequestPlugin {
  StubRequestPlugin({required this.onRequestCallback});

  final void Function(RequestOptions options, RequestInterceptorHandler handler) onRequestCallback;

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: 'test.stub',
        name: 'Stub',
        version: '1.0.0',
        author: 'test',
        description: 'test',
        minStudioVersion: '0.0.1',
        supportedDioVersion: '5.x.x',
      );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    onRequestCallback(options, handler);
  }
}

void main() {
  group('StudioInterceptor', () {
    test('forwards to pipeline if enabled', () async {
      final dio = Dio();
      const config = DioStudioConfig(enabled: true);
      final logger = StudioLogger();
      final eventBus = StudioEventBus();
      
      var intercepted = false;
      final stub = StubRequestPlugin(
        onRequestCallback: (options, handler) {
          intercepted = true;
          handler.next(options);
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
        // Ignore real network errors, we just want to check if onRequest fired!
      }

      expect(intercepted, isTrue);
    });

    test('bypasses pipeline if disabled', () async {
      final dio = Dio();
      const config = DioStudioConfig(enabled: false);
      final logger = StudioLogger();
      final eventBus = StudioEventBus();
      
      var intercepted = false;
      final stub = StubRequestPlugin(
        onRequestCallback: (options, handler) {
          intercepted = true;
          handler.next(options);
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
      } catch (_) {}

      expect(intercepted, isFalse);
    });
  });
}
