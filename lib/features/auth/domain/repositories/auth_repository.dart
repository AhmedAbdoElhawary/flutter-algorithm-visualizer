import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register({required String name, required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String code, required String newPassword});
  AuthUser? getCurrentUser();
  Future<void> logout();
}
