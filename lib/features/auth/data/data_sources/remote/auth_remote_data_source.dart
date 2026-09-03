import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserDTO> login({required String email, required String password});
  Future<AuthUserDTO> register({required String name, required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String code, required String newPassword});
  Future<void> signOut();
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
        solvedCount: 0,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
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
        solvedCount: 0,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
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
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  String _formatNameFromEmail(String email) {
    final prefix = email.split('@').first;
    if (prefix.isEmpty) return 'User';
    return prefix[0].toUpperCase() + prefix.substring(1);
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email':
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Invalid email or password');
      case 'email-already-in-use':
        return Exception('An account with this email already exists');
      case 'weak-password':
        return Exception('Password must be at least 6 characters');
      case 'invalid-action-code':
      case 'expired-action-code':
        return Exception('Invalid or expired verification code');
      case 'network-request-failed':
        return Exception('Network error. Please try again');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
