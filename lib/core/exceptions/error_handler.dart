import 'package:algorithm_visualizer/core/resources/strings_manager.dart';

class ErrorHandler {
  static String mapErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid email or password') || msg.contains('invalid credentials')) {
      return StringsManager.invalidCredentials;
    }
    if (msg.contains('already exists')) {
      return StringsManager.userAlreadyExists;
    }
    if (msg.contains('no account found') || msg.contains('not found')) {
      return StringsManager.userNotFound;
    }
    if (msg.contains('verification code')) {
      return StringsManager.invalidCode;
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
      return StringsManager.networkError;
    }
    if (msg.contains('log in again') || msg.contains('requires-recent-login')) {
      return StringsManager.reauthenticateRequired;
    }
    return StringsManager.sorryForInconvenience;
  }
}
