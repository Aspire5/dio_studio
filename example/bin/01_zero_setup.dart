// ignore_for_file: file_names
import 'package:dio_more/dio_more.dart';

void main() async {
  // 1. Create standard Dio client and enable DioStudio with zero setup
  final dio = Dio()..enableStudio();

  // ignore: avoid_print
  print('=== Run Example 01: Zero Setup ===');

  // 2. Make an API request to see the beautiful box formatting console logs
  try {
    await dio.get('https://pub.dev/api/packages/dio_more');
  } catch (e) {
    // ignore: avoid_print
    print('Request failed: $e');
  }
}
