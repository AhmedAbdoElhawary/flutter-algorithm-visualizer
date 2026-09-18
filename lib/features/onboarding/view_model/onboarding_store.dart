import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// Remembers whether the onboarding flow has been shown.
///
/// Lives in the same default [GetStorage] box as every other local data source
/// (see [localStorageProvider]), so it survives sign-in and sign-out the same
/// way the rest of the local state does.
final class OnboardingStore {
  const OnboardingStore(this._storage);

  /// Key name is fixed by the design spec (§5).
  static const String seenKey = 'onboarding_seen';

  final LocalStorage _storage;

  bool get isSeen => _storage.read<bool>(seenKey) ?? false;

  Future<void> markSeen() => _storage.write<bool>(seenKey, true);

  /// For the router, which builds before any [WidgetRef] exists. Safe to call
  /// after `GetStorage.init()` in `bootstrap.dart`, and it reads the very same
  /// box the provider below writes to.
  static OnboardingStore standalone() => OnboardingStore(GetStorageService(GetStorage()));
}

final onboardingStoreProvider = Provider<OnboardingStore>(
  (ref) => OnboardingStore(ref.watch(localStorageProvider)),
);
