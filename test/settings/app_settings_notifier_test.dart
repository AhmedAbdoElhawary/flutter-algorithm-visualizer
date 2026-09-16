// Device-level preferences. The thing worth pinning here is that a choice the
// user made is still in force the *next* time the app starts — the notifier
// used to return a hard-coded initial state and consult disk only from getters
// nothing watched, so every saved theme was quietly ignored on launch.

import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryStorage implements LocalStorage {
  _InMemoryStorage([Map<String, Object?>? seed]) : _values = {...?seed};

  final Map<String, Object?> _values;

  @override
  Future<void> write<T>(String key, T value) async => _values[key] = value;

  @override
  T? read<T>(String key) => _values[key] as T?;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  bool has(String key) => _values.containsKey(key);
}

/// A container whose settings box starts out holding [seed] — i.e. the state
/// of a device where the user has already chosen something.
ProviderContainer _containerWith([Map<String, Object?>? seed]) {
  final container = ProviderContainer(
    overrides: [appSettingsStorageProvider.overrideWithValue(_InMemoryStorage(seed))],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('what a fresh install gets', () {
    test('theme follows the phone rather than an opinion of ours', () {
      final container = _containerWith();

      expect(container.read(appSettingsProvider).themeMode, ThemeMode.system);
    });

    test('language falls back to English', () {
      final container = _containerWith();

      expect(container.read(appSettingsProvider).language, LanguagesEnum.english);
    });
  });

  group('a preference already on disk is in force at launch', () {
    test('light', () {
      final container = _containerWith({AppSettingsNotifier.themeModeKey: 'light'});

      expect(container.read(appSettingsProvider).themeMode, ThemeMode.light);
    });

    test('dark', () {
      final container = _containerWith({AppSettingsNotifier.themeModeKey: 'dark'});

      expect(container.read(appSettingsProvider).themeMode, ThemeMode.dark);
    });

    test('language', () {
      final container = _containerWith({AppSettingsNotifier.languageKey: 'ar'});

      expect(container.read(appSettingsProvider).language, LanguagesEnum.arabic);
    });
  });

  group('a value that cannot be parsed', () {
    test('does not throw, and does not strand the user on a broken theme', () {
      final container = _containerWith({AppSettingsNotifier.themeModeKey: 'ThemeMode.dark'});

      expect(container.read(appSettingsProvider).themeMode, ThemeMode.system);
    });
  });

  group('changing the theme', () {
    test('updates the state and writes it where the next launch will look', () async {
      final storage = _InMemoryStorage();
      final container = ProviderContainer(
        overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final changed = await container.read(appSettingsProvider.notifier).changeTheme(ThemeMode.light);

      expect(changed, isTrue);
      expect(container.read(appSettingsProvider).themeMode, ThemeMode.light);
      expect(storage.read<String>(AppSettingsNotifier.themeModeKey), 'light');
    });

    test('re-picking what is already selected changes nothing', () async {
      final container = _containerWith({AppSettingsNotifier.themeModeKey: 'dark'});

      final changed = await container.read(appSettingsProvider.notifier).changeTheme(ThemeMode.dark);

      expect(changed, isFalse);
    });

    test('every mode round-trips through storage, system included', () async {
      for (final mode in ThemeMode.values) {
        final storage = _InMemoryStorage({AppSettingsNotifier.themeModeKey: 'light'});
        final container = ProviderContainer(
          overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        await container.read(appSettingsProvider.notifier).changeTheme(mode);

        // Read it back through a *second* container, which is what a relaunch
        // really is: new notifier, same box.
        final relaunched = ProviderContainer(
          overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(relaunched.dispose);

        expect(relaunched.read(appSettingsProvider).themeMode, mode, reason: 'mode $mode did not survive');
      }
    });
  });

  group('changing the language', () {
    test('persists and survives a relaunch', () async {
      final storage = _InMemoryStorage();
      final container = ProviderContainer(
        overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);

      final relaunched = ProviderContainer(
        overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(relaunched.dispose);

      expect(relaunched.read(appSettingsProvider).language, LanguagesEnum.arabic);
    });

    test('theme and language do not overwrite each other', () async {
      final storage = _InMemoryStorage();
      final container = ProviderContainer(
        overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await container.read(appSettingsProvider.notifier).changeTheme(ThemeMode.light);
      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);

      final relaunched = ProviderContainer(
        overrides: [appSettingsStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(relaunched.dispose);

      final state = relaunched.read(appSettingsProvider);
      expect(state.themeMode, ThemeMode.light);
      expect(state.language, LanguagesEnum.arabic);
    });
  });
}
