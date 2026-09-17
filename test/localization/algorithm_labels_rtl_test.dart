// Translating an algorithm name makes it longer, and the searching tabs are
// the one place in the app where that is dangerous: three `Expanded` cells
// share a 360pt row, so each label has roughly 84pt and no scroll to escape
// into. A bracketed form like "البحث بالعرض (BFS)" does not fit there.
//
// So this suite measures the real labels in the real tab, at the narrowest
// surface the design supports, and fails if one is clipped.

import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/localization/translations/ar_translations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _smallSurface = Size(360, 640);

/// The three searching labels, laid out exactly as `visualize_page` lays them
/// out: one `Row`, one `Expanded` per tab, 16pt outer and 8pt inner gutters.
Future<void> _pumpSearchingTabs(WidgetTester tester, LanguagesEnum language) async {
  const devicePixelRatio = 3.0;
  await tester.binding.setSurfaceSize(_smallSurface);
  tester.view.physicalSize = _smallSurface * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  const labels = <String>[StringsManager.bFS, StringsManager.dFS, StringsManager.aStarSearch];

  await tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: _smallSurface,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.dark,
          locale: Locale(language.shortKey),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: i == 0 ? 16 : 8,
                        end: i == labels.length - 1 ? 16 : 0,
                      ),
                      child: AlgoTab(
                        isSelected: i == 0,
                        addEndPadding: false,
                        label: labels[i],
                        constrainLabelWidth: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final language in LanguagesEnum.values) {
    final name = language == LanguagesEnum.arabic ? 'Arabic' : 'English';

    testWidgets('the searching tabs lay out at 360pt in $name with no overflow', (tester) async {
      // This is the assertion that would have caught the bracketed form
      // ("البحث بالعرض (BFS)"): `AlgoTab` used to hold its label in a bare
      // `Row` child, so a label wider than its `Expanded` cell threw a
      // `RenderFlex` overflow rather than ellipsing.
      await _pumpSearchingTabs(tester, language);
      expect(tester.takeException(), isNull);
      expect(find.byType(AlgoTab), findsNWidgets(3));
    });
  }

  group('the Arabic searching labels', () {
    testWidgets('keep their acronym', (tester) async {
      // The acronym *is* the meaning here. Translating it away would leave a
      // learner unable to match the tab to anything they read elsewhere.
      await _pumpSearchingTabs(tester, LanguagesEnum.arabic);

      expect(find.text('بحث BFS'), findsOneWidget);
      expect(find.text('بحث DFS'), findsOneWidget);
    });

    test('are no longer than the English they replace', () {
      // A character budget, not a pixel measurement: widget tests render with
      // a fixed-width test font, so measuring real text fit in one would
      // prove nothing about IBM Plex on a device. Character count is coarse
      // but font-independent, and it is enough to catch the failure that
      // actually matters — someone later replacing these with the long
      // bracketed form used elsewhere in the table.
      const pairs = <String, String>{
        StringsManager.bFS: 'بحث BFS',
        StringsManager.dFS: 'بحث DFS',
        StringsManager.aStarSearch: 'بحث ‎A*‎',
      };

      pairs.forEach((english, arabic) {
        expect(
          kArTranslations[english],
          arabic,
          reason: 'The three searching tabs share one 360pt row. Keep these short.',
        );
        expect(
          arabic.length,
          lessThanOrEqualTo(english.length),
          reason: '"$arabic" is longer than "$english", and the tab has no room to grow.',
        );
      });
    });
  });

  test('the sorting names may use the long bracketed form', () {
    // Sorting tabs live in a horizontal scroll view, so length costs nothing
    // there. This is the house style the rest of the table follows.
    expect(kArTranslations[StringsManager.bubbleSort], contains('Bubble Sort'));
    expect(kArTranslations[StringsManager.bubbleSort], contains('الترتيب الفقاعي'));
  });
}
