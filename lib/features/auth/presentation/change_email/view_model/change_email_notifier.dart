import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_state.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/extensions/auth_extensions.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeEmailNotifier extends Notifier<ChangeEmailState> {
  late final ProfileRepository _profileRepository;

  @override
  ChangeEmailState build() {
    _profileRepository = ref.watch(profileRepositoryProvider);

    return const ChangeEmailState();
  }

  void setNewEmail(String value) {
    state = state.copyWith(
      newEmail: value,
      clearNewEmailError: true,
      clearErrorMessage: true,
    );
  }

  void setCurrentPassword(String value) {
    state = state.copyWith(
      currentPassword: value,
      clearCurrentPasswordError: true,
      clearErrorMessage: true,
    );
  }

  bool validate() {
    String? newEmailError;
    String? currentPasswordError;

    final currentEmail = ref.read(currentUserProvider).maybeWhen(
          data: (user) => user?.email,
          orElse: () => null,
        );

    if (state.newEmail.trim().isEmpty) {
      newEmailError = StringsManager.newEmailRequired;
    } else if (!state.newEmail.validateEmail) {
      newEmailError = StringsManager.invalidEmail;
    } else if (currentEmail != null && state.newEmail.trim().toLowerCase() == currentEmail.toLowerCase()) {
      newEmailError = StringsManager.sameEmailAsCurrent;
    }

    if (state.currentPassword.isEmpty) {
      currentPasswordError = StringsManager.currentPasswordRequired;
    }

    state = state.copyWith(
      newEmailError: newEmailError,
      currentPasswordError: currentPasswordError,
      clearNewEmailError: newEmailError == null,
      clearCurrentPasswordError: currentPasswordError == null,
    );

    return newEmailError == null && currentPasswordError == null;
  }

  /// Requests the change. Returns whether the confirmation link was sent — not
  /// whether the email changed, which only happens once the user opens it.
  Future<bool> requestEmailChange() async {
    if (!validate()) return false;

    state = state.copyWith(status: NotifierStatus.loading, clearErrorMessage: true);

    try {
      await _profileRepository.updateEmail(
        newEmail: state.newEmail.trim(),
        currentPassword: state.currentPassword,
      );

      /// The account still carries the old address, so nothing about the
      /// cached user is refreshed here — only the typed password is dropped.
      state = state.copyWith(status: NotifierStatus.success, currentPassword: '');
      return true;
    } catch (e) {
      state = state.copyWith(
        status: NotifierStatus.error,
        errorMessage: ErrorHandler.mapErrorMessage(e),
      );
      return false;
    }
  }
}
