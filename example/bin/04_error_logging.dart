// ignore_for_file: file_names
import 'package:dio_studio/dio_studio.dart';

void main() async {
  // 1. Initialize Studio to log ONLY errors, suppressing successful request details
  final dio = Dio()..enableStudio(logging: Logging.errorsOnly);

  // ignore: avoid_print
  print('=== Run Example 04: Errors Only Logging ===');

  // 2. Successful request: will NOT log to the console
  // ignore: avoid_print
  print('\nTriggering successful request (will be silent)...');
  try {
    await dio.get('https://pub.dev/api/packages/dio_studio');
  } catch (_) {}

  // 3. Failing request: WILL print beautiful red error box log details
  // ignore: avoid_print
  print('\nTriggering failing request (will print log details)...');
  try {
    await dio.get('https://pub.dev/api/non-existent-endpoint');
  } catch (_) {}
}
