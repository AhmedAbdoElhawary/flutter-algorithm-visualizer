import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';

/// Traces every [AuthRemoteDataSource] call to the console, then hands over to
/// the real data source untouched.
///
/// Errors are logged and rethrown as they are, so the mapping done by
/// `FirebaseExceptions` inside the wrapped implementation stays the only thing
/// that transforms them.
class LoggingAuthRemoteDataSource implements AuthRemoteDataSource {
  const LoggingAuthRemoteDataSource(this._source);

  final AuthRemoteDataSource _source;

  static const String _scope = 'auth';

  @override
  Future<AuthUserDTO> login({required String email, required String password}) {
    return FirebaseLogger.trace(
      _scope,
      'login',
      () => _source.login(email: email, password: password),
      args: {'email': FirebaseLogger.email(email), 'password': FirebaseLogger.secret},
      describeResult: _describeUser,
    );
  }

  @override
  Future<AuthUserDTO> register({
    required String name,
    required String email,
    required String password,
  }) {
    return FirebaseLogger.trace(
      _scope,
      'register',
      () => _source.register(name: name, email: email, password: password),
      args: {
        'name': name,
        'email': FirebaseLogger.email(email),
        'password': FirebaseLogger.secret,
      },
      describeResult: _describeUser,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return FirebaseLogger.trace(
      _scope,
      'forgotPassword',
      () => _source.forgotPassword(email: email),
      args: {'email': FirebaseLogger.email(email)},
    );
  }

  @override
  Future<void> resetPassword({required String code, required String newPassword}) {
    return FirebaseLogger.trace(
      _scope,
      'resetPassword',
      () => _source.resetPassword(code: code, newPassword: newPassword),
      args: {'code': FirebaseLogger.secret, 'newPassword': FirebaseLogger.secret},
    );
  }

  @override
  Future<void> signOut() {
    return FirebaseLogger.trace(_scope, 'signOut', () => _source.signOut());
  }

  String _describeUser(AuthUserDTO user) {
    return 'uid=${FirebaseLogger.id(user.id)}, ${FirebaseLogger.token(user.token)}';
  }
}
