// ignore_for_file: file_names
import 'package:dio_studio/dio_studio.dart';

void main() async {
  const getPackage = EndpointId('pub.get_package');
  const getPublisher = EndpointId('pub.get_publisher');

  final registry = ApiRegistry.builder()
      .environment(const EnvironmentId('prod'), baseUrl: 'https://pub.dev')
      .service(const ServiceId('pub_api'), path: '/api')
      .endpoint(
        id: getPackage,
        path: '/packages/{name}',
        service: const ServiceId('pub_api'),
      )
      .endpoint(
        id: getPublisher,
        path: '/publishers/{name}',
        service: const ServiceId('pub_api'),
      )
      .build(const EnvironmentId('prod'));

  // 1. Initialize Studio with logOnly filtering.
  // Only the 'getPackage' endpoint logs will print; 'getPublisher' logs will be filtered out.
  final dio = Dio()..enableStudio(registry: registry, logOnly: {getPackage});

  // ignore: avoid_print
  print('=== Run Example 03: Focused Endpoint Logging ===');

  // 2. This request matches 'getPackage' and WILL log to console
  try {
    await dio.get(
      'pub.get_package',
      options: Options()..withPathParams({'name': 'dio'}),
    );
  } catch (_) {}

  // 3. This request matches 'getPublisher' and will NOT log to console
  try {
    await dio.get(
      'pub.get_publisher',
      options: Options()..withPathParams({'name': 'dart.dev'}),
    );
  } catch (_) {}
}
