import 'package:dio_studio/dio_studio.dart';
import 'package:dio_studio/src/plugins/plugin_manager.dart';
import 'package:test/test.dart';

class MockBasePlugin extends DioStudioPlugin {
  const MockBasePlugin({
    required this.id,
    this.depends = const {},
    this.before = const {},
    this.after = const {},
  });

  final String id;
  final Set<String> depends;
  final Set<String> before;
  final Set<String> after;

  @override
  PluginMetadata get metadata => PluginMetadata(
        id: id,
        name: 'Mock $id',
        version: '1.0.0',
        author: 'test',
        description: 'test',
        minStudioVersion: '0.0.1',
        supportedDioVersion: '5.x.x',
      );

  @override
  Set<String> get dependsOn => depends;

  @override
  Set<String> get runBefore => before;

  @override
  Set<String> get runAfter => after;
}

class RequestMockPlugin extends MockBasePlugin implements RequestPlugin {
  const RequestMockPlugin({
    required super.id,
    super.depends,
    super.before,
    super.after,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {}
}

void main() {
  group('PluginManager Sorting', () {
    test('sorts plugins by simple dependsOn rules', () {
      const pluginA = RequestMockPlugin(id: 'A');
      const pluginB = RequestMockPlugin(id: 'B', depends: {'A'});

      // Registration is reversed (B, A)
      final manager = PluginManager([pluginB, pluginA]);
      
      // Should sort as (A, B)
      final sorted = manager.requestPipeline;
      expect(sorted, hasLength(2));
      expect((sorted[0] as DioStudioPlugin).metadata.id, equals('A'));
      expect((sorted[1] as DioStudioPlugin).metadata.id, equals('B'));
    });

    test('resolves topological order with before/after constraints', () {
      const pluginMock = RequestMockPlugin(id: 'mock', before: {'network'});
      const pluginNetwork = RequestMockPlugin(id: 'network');
      const pluginRecorder = RequestMockPlugin(id: 'recorder', after: {'mock'});

      // Register out of order
      final manager = PluginManager([pluginNetwork, pluginRecorder, pluginMock]);

      final pipeline = manager.requestPipeline;
      expect(pipeline, hasLength(3));
      
      final ids = pipeline.cast<MockBasePlugin>().map((p) => p.id).toList();
      
      expect(ids.indexOf('mock'), lessThan(ids.indexOf('network')));
      expect(ids.indexOf('mock'), lessThan(ids.indexOf('recorder')));
    });

    test('throws StateError on circular dependency', () {
      const pluginA = MockBasePlugin(id: 'A', depends: {'B'});
      const pluginB = MockBasePlugin(id: 'B', depends: {'A'});

      expect(() => PluginManager([pluginA, pluginB]), throwsStateError);
    });
  });
}
