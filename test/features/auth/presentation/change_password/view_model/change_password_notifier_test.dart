import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_profile_remote_data_source.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late ProviderContainer container;
  late FakeProfileRemoteDataSource remote;

  setUp(() {
    container = createTestContainer(signedInAs: buildTestUser());
    container.listen(changePasswordProvider, (previous, next) {});
    remote = container.read(profileRemoteDataSourceProvider) as FakeProfileRemoteDataSource..password = 'secret-1';
  });

  Future<bool> change({String current = 'secret-1', String next = 'secret-2', String? confirm}) {
    container.read(changePasswordProvider.notifier)
      ..setCurrentPassword(current)
      ..setNewPassword(next)
      ..setConfirmPassword(confirm ?? next);
    return container.read(changePasswordProvider.notifier).changePassword();
  }

  group('refuses before asking Firebase', () {
    for (final (name, current, next, confirm, errors) in [
      ('all empty', '', '', '', [StringsManager.currentPasswordRequired, StringsManager.newPasswordRequired, StringsManager.confirmPasswordRequired]),
      ('weak', 'secret-1', '12345', '12345', [null, StringsManager.passwordMinLength, null]),
      ('same as now', 'secret-1', 'secret-1', 'secret-1', [null, StringsManager.samePasswordAsCurrent, null]),
      ('mismatch', 'secret-1', 'secret-2', 'secret-3', [null, null, StringsManager.passwordsDoNotMatch]),
    ]) {
      test(name, () async {
        expect(await change(current: current, next: next, confirm: confirm), isFalse);

        final state = container.read(changePasswordProvider);
        expect([state.currentPasswordError, state.newPasswordError, state.confirmPasswordError], errors);
        expect(remote.calls, isEmpty);
      });
    }
  });

  test('editing a field clears its error', () async {
    await change(current: '', next: '', confirm: '');

    container.read(changePasswordProvider.notifier)
      ..setCurrentPassword('a')
      ..setNewPassword('b')
      ..setConfirmPassword('c');

    final state = container.read(changePasswordProvider);
    expect([state.currentPasswordError, state.newPasswordError, state.confirmPasswordError], everyElement(isNull));
  });

  test('success changes it and forgets every typed password', () async {
    expect(await change(), isTrue);

    final state = container.read(changePasswordProvider);
    expect(state.isSuccess, isTrue);
    expect([state.currentPassword, state.newPassword, state.confirmPassword], everyElement(''));
    expect(remote.password, 'secret-2');
  });

  group('a refused change says why', () {
    test('wrong current password', () async {
      expect(await change(current: 'wrong-1'), isFalse);

      expect(container.read(changePasswordProvider).errorMessage, StringsManager.invalidCredentials);
    });

    test('sign-in too old', () async {
      remote.failWith = authError('requires-recent-login');

      expect(await change(), isFalse);

      expect(container.read(changePasswordProvider).isError, isTrue);
      expect(container.read(changePasswordProvider).errorMessage, StringsManager.reauthenticateRequired);
    });

    test('Firebase finds it too weak', () async {
      remote.failWith = authError('weak-password');

      expect(await change(), isFalse);

      expect(container.read(changePasswordProvider).errorMessage, StringsManager.passwordMinLength);
    });
  });

  test('loading while waiting, and a second submit meanwhile is ignored', () async {
    remote.delay = const Duration(milliseconds: 50);

    final first = change();
    expect(container.read(changePasswordProvider).isLoading, isTrue);
    expect(await container.read(changePasswordProvider.notifier).changePassword(), isFalse);

    expect(await first, isTrue);
    expect(remote.calls, ['updatePassword']);
  });
}
