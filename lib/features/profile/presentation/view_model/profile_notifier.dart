import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_state.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _profileRepository;

  @override
  ProfileState build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    return _loadInitialUser();
  }

  ProfileState _loadInitialUser() {
    state = const ProfileState();
    try {
      final user = _profileRepository.getCurrentUser();
      if (user != null) state = state.copyWith(user: user);
      return state;
    } catch (_) {
      return const ProfileState();
    }
  }

  void setNewDisplayName(String value) {
    state = state.copyWith(
      newDisplayName: value,
      clearNewDisplayNameError: true,
      clearErrorMessage: true,
    );
  }

  // void setNewEmail(String value) {
  //   state = state.copyWith(
  //     newEmail: value,
  //     clearNewEmailError: true,
  //     clearErrorMessage: true,
  //   );
  // }
  //
  // void setNewProfilePassword(String value) {
  //   state = state.copyWith(
  //     newProfilePassword: value,
  //     clearNewProfilePasswordError: true,
  //     clearErrorMessage: true,
  //   );
  // }

  // Profile Update Validations
  bool validateUpdateDisplayName({required String name}) {
    String? newDisplayNameError;

    if (name.trim().isEmpty) {
      newDisplayNameError = StringsManager.newDisplayNameRequired;
    } else if (name.trim().length < 2) {
      newDisplayNameError = StringsManager.nameMinLength;
    }

    state = state.copyWith(
      newDisplayNameError: newDisplayNameError,
      clearNewDisplayNameError: newDisplayNameError == null,
    );

    return newDisplayNameError == null;
  }
  //
  // bool validateUpdateEmail() {
  //   String? newEmailError;
  //   String? currentPasswordError;
  //
  //   if (state.newEmail.trim().isEmpty) {
  //     newEmailError = StringsManager.newEmailRequired;
  //   } else if (!state.newEmail.validateEmail) {
  //     newEmailError = StringsManager.invalidEmail;
  //   }
  //
  //   if (state.currentPassword.isEmpty) {
  //     currentPasswordError = StringsManager.currentPasswordRequired;
  //   }
  //
  //   state = state.copyWith(
  //     newEmailError: newEmailError,
  //     currentPasswordError: currentPasswordError,
  //     clearNewEmailError: newEmailError == null,
  //     clearCurrentPasswordError: currentPasswordError == null,
  //   );
  //
  //   return newEmailError == null && currentPasswordError == null;
  // }
  //
  // bool validateUpdatePassword() {
  //   String? currentPasswordError;
  //   String? newProfilePasswordError;
  //   String? confirmNewProfilePasswordError;
  //
  //   if (state.currentPassword.isEmpty) {
  //     currentPasswordError = StringsManager.currentPasswordRequired;
  //   }
  //
  //   if (state.newProfilePassword.isEmpty) {
  //     newProfilePasswordError = StringsManager.newPasswordRequired;
  //   } else if (state.newProfilePassword.length < 6) {
  //     newProfilePasswordError = StringsManager.passwordMinLength;
  //   }
  //
  //   if (state.confirmNewProfilePassword.isEmpty) {
  //     confirmNewProfilePasswordError = StringsManager.confirmPasswordRequired;
  //   } else if (state.confirmNewProfilePassword != state.newProfilePassword) {
  //     confirmNewProfilePasswordError = StringsManager.passwordsDoNotMatch;
  //   }
  //
  //   state = state.copyWith(
  //     currentPasswordError: currentPasswordError,
  //     newProfilePasswordError: newProfilePasswordError,
  //     confirmNewProfilePasswordError: confirmNewProfilePasswordError,
  //     clearCurrentPasswordError: currentPasswordError == null,
  //     clearNewProfilePasswordError: newProfilePasswordError == null,
  //     clearConfirmNewProfilePasswordError: confirmNewProfilePasswordError == null,
  //   );
  //
  //   return currentPasswordError == null &&
  //       newProfilePasswordError == null &&
  //       confirmNewProfilePasswordError == null;
  // }

  // Profile Update Operations
  Future<bool> updateDisplayName({required String name}) async {
    if (!validateUpdateDisplayName(name: name)) return false;

    final preDisplayName = state.newDisplayName;
    final preUser = state.user;

    state = state.copyWith(
      status: NotifierStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      newDisplayName: name,
      user: state.user?.copyWith(name: name.trim()),
    );

    try {
      await _profileRepository.updateDisplayName(displayName: name.trim());

      state = state.copyWith(
        status: NotifierStatus.success,
        successMessage: StringsManager.displayNameUpdated,
        clearNewDisplayNameError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: NotifierStatus.error,
        errorMessage: ErrorHandler.mapErrorMessage(e),
        newDisplayName: preDisplayName,
        user: preUser,
      );
      return false;
    }
  }
  //
  // Future<bool> updateEmail() async {
  //   if (!validateUpdateEmail()) return false;
  //
  //   state = state.copyWith(
  //     status: NotifierStatus.loading,
  //     clearErrorMessage: true,
  //     clearSuccessMessage: true,
  //   );
  //
  //   try {
  //     await _profileRepository.updateEmail(
  //       newEmail: state.newEmail.trim(),
  //       currentPassword: state.currentPassword,
  //     );
  //
  //     // Update AuthUser in state
  //     if (state.user != null) {
  //       state = state.copyWith(user: state.user!.copyWith(email: state.newEmail.trim()));
  //     }
  //
  //     state = state.copyWith(
  //       status: NotifierStatus.success,
  //       successMessage: StringsManager.emailUpdated,
  //       currentPassword: '',
  //       newEmail: '',
  //       clearCurrentPasswordError: true,
  //       clearNewEmailError: true,
  //     );
  //     return true;
  //   } catch (e) {
  //     state = state.copyWith(
  //       status: NotifierStatus.error,
  //       errorMessage: ErrorHandler.mapErrorMessage(e),
  //     );
  //     return false;
  //   }
  // }
  //
  // Future<bool> updatePassword() async {
  //   if (!validateUpdatePassword()) return false;
  //
  //   state = state.copyWith(
  //     status: NotifierStatus.loading,
  //     clearErrorMessage: true,
  //     clearSuccessMessage: true,
  //   );
  //
  //   try {
  //     await _profileRepository.updatePassword(
  //       currentPassword: state.currentPassword,
  //       newPassword: state.newProfilePassword,
  //     );
  //
  //     state = state.copyWith(
  //       status: NotifierStatus.success,
  //       successMessage: StringsManager.passwordUpdated,
  //       currentPassword: '',
  //       newProfilePassword: '',
  //       confirmNewProfilePassword: '',
  //       clearCurrentPasswordError: true,
  //       clearNewProfilePasswordError: true,
  //       clearConfirmNewProfilePasswordError: true,
  //     );
  //     return true;
  //   } catch (e) {
  //     state = state.copyWith(
  //       status: NotifierStatus.error,
  //       errorMessage: ErrorHandler.mapErrorMessage(e),
  //     );
  //     return false;
  //   }
  // }
}
