import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_client.dart';
import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider), const FlutterSecureStorage());
});

final authProvider = AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthUser?> {
  late final AuthRepository _repository;

  @override
  Future<AuthUser?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    if (!await _repository.restoreToken()) return null;
    try {
      return await _repository.currentUser();
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403 ||
          error.response?.statusCode == 404) {
        await _repository.logout();
        return null;
      }
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final user = await _repository.login(email, password);
    state = AsyncData(user);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? license,
  }) async {
    final user = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
        license: license,
      );
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  Future<void> retryRestore() async {
    ref.invalidateSelf();
    await future;
  }
}
