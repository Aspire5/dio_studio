/// dio_studio - A developer toolkit built on top of Dio.
///
/// This package extends Dio with tools for API mocking, recording, replay,
/// network simulation, testing, and request inspection.
///
/// dio_studio does not replace Dio. It attaches to an existing Dio instance
/// and adds developer experience features on top.
///
/// See the docs/ directory for detailed documentation.
library;

// Re-export standard Dio HTTP package classes so users have a drop-in experience.
export 'package:dio/dio.dart';

// Core public configurations and controllers
export 'src/core/config.dart' show DioStudioConfig, StudioFeature, StudioFeatures;
export 'src/core/context.dart' show StudioContext;
export 'src/core/storage.dart' show StorageAdapter;
export 'src/core/studio.dart' show DioStudio;

// Extensions
export 'src/extensions/dio_extensions.dart' show DioStudioExtension;

// Logging Features
export 'src/features/logging/logging_presets.dart' show Logging;

// Plugin APIs
export 'src/plugins/plugin.dart'
    show
        DioStudioPlugin,
        PluginMetadata,
        RequestPlugin,
        ResponsePlugin,
        ErrorPlugin,
        LifecyclePlugin;

// Registry Features
export 'src/features/registry/endpoint.dart' show EndpointId, EndpointDefinition;
export 'src/features/registry/registry.dart'
    show
        EnvironmentId,
        ServiceId,
        ApiRegistry,
        ApiRegistryBuilder,
        OptionsStudioExtension;

