import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

void main() {
  Object? run(EditorLanguage language, String source) {
    final result = runIn(language, source);
    if (result.failure != null) fail('${language.name}: ${result.failure}');
    return result.value;
  }

  test('dividing two ints: Dart and JavaScript give a fraction, Python needs // to floor', () {
    expect(run(EditorLanguage.dart, 'return 7 / 2;'), 3.5);
    expect(run(EditorLanguage.javascript, 'return 7 / 2;'), 3.5);
    expect(run(EditorLanguage.python, 'return 7 / 2'), 3.5);
    expect(run(EditorLanguage.python, 'return 7 // 2'), 3);
    expect(run(EditorLanguage.dart, 'return 7 ~/ 2;'), 3);
  });

  test('truthiness: Python and JavaScript treat empty things as false', () {
    expect(run(EditorLanguage.python, "return 'yes' if [] else 'no'"), 'no');
    expect(run(EditorLanguage.javascript, "return 0 ? 'yes' : 'no';"), 'no');
  });

  test('printing true and none', () {
    expect(runIn(EditorLanguage.python, 'print(True)\nprint(None)\nreturn 0').stdout, ['True', 'None']);
    expect(runIn(EditorLanguage.dart, 'print(true); print(null); return 0;').stdout, ['true', 'null']);
    const logs = 'console.log(true); console.log(null); return 0;';
    expect(runIn(EditorLanguage.javascript, logs).stdout, ['true', 'null']);
  });

  test('negative indexing is Python only', () {
    expect(run(EditorLanguage.python, 'return [1, 2, 3][-1]'), 3);
    expect(runIn(EditorLanguage.dart, 'return [1, 2, 3][-1];').failure?.code, 'indexOutOfRange');
  });

  test('out of range reads undefined in JavaScript, an error elsewhere', () {
    expect(run(EditorLanguage.javascript, 'return [1][5];'), 'undefined');
    expect(runIn(EditorLanguage.python, 'return [1][5]').failure?.code, 'indexOutOfRange');
  });

  test('a string index gives a one character string', () {
    expect(run(EditorLanguage.dart, "return 'abc'[1];"), 'b');
    expect(run(EditorLanguage.python, "return 'abc'[1]"), 'b');
  });

  test('repeating a sequence is Python only', () {
    expect(run(EditorLanguage.python, 'return [0] * 3'), [0, 0, 0]);
  });
}
