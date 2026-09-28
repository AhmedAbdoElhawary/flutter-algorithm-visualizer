import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/account_deletion_service.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/guest_data_service.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../../helpers/test_container.dart';

void main() {
  test('each provider builds its piece on top of the storage and the remote', () {
    final container = createTestContainer();

    expect(container.read(authLocalDataSourceProvider), isA<AuthLocalDataSourceImpl>());
    expect(container.read(authRemoteDataSourceProvider), isA<FakeAuthRemoteDataSource>());
    final repository = container.read(authRepositoryProvider) as AuthRepositoryImpl;
    expect(repository.remoteDataSource, same(container.read(authRemoteDataSourceProvider)));
    expect(repository.localDataSource, same(container.read(authLocalDataSourceProvider)));
    expect(container.read(guestDataServiceProvider), isA<GuestDataService>());
    expect(container.read(accountDeletionServiceProvider), isA<AccountDeletionService>());
  });
}
