import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_studio/dio_studio.dart';
import 'package:test/test.dart';
import 'package:dio_studio/src/features/logging/log_filter.dart';
import 'package:dio_studio/src/features/logging/log_formatter.dart';
import 'package:dio_studio/src/features/logging/log_writer.dart';

void main() {
  group('Logging Presets', () {
    test('all logs everything', () {
      expect(Logging.all.request, isTrue);
      expect(Logging.all.response, isTrue);
      expect(Logging.all.error, isTrue);
      expect(Logging.all.performance, isTrue);
    });

    test('errorsOnly logs only errors', () {
      expect(Logging.errorsOnly.request, isFalse);
      expect(Logging.errorsOnly.response, isFalse);
      expect(Logging.errorsOnly.error, isTrue);
      expect(Logging.errorsOnly.performance, isFalse);
    });

    test('none logs nothing', () {
      expect(Logging.none.request, isFalse);
      expect(Logging.none.response, isFalse);
      expect(Logging.none.error, isFalse);
      expect(Logging.none.performance, isFalse);
    });
  });

  group('Idempotent Initialization', () {
    test('multiple enableStudio calls are idempotent', () {
      final dio = Dio();
      final initialLength = dio.interceptors.length;

      // First call
      dio.enableStudio();
      expect(dio.interceptors.length, initialLength + 1);

      // Second call (should return immediately as no-op)
      dio.enableStudio();
      expect(dio.interceptors.length, initialLength + 1);

      // Verify studio property returns same controller
      final studio1 = dio.studio;
      final studio2 = dio.studio;
      expect(identical(studio1, studio2), isTrue);
    });
  });

  group('LogFilter', () {
    final configAll = const DioStudioConfig(logging: Logging.all);
    final configErrors = const DioStudioConfig(logging: Logging.errorsOnly);
    final endpointAuth = const EndpointId('auth.login');
    final endpointUser = const EndpointId('user.profile');

    test('respects active categories', () {
      final options = RequestOptions(path: '/login');
      
      expect(LogFilter.shouldLogRequest(options, configAll), isTrue);
      expect(LogFilter.shouldLogResponse(options, configAll), isTrue);
      expect(LogFilter.shouldLogError(options, configAll), isTrue);

      expect(LogFilter.shouldLogRequest(options, configErrors), isFalse);
      expect(LogFilter.shouldLogResponse(options, configErrors), isFalse);
      expect(LogFilter.shouldLogError(options, configErrors), isTrue);
    });

    test('filters via logOnly focus list when populated', () {
      final registry = ApiRegistry.builder()
          .environment(EnvironmentId.development, baseUrl: 'https://dev.com')
          .service(ServiceId('api'), path: '')
          .endpoint(id: endpointAuth, path: '/login', service: ServiceId('api'))
          .endpoint(id: endpointUser, path: '/user', service: ServiceId('api'))
          .build(EnvironmentId.development);

      final configFocused = DioStudioConfig(
        logging: Logging.all,
        logOnly: {endpointAuth},
        registry: registry,
      );

      // Setup RequestOptions with matching registry/endpoint
      final authOptions = RequestOptions(path: 'auth.login')
        ..extra['dio_studio.endpoint_definition'] = registry.endpoints[endpointAuth]
        ..extra['dio_studio.registry'] = registry;

      final userOptions = RequestOptions(path: 'user.profile')
        ..extra['dio_studio.endpoint_definition'] = registry.endpoints[endpointUser]
        ..extra['dio_studio.registry'] = registry;

      final rawOptions = RequestOptions(path: '/some-other-raw-path');

      // Auth endpoint is in logOnly focus set -> logged
      expect(LogFilter.shouldLogRequest(authOptions, configFocused), isTrue);

      // User endpoint is NOT in logOnly focus set -> suppressed
      expect(LogFilter.shouldLogRequest(userOptions, configFocused), isFalse);

      // Raw endpoint bypassed registry -> suppressed when focus list is populated
      expect(LogFilter.shouldLogRequest(rawOptions, configFocused), isFalse);
    });
  });

  group('LogFormatter and Size Limits', () {
    test('formats payload under 100 KB', () {
      final options = RequestOptions(path: '/api', data: {'name': 'Alice'});
      final output = LogFormatter.formatRequest(options, 1);
      
      expect(output, contains('name'));
      expect(output, contains('Alice'));
      expect(output, contains('┌── [Req#001] GET /api'));
    });

    test('omits payload over 100 KB', () {
      final hugeData = 'x' * (101 * 1024); // 101 KB
      final options = RequestOptions(path: '/api', data: hugeData);
      final output = LogFormatter.formatRequest(options, 2);

      expect(output, contains('[Body omitted: size is 101.0 KB, exceeds maximum print threshold of 100 KB]'));
      expect(output, isNot(contains('xxxxx')));
    });

    test('summarizes multipart form data', () {
      final formData = FormData.fromMap({
        'name': 'Bob',
        'file': MultipartFile.fromBytes([1, 2, 3, 4], filename: 'test.png'),
      });
      final options = RequestOptions(path: '/upload', data: formData);
      final output = LogFormatter.formatRequest(options, 3);

      expect(output, contains('Multipart Request'));
      expect(output, contains('- Fields: 1'));
      expect(output, contains('name: Bob'));
      expect(output, contains('- Files: 1'));
      expect(output, contains('test.png'));
    });
  });

  group('LogWriter', () {
    test('splits lines and prints individually', () {
      final printedLines = <String>[];
      runZoned(() {
        LogWriter.printLog('line1\nline2\nline3');
      }, zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printedLines.add(line);
        },
      ));

      expect(printedLines, ['line1', 'line2', 'line3']);
    });
  });
}
