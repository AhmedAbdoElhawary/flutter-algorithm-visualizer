import 'package:algorithm_visualizer/core/exceptions/firebase_exceptions.dart';
import 'package:algorithm_visualizer/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'fake_remote.dart';

typedef FakeAccount = ({AuthUserDTO user, String password});

class FakeAuthRemoteDataSource with FakeRemote implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource({Map<String, FakeAccount>? accounts}) : accounts = {...?accounts};

  /// Keyed by email.
  final Map<String, FakeAccount> accounts;

  AuthUserDTO? signedIn;

  @override
  Future<AuthUserDTO> login({required String email, required String password}) async {
    await answer('login');

    final account = accounts[email.trim()];
    if (account == null || account.password != password) throw _error('invalid-credential');

    return signedIn = account.user;
  }

  @override
  Future<AuthUserDTO> register(
      {required String name, required String email, required String password}) async {
    await answer('register');

    if (accounts.containsKey(email.trim())) throw _error('email-already-in-use');

    final user = AuthUserDTO(id: 'uid-${accounts.length + 1}', name: name.trim(), email: email.trim());
    accounts[user.email] = (user: user, password: password);
    return signedIn = user;
  }

  @override
  Future<void> forgotPassword({required String email}) => answer('forgotPassword');

  @override
  Future<void> resetPassword({required String code, required String newPassword}) => answer('resetPassword');

  @override
  Future<void> signOut() async {
    await answer('signOut');
    signedIn = null;
  }

  @override
  Future<void> deleteAccount({
    required String password,
    required Future<void> Function() onReauthenticated,
  }) async {
    await answer('deleteAccount');

    final user = signedIn;
    if (user == null) throw Exception('No signed in user to delete');
    if (accounts[user.email]?.password != password) throw _error('invalid-credential');

    // Same order as the real one: owned data goes while the credential is still valid.
    await onReauthenticated();

    accounts.remove(user.email);
    signedIn = null;
  }

  Exception _error(String code) => FirebaseExceptions.handleFirebaseAuthException(
        FirebaseAuthException(code: code),
      );
}
