import 'package:algorithm_visualizer/core/exceptions/firebase_exceptions.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

String _message(String code, [String? message]) => FirebaseExceptions.handleFirebaseAuthException(
      FirebaseAuthException(code: code, message: message),
    ).toString();

void main() {
  // The texts here are what ErrorHandler matches on, so they must stay the StringsManager ones.
  for (final (codes, text) in [
    (['user-not-found', 'invalid-email', 'wrong-password', 'invalid-credential'], StringsManager.invalidCredentials),
    (['email-already-in-use'], StringsManager.userAlreadyExists),
    (['weak-password'], StringsManager.passwordMinLength),
    (['network-request-failed'], StringsManager.networkError),
    (['too-many-requests'], StringsManager.tooManyAttempts),
    (['requires-recent-login'], StringsManager.reauthenticateRequired),
  ]) {
    for (final code in codes) {
      test(code, () {
        expect(_message(code), 'Exception: $text');
      });
    }
  }

  test('an expired or invalid reset code', () {
    expect(_message('invalid-action-code'), contains('verification code'));
    expect(_message('expired-action-code'), contains('verification code'));
  });

  test('an unknown code keeps Firebase\'s own message, or a generic one', () {
    expect(_message('quota-exceeded', 'Quota exceeded.'), 'Exception: Quota exceeded.');
    expect(_message('quota-exceeded'), 'Exception: Authentication failed');
  });
}
