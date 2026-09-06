import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';


class ProfileState {
  final NotifierStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? successMessage;

  // Profile Update Fields
  final String currentPassword;
  final String newDisplayName;
  final String newEmail;
  final String newProfilePassword;
  final String confirmNewProfilePassword;

  // Profile Update Validation Errors
  final String? currentPasswordError;
  final String? newDisplayNameError;
  final String? newEmailError;
  final String? newProfilePasswordError;
  final String? confirmNewProfilePasswordError;

  const ProfileState({
    this.status = NotifierStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.currentPassword = '',
    this.newDisplayName = StringsManager.anonymous,
    this.newEmail = '',
    this.newProfilePassword = '',
    this.confirmNewProfilePassword = '',
    this.currentPasswordError,
    this.newDisplayNameError,
    this.newEmailError,
    this.newProfilePasswordError,
    this.confirmNewProfilePasswordError,
  });

  ProfileState copyWith({
    NotifierStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    String? currentPassword,
    String? newDisplayName,
    String? newEmail,
    String? newProfilePassword,
    String? confirmNewProfilePassword,
    String? currentPasswordError,
    bool clearCurrentPasswordError = false,
    String? newDisplayNameError,
    bool clearNewDisplayNameError = false,
    String? newEmailError,
    bool clearNewEmailError = false,
    String? newProfilePasswordError,
    bool clearNewProfilePasswordError = false,
    String? confirmNewProfilePasswordError,
    bool clearConfirmNewProfilePasswordError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      currentPassword: currentPassword ?? this.currentPassword,
      newDisplayName: newDisplayName ?? this.newDisplayName,
      newEmail: newEmail ?? this.newEmail,
      newProfilePassword: newProfilePassword ?? this.newProfilePassword,
      confirmNewProfilePassword: confirmNewProfilePassword ?? this.confirmNewProfilePassword,
      currentPasswordError:
      clearCurrentPasswordError ? null : (currentPasswordError ?? this.currentPasswordError),
      newDisplayNameError:
      clearNewDisplayNameError ? null : (newDisplayNameError ?? this.newDisplayNameError),
      newEmailError: clearNewEmailError ? null : (newEmailError ?? this.newEmailError),
      newProfilePasswordError:
      clearNewProfilePasswordError ? null : (newProfilePasswordError ?? this.newProfilePasswordError),
      confirmNewProfilePasswordError: clearConfirmNewProfilePasswordError
          ? null
          : (confirmNewProfilePasswordError ?? this.confirmNewProfilePasswordError),
    );
  }
}
