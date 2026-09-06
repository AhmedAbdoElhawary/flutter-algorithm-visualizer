import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_notifier.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) => ProfileRemoteDataSourceImpl());

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  final remote = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(localDataSource: local, remoteDataSource: remote);
});

final profileProvider = NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(profileProvider.select((state) => state.user));
});

final currentUserNameProvider = Provider<String>((ref) {
  return ref.watch(profileProvider.select((state) => (state.user?.name ?? state.newDisplayName)));
});
