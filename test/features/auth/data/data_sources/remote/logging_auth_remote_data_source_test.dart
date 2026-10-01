import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/logging_auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  const user = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');
  late FakeAuthRemoteDataSource source;
  late LoggingAuthRemoteDataSource logging;

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

        source = FakeAuthRemoteDataSource(accounts: {user.email: (user: user, password: 'secret-1')});
        logging = LoggingAuthRemoteDataSource(source);
      });

      test('every call reaches the real source and returns its result', () async {
        expect((await logging.login(email: user.email, password: 'secret-1')).id, user.id);
        expect((await logging.register(name: 'Grace', email: 'grace@test.dev', password: 'secret-2')).name, 'Grace');
        await logging.forgotPassword(email: user.email);
        await logging.resetPassword(code: 'code', newPassword: 'secret-3');
        await logging.signOut();
        source.signedIn = user;
        var reauthenticated = false;
        await logging.deleteAccount(password: 'secret-1', onReauthenticated: () async => reauthenticated = true);

        expect(source.calls,
            ['login', 'register', 'forgotPassword', 'resetPassword', 'signOut', 'deleteAccount']);
        expect(reauthenticated, isTrue);
      });

      test('errors come back unchanged', () async {
        final error = authError('network-request-failed');
        source.failWith = error;

        await expectLater(logging.forgotPassword(email: user.email), throwsA(same(error)));
      });
    });
  }
}
