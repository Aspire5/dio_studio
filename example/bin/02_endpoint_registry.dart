// ignore_for_file: file_names
import 'package:dio_studio/dio_studio.dart';

void main() async {
  // 1. Define logical EndpointIds
  const getPackage = EndpointId('pub.get_package');

  // 2. Build the API Registry compiling path templates
  final registry = ApiRegistry.builder()
      .environment(
        const EnvironmentId('production'),
        baseUrl: 'https://pub.dev',
      )
      .service(const ServiceId('pub_api'), path: '/api')
      .endpoint(
        id: getPackage,
        path: '/packages/{name}',
        service: const ServiceId('pub_api'),
      )
      .build(const EnvironmentId('production'));

  // 3. Enable Studio with the Registry attached
  final dio = Dio()..enableStudio(registry: registry);

  // ignore: avoid_print
  print('=== Run Example 02: Endpoint Registry ===');

  // 4. Trigger request using registry parameters resolution
  try {
    await dio.get(
      'pub.get_package',
      options: Options()..withPathParams({'name': 'dio_studio'}),
    );
  } catch (e) {
    // ignore: avoid_print
    print('Request failed: $e');
  }
}
