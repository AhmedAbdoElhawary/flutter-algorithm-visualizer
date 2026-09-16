// Regression test for a real crash: translating "Bubble sort" to the longer
// bracketed Arabic form ("الترتيب الفقاعي (Bubble Sort)") and rendering it in
// the sorting mode's horizontally-scrolling tab strip threw
//
//   'RenderBox was not laid out' / RenderFlex needs bounded constraints
//
// because `AlgoTab` had unconditionally wrapped its label in `Flexible` to
// fix a *different* overflow (the three-way searching tabs, which sit inside
// a bounded `Expanded`). `Flexible`/`Expanded` require a bounded main-axis
// constraint from their parent `Row`; the sorting tabs live inside a
// `SingleChildScrollView(scrollDirection: horizontal)`, which gives its
// `Row` unbounded width on purpose (so the row grows to fit its content and
// scrolls). Wrapping every label in `Flexible` regardless of context turned
// a soft, cosmetic problem in one place into a hard crash in another.
//
// The fix: `constrainLabelWidth` opts a caller *in* to the `Flexible` +
// single-line-ellipsis behavior, and only the callers whose parent actually
// bounds their width (the three `Expanded`-wrapped tabs) set it. This test
// pins both shapes so neither regresses again.

import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// The longest real label in the app today: an algorithm name in the
/// bracketed Arabic house style. Deliberately hard-coded rather than pulled
/// from the translation table, so this test still catches the crash even if
/// that particular string is later shortened.
const _longArabicLabel = 'الترتيب الفقاعي (Bubble Sort)';

Widget _harness(Widget child) {
  return ProviderScope(
    child: ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: Directionality(textDirection: TextDirection.rtl, child: child)),
      ),
    ),
  );
}

void main() {
  group('AlgoTab inside an unbounded horizontal scroll (sorting mode)', () {
    testWidgets('a long label does not crash when constrainLabelWidth is left off (default)', (tester) async {
      await tester.pumpWidget(
        _harness(
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AlgoTab(label: _longArabicLabel, isSelected: true, addEndPadding: false),
                AlgoTab(label: 'ترتيب الإدراج (Insertion Sort)', isSelected: false, addEndPadding: false),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(_longArabicLabel), findsOneWidget);
    });

    testWidgets(
        'setting constrainLabelWidth: true in this same unbounded context is a real crash '
        '(documents why the flag defaults to false, not just a style choice)', (tester) async {
      await tester.pumpWidget(
        _harness(
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AlgoTab(
                  label: _longArabicLabel,
                  isSelected: true,
                  addEndPadding: false,
                  constrainLabelWidth: true,
                ),
              ],
            ),
          ),
        ),
      );

      // FlutterError surfaces through takeException in a test, rather than
      // crashing the test runner itself — this is the same failure a real
      // run hit, captured here so nobody re-adds the flag to that call site.
      expect(tester.takeException(), isNotNull);
    });
  });

  group('AlgoTab inside a bounded Expanded (the searching tabs\' actual shape)', () {
    testWidgets('a long label ellipsizes instead of overflowing when constrainLabelWidth is true',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          const Row(
            children: [
              Expanded(
                child: AlgoTab(
                  label: _longArabicLabel,
                  isSelected: true,
                  addEndPadding: false,
                  constrainLabelWidth: true,
                ),
              ),
              Expanded(
                child: AlgoTab(
                  label: 'بحث BFS',
                  isSelected: false,
                  addEndPadding: false,
                  constrainLabelWidth: true,
                ),
              ),
              Expanded(
                child: AlgoTab(
                  label: 'بحث DFS',
                  isSelected: false,
                  addEndPadding: false,
                  constrainLabelWidth: true,
                ),
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
