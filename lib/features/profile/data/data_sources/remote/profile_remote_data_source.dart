import 'package:algorithm_visualizer/core/exceptions/firebase_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateDisplayName({required String displayName});
  Future<void> updateEmail({required String newEmail, required String currentPassword});
  Future<void> updatePassword({required String currentPassword, required String newPassword});
  User? getCurrentUser();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  late final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    try {
      final user = getCurrentUser();
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
      final user = getCurrentUser();
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
      final user = getCurrentUser();
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
}
