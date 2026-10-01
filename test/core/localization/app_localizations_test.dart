import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const delegate = AppLocalizations.delegate;

  test('English and Arabic are supported, with or without a country', () {
    expect(delegate.isSupported(const Locale('en')), isTrue);
    expect(delegate.isSupported(const Locale('ar', 'EG')), isTrue);
    expect(delegate.isSupported(const Locale('fr')), isFalse);
  });

  test('loading is synchronous, so switching language never shows the old one for a frame', () {
    final loaded = delegate.load(const Locale('ar'));

    expect(loaded, isA<SynchronousFuture<AppLocalizations>>());
  });

  test('Arabic reads right to left, English left to right', () async {
    final arabic = await delegate.load(const Locale('ar'));
    final english = await delegate.load(const Locale('en'));

    expect(arabic.isArabic, isTrue);
    expect(arabic.textDirection, TextDirection.rtl);
    expect(english.isArabic, isFalse);
    expect(english.textDirection, TextDirection.ltr);
  });

  test('a string with no translation comes back as itself, so translating twice is safe', () async {
    final arabic = await delegate.load(const Locale('ar'));

    expect(arabic.tr('Settings'), 'Settings');
    expect(arabic.tr(arabic.tr('Settings')), 'Settings');
    expect(noTranslation('Settings'), 'Settings');
  });

  test('the tables never change, so there is nothing to reload', () {
    expect(delegate.shouldReload(delegate), isFalse);
  });

  testWidgets('outside a MaterialApp, of() falls back to English instead of throwing', (tester) async {
    late AppLocalizations found;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          found = AppLocalizations.of(context);
          return const SizedBox();
        },
      ),
    );

    expect(found.locale, const Locale('en'));
    expect(found.isArabic, isFalse);
  });

  testWidgets('String.tr uses the locale of the context', (tester) async {
    late String translated;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('ar'),
        delegates: const [delegate, DefaultWidgetsLocalizations.delegate],
        child: Builder(
          builder: (context) {
            translated = 'Settings'.tr(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(translated, 'Settings');
  });
}
