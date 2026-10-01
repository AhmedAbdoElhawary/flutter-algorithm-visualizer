import 'dart:io';

import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/onboarding/view_model/onboarding_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import '../../../helpers/fakes/in_memory_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingStore', () {
    test('is not seen on first launch', () {
      expect(OnboardingStore(InMemoryStorage()).isSeen, isFalse);
    });

    test('markSeen saves the flag', () async {
      final storage = InMemoryStorage();

      await OnboardingStore(storage).markSeen();

      expect(storage.read<bool>(OnboardingStore.seenKey), isTrue);
      expect(OnboardingStore(storage).isSeen, isTrue);
    });

    test('is seen when the flag was saved on an earlier launch', () {
      final storage = InMemoryStorage({OnboardingStore.seenKey: true});

      expect(OnboardingStore(storage).isSeen, isTrue);
    });

    test('a saved false is not seen', () {
      final storage = InMemoryStorage({OnboardingStore.seenKey: false});

      expect(OnboardingStore(storage).isSeen, isFalse);
    });

    test('a wrong-type value is treated as not seen instead of throwing', () {
      final storage = InMemoryStorage({OnboardingStore.seenKey: 'yes'});

      expect(OnboardingStore(storage).isSeen, isFalse);
    });

    test('the provider reads the app storage', () async {
      final storage = InMemoryStorage({OnboardingStore.seenKey: true});
      final container = ProviderContainer(overrides: [localStorageProvider.overrideWithValue(storage)]);
      addTearDown(container.dispose);

      expect(container.read(onboardingStoreProvider).isSeen, isTrue);
    });

    // The router reads this before any provider exists, so it goes through the real GetStorage.
    test('standalone reads the same box the provider writes to', () async {
      // GetStorage writes to disk in the background, even from init(), with nothing to await. So the
      // folder and the path_provider answer stay for the whole file instead of being torn down mid-write.
      final dir = Directory('${Directory.systemTemp.path}/algodive_onboarding_store_test')
        ..createSync(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => dir.path,
      );

      await GetStorage.init();
      await GetStorage().erase();
      expect(OnboardingStore.standalone().isSeen, isFalse);

      GetStorage().writeInMemory(OnboardingStore.seenKey, true);
      expect(OnboardingStore.standalone().isSeen, isTrue);
    });
  });
}
