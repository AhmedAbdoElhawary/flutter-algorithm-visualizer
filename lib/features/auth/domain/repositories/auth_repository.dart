import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register({required String name, required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String code, required String newPassword});
  Future<void> logout();

  /// Permanently deletes the signed in account after re-authenticating with
  /// [password]. See `AuthRemoteDataSource.deleteAccount` for why the password
  /// and the [onReauthenticated] hook are both required.
  Future<void> deleteAccount({
    required String password,
    required Future<void> Function() onReauthenticated,
  });
}
