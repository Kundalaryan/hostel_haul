import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../main.dart'; // Import main to access navigatorKey

class ApiClient {
  static const String baseUrl = 'http://20.197.4.13/api/';

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

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // --- CATCH 401 (UNAUTHORIZED) ---
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {

          // 1. Delete the bad token
          await _storage.delete(key: 'jwt_token');

          // 2. Use the Global Key to navigate safely without 'context'
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}