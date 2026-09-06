import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    final dto = await remoteDataSource.login(email: email, password: password);
    await localDataSource.saveUser(dto);
    return dto.toDomain();
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final dto = await remoteDataSource.register(name: name, email: email, password: password);
    await localDataSource.saveUser(dto);
    return dto.toDomain();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({required String code, required String newPassword}) async {
    await remoteDataSource.resetPassword(code: code, newPassword: newPassword);
  }

  @override
  AuthUser? getCurrentUser()  {
    final dto = localDataSource.getUser();
    return dto?.toDomain();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
    await remoteDataSource.signOut();
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
