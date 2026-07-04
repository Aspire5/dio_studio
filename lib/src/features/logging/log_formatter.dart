import 'dart:convert';
import 'package:dio/dio.dart';
import '../registry/registry.dart';
import '../registry/endpoint.dart';

/// Formatting engine for generating premium Unicode terminal logs.
class LogFormatter {
  // ANSI terminal styling escape codes
  static const _reset = '\x1B[0m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _cyan = '\x1B[36m';
  static const _gray = '\x1B[90m';

  /// Format requests into Unicode box blocks.
  static String formatRequest(RequestOptions options, int reqId) {
    final sb = StringBuffer();
    final url = options.uri.toString();
    final method = options.method;

    // Header segment
    sb.writeln('$_blue┌── [Req#${_padId(reqId)}] $method $url$_reset');

    // Endpoint identification registry info
    final definition = options.extra[StudioExtra.endpointDefinition];
    final registry = options.extra[StudioExtra.registry];
    if (definition is EndpointDefinition && registry is ApiRegistry) {
      final env = registry.activeEnvironment.value;
      sb.writeln('$_blue│$_reset   Endpoint: ${definition.id.value} (Environment: $env)');
    }

    // Headers
    sb.writeln('$_blue│$_reset   Headers:');
    final formattedHeaders = _formatHeaders(options.headers);
    if (formattedHeaders.isNotEmpty) {
      sb.writeln(formattedHeaders);
    }

    // Body
    sb.writeln('$_blue│$_reset   Body:');
    if (options.data is FormData) {
      final formData = options.data as FormData;
      sb.writeln(_indentBody(_formatFormDataSummary(formData)));
    } else {
      final info = _parsePayload(options.data);
      sb.writeln(_indentBody(info.content));
    }

    sb.write('$_blue└──────────────────────────────────────────────────────────$_reset');
    return sb.toString();
  }

  /// Format responses into Unicode box blocks.
  static String formatResponse(Response<dynamic> response, int reqId, Duration? duration) {
    final sb = StringBuffer();
    final statusCode = response.statusCode ?? 0;
    final statusMessage = response.statusMessage ?? 'Unknown';
    final elapsedStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';

    // Color code based on response status
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final color = isSuccess ? _green : _yellow;

    // Header segment
    sb.writeln('$color┌── [Res#${_padId(reqId)}] $statusCode $statusMessage$elapsedStr$_reset');

    // Headers
    sb.writeln('$color│$_reset   Headers:');
    final formattedHeaders = _formatHeaders(response.headers.map);
    if (formattedHeaders.isNotEmpty) {
      sb.writeln(formattedHeaders);
    }

    // Body
    sb.writeln('$color│$_reset   Body:');
    final info = _parsePayload(response.data);
    sb.writeln(_indentBody(info.content));

    // Performance info
    if (duration != null) {
      sb.writeln('$color│$_reset   Performance:');
      sb.writeln('$color│$_reset     Duration: ${duration.inMilliseconds} ms');
      sb.writeln('$color│$_reset     Payload Size: ${_formatSize(info.byteLength)}');
    }

    sb.write('$color└──────────────────────────────────────────────────────────$_reset');
    return sb.toString();
  }

  /// Format errors and failures into Unicode box blocks.
  static String formatError(DioException error, int reqId, Duration? duration) {
    final sb = StringBuffer();
    final url = error.requestOptions.uri.toString();
    final method = error.requestOptions.method;
    final elapsedStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    final statusCode = error.response?.statusCode;
    final statusMessage = error.response?.statusMessage ?? 'Unknown';

    // Header segment
    sb.writeln('$_red┌── [Err#${_padId(reqId)}] $method $url$elapsedStr$_reset');

    if (statusCode != null) {
      sb.writeln('$_red│$_reset   HTTP Status: $statusCode $statusMessage');
    }

    // Error details
    sb.writeln('$_red│$_reset   Type: ${error.type}');
    sb.writeln('$_red│$_reset   Message: ${error.message}');
    if (error.error != null) {
      sb.writeln('$_red│$_reset   Underlying: ${error.error}');
    }

    // Response Body (if present)
    if (error.response?.data != null) {
      sb.writeln('$_red│$_reset   Response Body:');
      final info = _parsePayload(error.response?.data);
      sb.writeln(_indentBody(info.content));
    }

    sb.write('$_red└──────────────────────────────────────────────────────────$_reset');
    return sb.toString();
  }

  static String _padId(int id) {
    return id.toString().padLeft(3, '0');
  }

  static String _formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return '│     None';
    final sb = StringBuffer();
    headers.forEach((key, value) {
      sb.writeln('│     $key: $value');
    });
    final res = sb.toString();
    return res.isNotEmpty ? res.substring(0, res.length - 1) : '';
  }

  static String _indentBody(String content) {
    if (content.isEmpty) return '│     [Empty Body]';
    return content.split('\n').map((line) => '│     $line').join('\n');
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _formatFormDataSummary(FormData formData) {
    final sb = StringBuffer();
    sb.writeln('Multipart Request');
    sb.writeln('- Fields: ${formData.fields.length}');
    for (final field in formData.fields) {
      sb.writeln('  * ${field.key}: ${field.value}');
    }
    sb.writeln('- Files: ${formData.files.length}');
    var totalBytes = 0;
    for (final file in formData.files) {
      final len = file.value.length;
      totalBytes += len;
      sb.writeln('  * ${file.key}: ${file.value.filename ?? "Unnamed"} ($len bytes)');
    }
    sb.write('- Approximate Total Size: ${_formatSize(totalBytes)}');
    return sb.toString();
  }

  static _PayloadInfo _parsePayload(dynamic data) {
    if (data == null) {
      return const _PayloadInfo('', 0, false);
    }
    String str = '';
    if (data is String) {
      str = data;
    } else {
      try {
        str = json.encode(data);
      } catch (_) {
        str = data.toString();
      }
    }
    final bytes = utf8.encode(str).length;
    if (bytes > 100 * 1024) {
      return _PayloadInfo(
        '[Body omitted: size is ${_formatSize(bytes)}, exceeds maximum print threshold of 100 KB]',
        bytes,
        true,
      );
    }

    try {
      final decoded = json.decode(str);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      return _PayloadInfo(pretty, bytes, false);
    } catch (_) {
      return _PayloadInfo(str, bytes, false);
    }
  }
}

class _PayloadInfo {
  const _PayloadInfo(this.content, this.byteLength, this.isOmitted);
  final String content;
  final int byteLength;
  final bool isOmitted;
}
