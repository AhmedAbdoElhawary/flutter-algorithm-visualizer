import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

abstract class ProfileRepository {
  Future<void> updateDisplayName({required String displayName});
  Future<void> updateEmail({required String newEmail, required String currentPassword});
  Future<void> updatePassword({required String currentPassword, required String newPassword});
  Future<AuthUser?> getCurrentUser();
}
