import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_keyboard_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// [EditorKeyboardToolbar] never touches [Theme.of]/[MediaQuery] directly for
/// colour beyond `context.getColor`, but that still needs a real [AppTheme]
/// and [ScreenUtilInit] ancestor (every `.r`/`.w`/`.h` call resolves through
/// it) — same shape as `theme_role_contrast_test.dart`.
Future<void> _pumpToolbar(
  WidgetTester tester, {
  required CodeController controller,
  required EditorLanguage language,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EditorKeyboardToolbar(controller: controller, language: language),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('EditorKeyboardToolbar — symbols', () {
    testWidgets('tapping a bracket key inserts it and auto-closes, caret lands between', (tester) async {
      final controller = CodeController(config: const CodeEditorConfig());
      addTearDown(controller.dispose);

      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      await tester.tap(find.text('('));
      await tester.pump();

      // Goes through CodeController.value exactly like typing does, so the
      // same auto-close behavior real typing gets applies to a tapped key.
      expect(controller.text, '()');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
    });

    testWidgets('tapping a quote key type-overs the auto-inserted closing quote', (tester) async {
      final controller = CodeController(config: const CodeEditorConfig());
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      await tester.tap(find.text('"'));
      await tester.pump();
      expect(controller.text, '""');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));

      // Tapping the closing quote again should type over, not double it.
      await tester.tap(find.text('"'));
      await tester.pump();
      expect(controller.text, '""');
      expect(controller.selection, const TextSelection.collapsed(offset: 2));
    });

    testWidgets('tapping a key replaces an active (non-collapsed) selection', (tester) async {
      final controller = CodeController(text: 'hello', config: const CodeEditorConfig());
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      await tester.tap(find.text('_'));
      await tester.pump();

      expect(controller.text, '_');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
    });

    testWidgets('Dart/JS symbol set has braces and semicolon, not the Python-only keys', (tester) async {
      final controller = CodeController(config: const CodeEditorConfig());
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      expect(find.text('{'), findsOneWidget);
      expect(find.text('}'), findsOneWidget);
      expect(find.text(';'), findsOneWidget);
      expect(find.text('#'), findsNothing);
    });

    testWidgets('Python symbol set has # and no braces/semicolon', (tester) async {
      final controller = CodeController(config: const CodeEditorConfig());
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.python);

      expect(find.text('#'), findsOneWidget);
      expect(find.text('{'), findsNothing);
      expect(find.text('}'), findsNothing);
      expect(find.text(';'), findsNothing);
      // `:` matters a lot more in Python than Dart/JS, so it's still present.
      expect(find.text(':'), findsOneWidget);
    });
  });

  group('EditorKeyboardToolbar — Tab', () {
    testWidgets('inserts the controller\'s configured indent unit, not a hard-coded one', (tester) async {
      final controller = CodeController(config: const CodeEditorConfig(tabSize: 4, useSpaces: true));
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.python);

      await tester.tap(find.text('Tab'));
      await tester.pump();

      expect(controller.text, '    ');
      expect(controller.selection, const TextSelection.collapsed(offset: 4));
    });
  });

  group('EditorKeyboardToolbar — arrow keys', () {
    testWidgets('left/right move the caret by one character, clamped at the edges', (tester) async {
      final controller = CodeController(text: 'ab', config: const CodeEditorConfig());
      controller.selection = const TextSelection.collapsed(offset: 1);
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 2));

      // Already at the end — must clamp, not run off the document.
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 2));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
    });

    testWidgets('up/down move a line, preserving column when the target line is long enough', (tester) async {
      final controller = CodeController(text: 'abcd\nxy\nabcd', config: const CodeEditorConfig());
      // Column 3 on line 0 ("abcd").
      controller.selection = const TextSelection.collapsed(offset: 3);
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pump();
      // Line 1 ("xy") is shorter than column 3, so the caret clamps to its end
      // (offset 5 = line 0's 4 chars + '\n' + 2 chars of "xy").
      expect(controller.selection, const TextSelection.collapsed(offset: 7));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pump();
      // No "sticky column" memory across moves — each step reads the
      // *current* column, which is already clamped to 2 from the previous
      // line. So this lands on line 2's column 2, not the original 3.
      expect(controller.selection, const TextSelection.collapsed(offset: 10));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 7));
    });

    testWidgets('up on the first line and down on the last line do nothing', (tester) async {
      final controller = CodeController(text: 'only', config: const CodeEditorConfig());
      controller.selection = const TextSelection.collapsed(offset: 2);
      addTearDown(controller.dispose);
      await _pumpToolbar(tester, controller: controller, language: EditorLanguage.dart);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 2));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 2));
    });
  });
}
