// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_lost/core/api/apiendpoints.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  // Singleton pattern
  DioClient._internal() {
    _dio = Dio();
    _setupDio();
  }

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  void _setupDio() {
    // Configure base options
    _dio.options.baseUrl = ApiEndpoints.fullBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Set default headers
    _dio.options.headers.addAll(ApiEndpoints.defaultHeaders);

    // Debug information (only in debug mode)
    if (kDebugMode) {
      debugPrint('DioClient initialized with base URL: ${_dio.options.baseUrl}');
      debugPrint('Default headers: ${_dio.options.headers}');
    }

    // Add interceptors
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('REQUEST: ${options.method} ${options.uri}');
            debugPrint('Headers: ${options.headers}');
            debugPrint('Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            debugPrint('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('ERROR: ${error.message}');
            debugPrint('Response: ${error.response?.data}');
            debugPrint('Status Code: ${error.response?.statusCode}');
          }
          handler.next(error);
        },
      ),
    );

    // Add pretty logging interceptor for debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  // Get Dio instance
  Dio get dio => _dio;

  // Update base URL if needed
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    if (kDebugMode) {
      debugPrint('Base URL updated to: $newBaseUrl');
    }
  }

  // Add custom headers
  void addHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
    if (kDebugMode) {
      debugPrint('Headers updated: $headers');
    }
  }

  // Remove specific header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
    if (kDebugMode) {
      debugPrint('Header removed: $key');
    }
  }

  // Clear all custom headers (keep defaults)
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll(ApiEndpoints.defaultHeaders);
    if (kDebugMode) {
      debugPrint('Headers reset to defaults');
    }
  }
}
