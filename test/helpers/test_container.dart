import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import 'fakes/fake_auth_remote_data_source.dart';
import 'fakes/fake_problem_remote_data_source.dart';
import 'fakes/fake_profile_remote_data_source.dart';
import 'fakes/in_memory_storage.dart';

/// A container with storage and every remote data source swapped for fakes, so nothing reaches disk or
/// Firebase. Disposed when the test ends.
ProviderContainer createTestContainer({AuthUser? signedInAs, List<Override> overrides = const []}) {
  final user = signedInAs == null
      ? null
      : FakeUser(uid: signedInAs.id, displayName: signedInAs.name, email: signedInAs.email);

  final profileRemote = FakeProfileRemoteDataSource(user: user);
  final authRemote = FakeAuthRemoteDataSource()..onSignedOut = () => profileRemote.user = null;

  final container = ProviderContainer(
    overrides: [
      localStorageProvider.overrideWithValue(InMemoryStorage()),
      appSettingsStorageProvider.overrideWithValue(InMemoryStorage()),
      authRemoteDataSourceProvider.overrideWithValue(authRemote),
      profileRemoteDataSourceProvider.overrideWithValue(profileRemote),
      problemRemoteDataSourceProvider.overrideWithValue(FakeProblemRemoteDataSource(isSignedIn: user != null)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}
