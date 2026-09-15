import 'package:algorithm_visualizer/core/enums/notifier_state.dart';

class DeleteAccountState {
  final NotifierStatus status;
  final String password;
  final String? passwordError;
  final String? errorMessage;

  const DeleteAccountState({
    this.status = NotifierStatus.initial,
    this.password = '',
    this.passwordError,
    this.errorMessage,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  DeleteAccountState copyWith({
    NotifierStatus? status,
    String? password,
    String? passwordError,
    bool clearPasswordError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DeleteAccountState(
      status: status ?? this.status,
      password: password ?? this.password,
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
