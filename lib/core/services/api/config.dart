import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConfig {
  static String baseUrl = dotenv.get(
    'APP_API_BASE_URL',
    fallback: 'http://localhost:8000',
  );
  static String url = '$baseUrl/api';
  static Map<String, String> requestHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile',
  };
  static const Duration requestTimeout = Duration(seconds: 30);
}
