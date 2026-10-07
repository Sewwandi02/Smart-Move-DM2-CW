import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_client.dart';
import '../models/auth_user.dart';

class AuthRepository {
  AuthRepository(this._client, this._storage);

  static const _tokenKey = 'smartmove_access_token';

  final ApiClient _client;
  final FlutterSecureStorage _storage;

  Future<AuthUser> login(String email, String password) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _acceptAuthResponse(response.data);
  }

  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? license,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
        if (role == 'DRIVER') 'license': license,
      },
    );
    return _acceptAuthResponse(response.data);
  }

  Future<AuthUser> currentUser() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data;
    if (data == null) {
      throw const FormatException('The current-user response was empty.');
    }
    return AuthUser.fromJson(data);
  }

  Future<bool> restoreToken() async {
    final token = await _storage.read(key: _tokenKey);
    _client.setToken(token);
    return token != null;
  }

  Future<void> logout() async {
    _client.setToken(null);
    await _storage.delete(key: _tokenKey);
  }

  Future<AuthUser> _acceptAuthResponse(Map<String, dynamic>? data) async {
    if (data == null || data['token'] is! String || data['user'] is! Map) {
      throw const FormatException('The authentication response was invalid.');
    }
    final token = data['token'] as String;
    await _storage.write(key: _tokenKey, value: token);
    _client.setToken(token);
    return AuthUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }
}

String authErrorMessage(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map && body['message'] is String) {
      return body['message'] as String;
    }
    if (error.response?.statusCode == 401) {
      return 'Email or password is incorrect.';
    }
    if (error.response?.statusCode == 409) {
      return 'An account with this email already exists.';
    }
    if (error.response == null) {
      return 'Cannot reach the backend. Check that the API is running.';
    }
  }
  return error is FormatException ? error.message : 'Authentication failed. Please try again.';
}
