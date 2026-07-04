import 'package:dio_studio/dio_studio.dart';
import 'package:dio_studio/src/features/registry/endpoint.dart';
import 'package:test/test.dart';

void main() {
  group('ApiRegistryPlugin Resolution', () {
    const envProduction = EnvironmentId('production');
    const serviceUser = ServiceId('user');
    const endpointProfile = EndpointId('user.profile');
    const endpointUpdate = EndpointId('user.update');

    late Dio dio;
    late ApiRegistry registry;

    setUp(() {
      dio = Dio();
      registry = ApiRegistry.builder()
          .environment(envProduction, baseUrl: 'https://api.production.com/')
          .service(serviceUser, path: 'user/')
          .endpoint(
            id: endpointProfile,
            path: '/profile/:id',
            service: serviceUser,
            timeout: const Duration(seconds: 4),
            defaultHeaders: {'X-Default-Header': 'studio-value'},
          )
          .endpoint(
            id: endpointUpdate,
            path: '/update/:id/type/:type',
            service: serviceUser,
          )
          .build(envProduction);

      dio.enableStudio(registry: registry);
    });

    test(
      'resolves registered endpoint cleanly with parameters and normalization',
      () async {
        var requestFired = false;
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requestFired = true;
              expect(
                options.path,
                'https://api.production.com/user/profile/123',
              );
              expect(options.baseUrl, '');
              expect(options.sendTimeout, const Duration(seconds: 4));
              expect(options.headers['X-Default-Header'], 'studio-value');

              // Check Plugin Integration Contract
              final epDef =
                  options.extra['dio_studio.endpoint_definition']
                      as EndpointDefinition?;
              expect(epDef, isNotNull);
              expect(epDef!.id, endpointProfile);

              final pathParams =
                  options.extra['dio_studio.path_parameters']
                      as Map<String, Object?>?;
              expect(pathParams, isNotNull);
              expect(pathParams!['id'], 123);

              // Return mock response to prevent actual network request
              handler.resolve(
                Response(requestOptions: options, statusCode: 200),
              );
            },
          ),
        );

        final response = await dio.get(
          endpointProfile,
          options: Options().withPathParams({'id': 123}),
        );

        expect(response.statusCode, 200);
        expect(requestFired, isTrue);
      },
    );

    test('resolves multiple parameters in endpoint path', () async {
      var requestFired = false;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestFired = true;
            expect(
              options.path,
              'https://api.production.com/user/update/456/type/admin',
            );
            handler.resolve(Response(requestOptions: options, statusCode: 200));
          },
        ),
      );

      final response = await dio.get(
        endpointUpdate,
        options: Options().withPathParams({'id': 456, 'type': 'admin'}),
      );

      expect(response.statusCode, 200);
      expect(requestFired, isTrue);
    });

    test('throws ArgumentError on missing required parameter', () async {
      expect(
        () => dio.get(endpointProfile, options: Options().withPathParams({})),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ArgumentError>().having(
              (ae) => ae.message,
              'message',
              contains('Missing required path parameter "id"'),
            ),
          ),
        ),
      );
    });

    test('throws ArgumentError on unknown path parameters', () async {
      expect(
        () => dio.get(
          endpointProfile,
          options: Options().withPathParams({'id': 123, 'extra': 'value'}),
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ArgumentError>().having(
              (ae) => ae.message,
              'message',
              contains('Unknown path parameter "extra"'),
            ),
          ),
        ),
      );
    });

    test(
      'optional adoption: standard raw path bypasses registry cleanly',
      () async {
        var requestFired = false;
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requestFired = true;
              expect(options.path, '/custom-raw-endpoint');
              expect(options.baseUrl, '');
              expect(options.extra['dio_studio.endpoint_definition'], isNull);
              handler.resolve(
                Response(requestOptions: options, statusCode: 200),
              );
            },
          ),
        );

        final response = await dio.get('/custom-raw-endpoint');

        expect(response.statusCode, 200);
        expect(requestFired, isTrue);
      },
    );
  });
}
