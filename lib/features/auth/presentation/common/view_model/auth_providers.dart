import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/logging_auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/guest_data_service.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(localStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final source = FirebaseAuthRemoteDataSourceImpl();
  return FirebaseLogConfig.enabled ? LoggingAuthRemoteDataSource(source) : source;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: local, remoteDataSource: remote);
});

final guestDataServiceProvider = Provider<GuestDataService>((ref) {
  return GuestDataService(
    problemLocalDataSource: ref.watch(problemLocalDataSourceProvider),
    problemRemoteDataSource: ref.watch(problemRemoteDataSourceProvider),
    profileLocalDataSource: ref.watch(profileLocalDataSourceProvider),
    storage: ref.watch(localStorageProvider),
  );
});
