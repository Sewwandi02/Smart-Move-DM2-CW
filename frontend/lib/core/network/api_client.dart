import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';

class ApiClient {
  ApiClient() {
    dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio dio;
  String? _token;

  void setToken(String? token) => _token = token;
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
