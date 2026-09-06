import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Traces every [ProfileRemoteDataSource] call to the console, then hands over
/// to the real data source untouched.
class LoggingProfileRemoteDataSource implements ProfileRemoteDataSource {
  const LoggingProfileRemoteDataSource(this._source);

  final ProfileRemoteDataSource _source;

  static const String _scope = 'profile';

  @override
  User? getCurrentUser() {
    return FirebaseLogger.traceSync(
      _scope,
      'getCurrentUser',
      _source.getCurrentUser,
      describeResult: (user) =>
          user == null ? 'no user' : 'uid=${FirebaseLogger.id(user.uid)}',
    );
  }

  @override
  Future<void> updateDisplayName({required String displayName}) {
    return FirebaseLogger.trace(
      _scope,
      'updateDisplayName',
      () => _source.updateDisplayName(displayName: displayName),
      args: {'displayName': displayName},
    );
  }

  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) {
    return FirebaseLogger.trace(
      _scope,
      'updateEmail',
      () => _source.updateEmail(newEmail: newEmail, currentPassword: currentPassword),
      args: {
        'newEmail': FirebaseLogger.email(newEmail),
        'currentPassword': FirebaseLogger.secret,
      },
    );
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) {
    return FirebaseLogger.trace(
      _scope,
      'updatePassword',
      () => _source.updatePassword(currentPassword: currentPassword, newPassword: newPassword),
      args: {
        'currentPassword': FirebaseLogger.secret,
        'newPassword': FirebaseLogger.secret,
      },
    );
  }
}
