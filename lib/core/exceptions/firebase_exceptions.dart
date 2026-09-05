import 'package:firebase_auth/firebase_auth.dart';

class FirebaseExceptions {

 static Exception handleFirebaseAuthException(FirebaseAuthException e) {
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
      case 'requires-recent-login':
        return Exception('Please log in again before making this change');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}