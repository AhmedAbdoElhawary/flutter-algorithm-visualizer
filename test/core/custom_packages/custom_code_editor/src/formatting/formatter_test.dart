import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

class _TrimFormatter extends CodeFormatter {
  const _TrimFormatter();

  @override
  String format(String source) => source.split('\n').map((line) => line.trimRight()).join('\n');
}

void main() {
  test('format replaces the text and puts the caret at the end', () {
    final controller = CodeController(text: 'int a;   \nint b;  ', formatter: const _TrimFormatter());
    addTearDown(controller.dispose);

    controller.format();

    expect(controller.text, 'int a;\nint b;');
    expect(controller.selection.baseOffset, controller.text.length);
  });

  test('with no formatter, format does nothing', () {
    final controller = CodeController(text: 'int a;   ');
    addTearDown(controller.dispose);

    controller.format();

    expect(controller.text, 'int a;   ');
  });
}
