import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileNotifier extends Notifier<AsyncValue<AuthUser?>> {
  late final ProfileRepository _profileRepository;

  @override
  AsyncValue<AuthUser?> build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _loadInitialUser();
    return const AsyncLoading();
  }

  Future<void> _loadInitialUser() async {
    state = await AsyncValue.guard(() => _profileRepository.getCurrentUser());
  }

  // Profile Update Validations
  bool validateUpdateDisplayName({required String name}) {
    String? newDisplayNameError;

    if (name.trim().isEmpty) {
      newDisplayNameError = StringsManager.newDisplayNameRequired;
    } else if (name.trim().length < 2) {
      newDisplayNameError = StringsManager.nameMinLength;
    }

    return newDisplayNameError == null;
  }

  Future<bool> updateDisplayName({required String name}) async {
    if (!validateUpdateDisplayName(name: name)) {
      // state = AsyncError(StringsManager.notValidName, StackTrace.empty);
      return false;
    }

    // final preDisplayName = state.newDisplayName;
    // final preUser = state.user;

    try {
      await _profileRepository.updateDisplayName(displayName: name.trim());

      // state = state.copyWith(
      //   status: NotifierStatus.success,
      //   successMessage: StringsManager.displayNameUpdated,
      //   clearNewDisplayNameError: true,
      // );
      return true;
    } catch (e) {
      // state = state.copyWith(
      //   status: NotifierStatus.error,
      //   errorMessage: ErrorHandler.mapErrorMessage(e),
      //   newDisplayName: preDisplayName,
      //   user: preUser,
      // );
      return false;
    }
  }
}
