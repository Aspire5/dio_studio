import 'package:dio_studio/dio_studio.dart';

/// A simple custom plugin that logs outgoing requests to demonstrate the plugin system.
class LoggerPlugin extends DioStudioPlugin implements RequestPlugin, LifecyclePlugin {
  const LoggerPlugin();

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: 'example.logger',
        name: 'Console Request Logger',
        version: '1.0.0',
        author: 'dio_studio contributors',
        description: 'Logs outgoing request methods and URIs to the console.',
        minStudioVersion: '0.0.1',
        supportedDioVersion: '5.x.x',
      );

  @override
  void onInit(StudioContext context) {
    context.logger.info('LoggerPlugin initialized inside example.');
  }

  @override
  void onEnable() {
    // ignore: avoid_print
    print('[ExampleLogger] Plugin activated.');
  }

  @override
  void onDisable() {
    // ignore: avoid_print
    print('[ExampleLogger] Plugin deactivated.');
  }

  @override
  void onDispose() {}

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[ExampleLogger] Intercepted Request: ${options.method} -> ${options.uri}');
    handler.next(options);
  }
}

void main() async {
  // Create a standard Dio client
  final dio = Dio();

  // ignore: avoid_print
  print('=== Initializing dio_studio example ===');

  // Initialize and enable studio with our LoggerPlugin
  dio.enableStudio(
    config: const DioStudioConfig(
      enabled: true,
      enabledFeatures: {StudioFeatures.mock},
    ),
    plugins: [
      const LoggerPlugin(),
    ],
  );

  // Make a simple mock request to verify interception works
  try {
    // ignore: avoid_print
    print('\nMaking test request...');
    await dio.get('https://pub.dev/packages/dio_studio');
  } catch (e) {
    // ignore: avoid_print
    print('Request failed with error: $e');
  }

  // Disable the studio
  dio.studio.disable();
  
  // ignore: avoid_print
  print('\n=== Example completed successfully ===');
}
