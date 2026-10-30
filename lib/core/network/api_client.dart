import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class ApiClient {
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      final baseUrl = StorageService.getBaseUrl();
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = StorageService.getAuthToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            // log error
            return handler.next(e);
          },
        ),
      );
    }
    return _dio!;
  }

  static void resetClient() {
    _dio = null;
  }
}
