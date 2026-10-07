// Handles all HTTP communication between the Flutter app and the backend.
// It creates a reusable Dio client, attaches the JWT token when available, and
// centralises the logic needed to call protected endpoints.
import 'package:dio/dio.dart';
import 'api_config.dart';

// ApiClient is the app's HTTP gateway. It configures the base URL once and
// injects bearer tokens into outgoing requests for authenticated actions.
class ApiClient {
  ApiClient() {
    dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (_token != null) options.headers['Authorization'] = 'Bearer $_token';
      handler.next(options);
    }));
  }

  // The actual Dio instance used for requests such as GET, POST, PUT, and DELETE.
  late final Dio dio;

  // Stores the current auth token so the interceptor can add it to every call.
  String? _token;

  // Updates the token after login or logout events.
  void setToken(String? token) => _token = token;
}