import 'package:algorithm_visualizer/core/exceptions/firebase_exceptions.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'fake_remote.dart';

class FakeProfileRemoteDataSource with FakeRemote implements ProfileRemoteDataSource {
  FakeProfileRemoteDataSource({this.user, this.password = ''});

  /// Null means a guest session.
  FakeUser? user;
  String password;

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    await answer('updateDisplayName');
    user?.displayName = displayName.trim();
  }

  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    await answer('updateEmail');
    if (currentPassword != password) throw _error('invalid-credential');
    user?.email = newEmail.trim();
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    await answer('updatePassword');
    if (currentPassword != password) throw _error('invalid-credential');
    password = newPassword;
  }

  @override
  User? getCurrentUser() => user;

  Exception _error(String code) => FirebaseExceptions.handleFirebaseAuthException(
        FirebaseAuthException(code: code),
      );
}

/// Only the fields the app reads. Anything else fails loudly instead of returning a made-up value.
class FakeUser implements User {
  FakeUser({required this.uid, this.displayName, this.email});

  @override
  final String uid;

  @override
  String? displayName;

  @override
  String? email;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
