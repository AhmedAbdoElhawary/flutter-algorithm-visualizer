import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) => ProfileRemoteDataSourceImpl());

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSourceImpl(ref.watch(localStorageProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final authLocal = ref.watch(authLocalDataSourceProvider);
  final profileLocal = ref.watch(profileLocalDataSourceProvider);
  final remote = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(
    localDataSource: authLocal,
    profileLocalDataSource: profileLocal,
    remoteDataSource: remote,
  );
});

final profileProvider = NotifierProvider.autoDispose<ProfileNotifier, AsyncValue<AuthUser?>>(() {
  return ProfileNotifier();
});

final currentUserProvider = Provider<AsyncValue<AuthUser?>>((ref) {
  return ref.watch(profileProvider);
});

final currentUserNameProvider = Provider<AsyncValue<String>>((ref) {
  return ref.watch(profileProvider
      .select((state) => (state.whenData((value) => value?.name ?? StringsManager.anonymous))));
});

/// Whether the app is backed by a real account rather than a local guest session.
///
/// Stays `false` while the user is still loading, so the UI never flashes the
/// signed-in state before it knows who the user is.
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(
    profileProvider.select(
      (state) => state.maybeWhen(data: (user) => user?.isGuest == false, orElse: () => false),
    ),
  );
});
