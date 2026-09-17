// Switching language has to do three things at once, and each of them fails
// in a way a screenshot of the *settings* screen would not show:
//
//   1. the words change,
//   2. the whole layout mirrors,
//   3. it happens on the next frame, with the user still where they were.
//
// (3) is the one worth a test. `AppLocalizations` loads from a
// `SynchronousFuture` precisely so the new table is in place inside the same
// build; a plain `Future` would still "work", just with a frame of the old
// language in between. Only a pump-by-pump assertion catches that.

import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemorySettings implements LocalStorage {
  final Map<String, Object?> _values = <String, Object?>{};

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

/// The same locale wiring `MyApp` sets up, with a caller-supplied body.
Widget _app(Widget body, {LocalStorage? storage}) {
  return ProviderScope(
    overrides: [
      appSettingsStorageProvider.overrideWithValue(storage ?? _InMemorySettings()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: (context, _) => Consumer(
        builder: (context, ref, _) {
          final language = ref.watch(appSettingsProvider.select((s) => s.language));
          return MaterialApp(
            locale: Locale(language.shortKey),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(body: body),
          );
        },
      ),
    ),
  );
}

void main() {
  group('the table', () {
    test('translates a known key and passes an unknown one straight through', () {
      const english = AppLocalizations(Locale('en'), {});
      expect(english.tr(StringsManager.settings), StringsManager.settings);
      expect(english.isArabic, isFalse);
    });

    test('is supported by language code alone, ignoring the country subtag', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('ar', 'EG')), isTrue);
      expect(delegate.isSupported(const Locale('en', 'US')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });

  group('switching to Arabic', () {
    testWidgets('translates the label and mirrors the layout', (tester) async {
      await tester.pumpWidget(_app(const BoldText(StringsManager.settings)));
      expect(find.text(StringsManager.settings), findsOneWidget);

      final context = tester.element(find.byType(BoldText));
      expect(Directionality.of(context), TextDirection.ltr);

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);
      await tester.pumpAndSettle();

      expect(find.text(StringsManager.settings), findsNothing);
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(BoldText))), TextDirection.rtl);
    });

    testWidgets('lands on the very next frame, with no English frame in between', (tester) async {
      await tester.pumpWidget(_app(const BoldText(StringsManager.settings)));

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);

      // One pump, not `pumpAndSettle`: if the delegate returned a real Future
      // the table would still be loading here and the old language would
      // still be painted.
      await tester.pump();
      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('drops the tracking that would break joined Arabic letters', (tester) async {
      await tester.pumpWidget(
        _app(const BoldText(StringsManager.settings, letterSpacing: -1.9)),
      );
      expect(tester.widget<Text>(find.byType(Text)).style!.letterSpacing, -1.9);

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.byType(Text)).style!.letterSpacing, 0);
    });

    testWidgets('leaves text marked as content alone', (tester) async {
      // "Settings" is a real key, so this proves the opt-out, not a miss.
      await tester.pumpWidget(
        _app(const BoldText(StringsManager.settings, translate: false)),
      );

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);
      await tester.pumpAndSettle();

      expect(find.text(StringsManager.settings), findsOneWidget);
    });

    testWidgets('keeps an LtrContent subtree left-to-right', (tester) async {
      await tester.pumpWidget(
        _app(const LtrContent(child: BoldText('two_sum.dart', translate: false))),
      );

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);
      await tester.pumpAndSettle();

      expect(Directionality.of(tester.element(find.byType(BoldText))), TextDirection.ltr);
      expect(find.text('two_sum.dart'), findsOneWidget);
    });
  });

  testWidgets('the choice survives a relaunch', (tester) async {
    final storage = _InMemorySettings();

    await tester.pumpWidget(_app(const BoldText(StringsManager.settings), storage: storage));
    final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);
    await tester.pumpAndSettle();

    expect(storage.read<String>(AppSettingsNotifier.languageKey), 'ar');

    // A fresh tree over the same box is what the next cold start looks like.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(const BoldText(StringsManager.settings), storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget);
  });
}
