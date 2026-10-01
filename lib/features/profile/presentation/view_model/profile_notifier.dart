import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileNotifier extends Notifier<AuthUser?> {
  late ProfileRepository _profileRepository;

  @override
  AuthUser? build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    return _profileRepository.getCurrentUser();
  }

  static const int maxDisplayNameLength = 50;

  // Profile Update Validations
  bool validateUpdateDisplayName({required String name}) {
    String? newDisplayNameError;

    if (name.trim().isEmpty) {
      newDisplayNameError = StringsManager.newDisplayNameRequired;
    } else if (name.trim().length < 2) {
      newDisplayNameError = StringsManager.nameMinLength;
    } else if (name.trim().length > maxDisplayNameLength) {
      newDisplayNameError = StringsManager.nameMaxLength;
    }

    return newDisplayNameError == null;
  }

  /// Returns null once the name is saved, or the message to show when it is not.
  Future<String?> updateDisplayName({required String name}) async {
    if (!validateUpdateDisplayName(name: name)) {
      // state = AsyncError(StringsManager.notValidName, StackTrace.empty);
      return StringsManager.notValidName;
    }

    try {
      await _profileRepository.updateDisplayName(displayName: name.trim());

      /// Reflect the new name straight away: a guest has no Firebase profile to
      /// re-read, and `currentUserNameProvider` reads it off this state.
      state = (state ?? const AuthUser.guest()).copyWith(name: name.trim());
      return null;
    } catch (e) {
      return ErrorHandler.mapErrorMessage(e);
    }
  }
}
