import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/logging_profile_remote_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_profile_remote_data_source.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late FakeProfileRemoteDataSource source;
  late LoggingProfileRemoteDataSource logging;

  for (final enabled in [false, true]) {
    group(enabled ? 'with logging on' : 'with logging off', () {
      setUp(() {
        final wasEnabled = FirebaseLogConfig.enabled;
        final originalDebugPrint = debugPrint;
        FirebaseLogConfig.enabled = enabled;
        debugPrint = (message, {wrapWidth}) {};
        addTearDown(() {
          FirebaseLogConfig.enabled = wasEnabled;
          debugPrint = originalDebugPrint;
        });

        source = FakeProfileRemoteDataSource(
          user: FakeUser(uid: 'uid-1', displayName: 'Ada', email: 'ada@test.dev'),
          password: 'secret-1',
        );
        logging = LoggingProfileRemoteDataSource(source);
      });

      test('every call reaches the real source and returns its result', () async {
        expect(logging.getCurrentUser()?.uid, 'uid-1');
        await logging.updateDisplayName(displayName: 'Grace');
        await logging.updateEmail(newEmail: 'grace@test.dev', currentPassword: 'secret-1');
        await logging.updatePassword(currentPassword: 'secret-1', newPassword: 'secret-2');

        expect(source.calls, ['updateDisplayName', 'updateEmail', 'updatePassword']);
        expect(source.user?.displayName, 'Grace');
        expect(source.password, 'secret-2');
      });

      test('a guest reads back as nobody', () {
        source.user = null;

        expect(logging.getCurrentUser(), isNull);
      });

      test('errors come back unchanged', () async {
        final error = authError('network-request-failed');
        source.failWith = error;

        await expectLater(logging.updateDisplayName(displayName: 'Grace'), throwsA(same(error)));
      });
    });
  }
}
