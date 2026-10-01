import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('every Firebase auth error reaches the user as its own message', () {
    for (final (code, message) in [
      ('invalid-credential', StringsManager.invalidCredentials),
      ('wrong-password', StringsManager.invalidCredentials),
      ('user-not-found', StringsManager.invalidCredentials),
      ('invalid-email', StringsManager.invalidCredentials),
      ('email-already-in-use', StringsManager.userAlreadyExists),
      ('weak-password', StringsManager.passwordMinLength),
      ('invalid-action-code', StringsManager.invalidCode),
      ('expired-action-code', StringsManager.invalidCode),
      ('network-request-failed', StringsManager.networkError),
      ('too-many-requests', StringsManager.tooManyAttempts),
      ('requires-recent-login', StringsManager.reauthenticateRequired),
    ]) {
      test(code, () {
        expect(ErrorHandler.mapErrorMessage(authError(code)), message);
      });
    }
  });

  test('other errors that name a cause are recognised too', () {
    expect(ErrorHandler.mapErrorMessage(Exception('Invalid credentials')), StringsManager.invalidCredentials);
    expect(ErrorHandler.mapErrorMessage(Exception('Problem not found')), StringsManager.userNotFound);
    expect(ErrorHandler.mapErrorMessage(Exception('SocketException: failed')), StringsManager.networkError);
    expect(ErrorHandler.mapErrorMessage(Exception('Connection timeout')), StringsManager.networkError);
  });

  test('anything else gets the generic message', () {
    expect(ErrorHandler.mapErrorMessage(authError('some-new-code')), StringsManager.sorryForInconvenience);
    expect(ErrorHandler.mapErrorMessage(StateError('boom')), StringsManager.sorryForInconvenience);
  });
}
