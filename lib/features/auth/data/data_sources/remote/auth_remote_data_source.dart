import 'package:algorithm_visualizer/core/exceptions/firebase_exceptions.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserDTO> login({required String email, required String password});
  Future<AuthUserDTO> register({required String name, required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String code, required String newPassword});
  Future<void> signOut();
  Future<void> updateDisplayName({required String displayName});
  Future<void> updateEmail({required String newEmail, required String currentPassword});
  Future<void> updatePassword({required String currentPassword, required String newPassword});
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

      final token = await user.getIdToken();

      return AuthUserDTO(
        id: user.uid,
        name: user.displayName ?? _formatNameFromEmail(user.email ?? email),
        email: user.email ?? email.trim(),
        token: token,
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
      if (user == null) {
        throw Exception('User creation failed');
      }

      // Update user display name in Firebase Auth
      await user.updateDisplayName(name.trim());
      await user.reload();

      final token = await user.getIdToken();

      return AuthUserDTO(
        id: user.uid,
        name: name.trim(),
        email: user.email ?? email.trim(),
        token: token,
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
  Future<void> updateDisplayName({required String displayName}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await user.updateDisplayName(displayName.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) throw Exception('No authenticated user');

      final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) throw Exception('No authenticated user');

      final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
      await user.reload();
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
