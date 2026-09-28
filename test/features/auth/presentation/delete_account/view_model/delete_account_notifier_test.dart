import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late ProviderContainer container;
  late FakeAuthRemoteDataSource remote;

  setUp(() {
    final user = buildTestUser();
    container = createTestContainer(signedInAs: user);
    container.listen(deleteAccountProvider, (previous, next) {});
    final dto = AuthUserDTO(id: user.id, name: user.name!, email: user.email!);
    remote = container.read(authRemoteDataSourceProvider) as FakeAuthRemoteDataSource
      ..accounts[dto.email] = (user: dto, password: 'secret-1')
      ..signedIn = dto;
  });

  Future<bool> delete(String password) {
    container.read(deleteAccountProvider.notifier).setPassword(password);
    return container.read(deleteAccountProvider.notifier).deleteAccount();
  }

  test('an empty password is refused before asking Firebase', () async {
    expect(await delete(''), isFalse);

    expect(container.read(deleteAccountProvider).passwordError, StringsManager.passwordRequired);
    expect(remote.calls, isEmpty);
  });

  test('typing clears the error', () async {
    await delete('');

    container.read(deleteAccountProvider.notifier).setPassword('a');

    expect(container.read(deleteAccountProvider).passwordError, isNull);
  });

  test('the right password deletes the account and signs out to a guest', () async {
    expect(await delete('secret-1'), isTrue);

    expect(container.read(deleteAccountProvider).isSuccess, isTrue);
    expect(container.read(deleteAccountProvider).password, '');
    expect(remote.accounts, isEmpty);
    expect(container.read(isSignedInProvider), isFalse);
  });

  test('a wrong password says so and keeps the account', () async {
    expect(await delete('wrong'), isFalse);

    expect(container.read(deleteAccountProvider).errorMessage, StringsManager.invalidCredentials);
    expect(remote.accounts, isNotEmpty);
  });

  test('a network failure says so', () async {
    remote.failWith = authError('network-request-failed');

    expect(await delete('secret-1'), isFalse);

    expect(container.read(deleteAccountProvider).isError, isTrue);
    expect(container.read(deleteAccountProvider).errorMessage, StringsManager.networkError);
  });

  test('loading while waiting, and a second submit meanwhile is ignored', () async {
    remote.delay = const Duration(milliseconds: 50);

    final first = delete('secret-1');
    expect(container.read(deleteAccountProvider).isLoading, isTrue);
    expect(await container.read(deleteAccountProvider.notifier).deleteAccount(), isFalse);

    expect(await first, isTrue);
    expect(remote.calls, ['deleteAccount']);
  });
}
