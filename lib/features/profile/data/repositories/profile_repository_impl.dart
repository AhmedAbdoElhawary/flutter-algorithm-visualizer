import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.localDataSource, required this.remoteDataSource});
  @override
  AuthUser? getCurrentUser() {
    final dto = localDataSource.getUser();
    return dto?.toDomain();
  }

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    await remoteDataSource.updateDisplayName(displayName: displayName);

    final currentDto = localDataSource.getUser();
    if (currentDto != null) {
      final updatedDto = currentDto.copyWith(name: displayName.trim());
      await localDataSource.saveUser(updatedDto);
    }
  }

  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    await remoteDataSource.updateEmail(newEmail: newEmail, currentPassword: currentPassword);

    final currentDto = localDataSource.getUser();
    if (currentDto != null) {
      final updatedDto = currentDto.copyWith(email: newEmail.trim());
      await localDataSource.saveUser(updatedDto);
    }
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    await remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}
