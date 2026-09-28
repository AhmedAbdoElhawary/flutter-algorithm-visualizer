import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/frontend.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/ir/ir.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/dialect.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:flutter_test/flutter_test.dart';

class _Bare extends LanguageFrontend {
  @override
  EditorLanguage get language => EditorLanguage.dart;

  @override
  Dialect get dialect => throw UnimplementedError();

  @override
  IrProgram parse(String source) => const IrProgram([]);

  @override
  IrProgram buildHarness({
    required IrProgram userProgram,
    required String functionName,
    required List<Value> arguments,
    required List<String> preludeSources,
  }) =>
      userProgram;
}

void main() {
  test('a frontend brings no globals unless it says so', () {
    expect(_Bare().globals, isEmpty);
  });
}
