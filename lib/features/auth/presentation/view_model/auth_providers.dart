import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(GetStorageService(GetStorage()));
});

final authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) => FirebaseAuthRemoteDataSourceImpl());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: local, remoteDataSource: remote);
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider.select((state) => state.user));
});

final currentUserNameProvider = Provider<String>((ref) {
  return ref.watch(authProvider.select((state) => (state.newDisplayName)));
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authLocalDataSourceProvider.select((state) => state.isLoggedIn()));
});
