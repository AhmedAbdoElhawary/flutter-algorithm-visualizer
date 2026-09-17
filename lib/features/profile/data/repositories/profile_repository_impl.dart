import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthLocalDataSource localDataSource;
  final ProfileLocalDataSource profileLocalDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.profileLocalDataSource,
    required this.remoteDataSource,
  });

  @override
  AuthUser? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();

    /// Nobody is signed in, so this is a guest session: report the name they
    /// picked locally, if any, instead of nothing at all.
    if (user == null) return AuthUser.guest(name: profileLocalDataSource.getDisplayName());

    return AuthUser(
      id: user.uid,
      name: user.displayName,
      email: user.email,
    );
  }

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    /// A guest has no Firebase profile to write to, the name is held locally
    /// until it is handed to the account created at sign up.
    if (remoteDataSource.getCurrentUser() == null) {
      return await profileLocalDataSource.saveDisplayName(displayName);
    }

    await remoteDataSource.updateDisplayName(displayName: displayName);

    final currentDto = localDataSource.getUser();
    if (currentDto != null) {
      final updatedDto = currentDto.copyWith(name: displayName.trim());
      await localDataSource.saveUser(updatedDto);
    }
  }

  /// Only *requests* the change: `verifyBeforeUpdateEmail` sends a link and the
  /// account keeps its old address until that link is opened.
  ///
  /// So the cached user is deliberately left alone. Writing [newEmail] here
  /// would show an address the account does not actually have yet, and the one
  /// the user would then try — and fail — to sign in with.
  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    await remoteDataSource.updateEmail(newEmail: newEmail, currentPassword: currentPassword);
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    await remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}
