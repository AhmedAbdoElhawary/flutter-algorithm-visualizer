import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<AuthUser> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<AuthUser> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.register(name: name, email: email, password: password);
  }
}

class ForgotPasswordUseCase {
  final AuthRepository repository;
  const ForgotPasswordUseCase(this.repository);

  Future<void> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  const ResetPasswordUseCase(this.repository);

  Future<void> call({required String code, required String newPassword}) {
    return repository.resetPassword(code: code, newPassword: newPassword);
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  Future<AuthUser?> call() {
    return repository.getCurrentUser();
  }
}
