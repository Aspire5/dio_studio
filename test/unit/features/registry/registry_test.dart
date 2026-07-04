import 'package:dio_more/dio_more.dart';
import 'package:test/test.dart';

void main() {
  group('ApiRegistry and ApiRegistryBuilder', () {
    const envProduction = EnvironmentId('production');
    const envStaging = EnvironmentId('staging');
    const serviceAuth = ServiceId('auth');
    const serviceUser = ServiceId('user');

    test('creates immutable registry with valid inputs', () {
      final registry = ApiRegistry.builder()
          .environment(envProduction, baseUrl: 'https://api.production.com/')
          .environment(envStaging, baseUrl: 'https://api.staging.com')
          .service(serviceAuth, path: 'auth/')
          .service(serviceUser, path: '/user')
          .endpoint(
            id: const EndpointId('auth.login'),
            path: '/login',
            service: serviceAuth,
            timeout: const Duration(seconds: 5),
            requiresAuthentication: false,
          )
          .endpoint(
            id: const EndpointId('user.profile'),
            path: 'profile/:id',
            service: serviceUser,
            requiresAuthentication: true,
          )
          .build(envProduction);

      expect(registry.activeEnvironment, envProduction);
      expect(registry.activeBaseUrl, 'https://api.production.com/');
      expect(registry.getServicePath(serviceAuth), 'auth/');
      expect(registry.getServicePath(serviceUser), '/user');

      final loginDef = registry.endpoints[const EndpointId('auth.login')];
      expect(loginDef, isNotNull);
      expect(loginDef!.pathTemplate, '/login');
      expect(loginDef.service, serviceAuth);
      expect(loginDef.timeout, const Duration(seconds: 5));
      expect(loginDef.requiresAuthentication, isFalse);

      final profileDef = registry.endpoints[const EndpointId('user.profile')];
      expect(profileDef, isNotNull);
      expect(profileDef!.pathTemplate, 'profile/:id');
      expect(profileDef.service, serviceUser);
      expect(profileDef.requiresAuthentication, isTrue);
    });

    test('throws ArgumentError if active environment is not defined', () {
      expect(
        () => ApiRegistry.builder()
            .environment(envStaging, baseUrl: 'https://staging.com')
            .build(envProduction),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError on duplicate endpoint registration', () {
      expect(
        () => ApiRegistry.builder()
            .environment(envProduction, baseUrl: 'https://production.com')
            .service(serviceAuth, path: '/auth')
            .endpoint(
              id: const EndpointId('auth.login'),
              path: '/login',
              service: serviceAuth,
            )
            .endpoint(
              id: const EndpointId('auth.login'),
              path: '/signin',
              service: serviceAuth,
            )
            .build(envProduction),
        throwsArgumentError,
      );
    });

    test(
      'throws ArgumentError if endpoint references unregistered service',
      () {
        expect(
          () => ApiRegistry.builder()
              .environment(envProduction, baseUrl: 'https://production.com')
              .endpoint(
                id: const EndpointId('auth.login'),
                path: '/login',
                service: serviceAuth,
              )
              .build(envProduction),
          throwsArgumentError,
        );
      },
    );

    test(
      'throws ArgumentError on duplicate path template under same service',
      () {
        expect(
          () => ApiRegistry.builder()
              .environment(envProduction, baseUrl: 'https://production.com')
              .service(serviceAuth, path: '/auth')
              .endpoint(
                id: const EndpointId('auth.login'),
                path: '/login',
                service: serviceAuth,
              )
              .endpoint(
                id: const EndpointId('auth.signin'),
                path: '/login',
                service: serviceAuth,
              )
              .build(envProduction),
          throwsArgumentError,
        );
      },
    );

    test(
      'throws ArgumentError on duplicate placeholder parameter name in template',
      () {
        expect(
          () => ApiRegistry.builder()
              .environment(envProduction, baseUrl: 'https://production.com')
              .service(serviceAuth, path: '/auth')
              .endpoint(
                id: const EndpointId('auth.login'),
                path: '/login/:id/profile/:id',
                service: serviceAuth,
              )
              .build(envProduction),
          throwsArgumentError,
        );
      },
    );
  });
}
