import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Replace with your actual Spring Boot URL
  // If using Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://10.0.2.2:8080/api/';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient()
      : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  )),
        _storage = const FlutterSecureStorage() {

    // Add Interceptor for JWT
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Get token from secure storage
        final token = await _storage.read(key: 'jwt_token');

        // 2. If token exists, attach it to Header
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options); // Continue the request
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized (Token expired) here in the future
        return handler.next(e);
      },
    ));
  }

  // Expose the Dio instance to be used by Repositories
  Dio get client => _dio;
}