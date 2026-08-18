import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScreenUtilSetup extends StatelessWidget {
  const _ScreenUtilSetup({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 844));
    return child;
  }
}

void main() {
  testWidgets('rebuilding CodeEditorBlock with changed code while focused does not crash the caret painter',
      (tester) async {
    CodeController? controller;
    final captured = <CodeController>[];

    Widget build(String code) {
      return _ScreenUtilSetup(
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: CodeEditorBlock(
                      title: 'test',
                      code: code,
                      controllerCallback: (c) {
                        captured.add(c);
                        controller = c;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(build('void main() {}'));
    expect(captured, hasLength(1));

    await tester.tap(find.byType(EditableText));
    await tester.pump();

    controller!.text = 'void main() { print(1); }';
    await tester.pump();

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    // Rebuild with the saved solution as the widget code while focused and
    // blinking; the value must not be reset nor the editable torn down.
    await tester.pumpWidget(build('void main() { print(1); }'));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(controller!.text, 'void main() { print(1); }');
    expect(captured, hasLength(1));
  });

  testWidgets('disposing CodeEditorBlock while the caret is blinking does not crash', (tester) async {
    CodeController? controller;

    await tester.pumpWidget(
      _ScreenUtilSetup(
        child: MaterialApp(
          home: Scaffold(
            body: CodeEditorBlock(title: 'test', code: 'void main() {}', controllerCallback: (c) => controller = c),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.pump();

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    // Simulate navigating away: the whole editor is removed from the tree.
    await tester.pumpWidget(const _ScreenUtilSetup(child: MaterialApp(home: Scaffold(body: SizedBox()))));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(controller, isNotNull);
  });
}
