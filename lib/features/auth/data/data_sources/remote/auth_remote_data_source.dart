import 'package:algorithm_visualizer/core/exceptions/firebase_exceptions.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserDTO> login({required String email, required String password});
  Future<AuthUserDTO> register({required String name, required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String code, required String newPassword});
  Future<void> signOut();

  /// Re-authenticates with [password], then permanently deletes the Firebase
  /// user.
  ///
  /// Firebase refuses `delete()` on a credential older than a few minutes
  /// (`requires-recent-login`), so the password is not an extra confirmation
  /// step invented by the UI — the operation genuinely needs it.
  ///
  /// [onReauthenticated] runs after the re-login succeeds but before the user
  /// is destroyed. That ordering is required: clearing Firestore needs a live
  /// credential, and once `delete()` returns there is no longer an account
  /// authorised to write under `users/{uid}`.
  Future<void> deleteAccount({
    required String password,
    required Future<void> Function() onReauthenticated,
  });
}

class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  late final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuthRemoteDataSourceImpl();

  @override
  Future<AuthUserDTO> login({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User not found after login');

      return AuthUserDTO(
        id: user.uid,
        name: user.displayName ?? _formatNameFromEmail(user.email ?? email),
        email: user.email ?? email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUserDTO> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User creation failed');

      // Update user display name in Firebase Auth
      await user.updateDisplayName(name.trim());
      await user.reload();

      return AuthUserDTO(
        id: user.uid,
        name: name.trim(),
        email: user.email ?? email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String code, required String newPassword}) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code.trim(),
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount({
    required String password,
    required Future<void> Function() onReauthenticated,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No signed in user to delete');

      final email = user.email;
      if (email == null) throw Exception('This account has no e-mail to re-authenticate with');

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );

      /// Owned data goes first, while the credential is still valid.
      await onReauthenticated();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  String _formatNameFromEmail(String email) {
    final prefix = email.split('@').first;
    if (prefix.isEmpty) return 'User';
    return prefix[0].toUpperCase() + prefix.substring(1);
  }
}
