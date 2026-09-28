import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../engine_support.dart';

void main() {
  const language = EditorLanguage.javascript;
  const source = 'function add(a, b) {\n  return a + b\n}';

  test('calls the function with the test case values and returns its answer', () {
    final result = callIn(language, source, 'add', [2, 3]);

    expect(result.failure, isNull);
    expect(result.value, 5);
  });

  test('a class from the problem is available before the solution', () {
    const box = 'class Box {\n  constructor(v) {\n    this.v = v\n  }\n}';
    const solution = 'function open(n) {\n  return new Box(n).v\n}';

    final result = callIn(language, solution, 'open', [4], prelude: [box]);

    expect(result.failure, isNull);
    expect(result.value, 4);
  });

  test('a missing function is a failure, never a pass', () {
    final result = callIn(language, source, 'subtract', [2, 3]);

    expect(result.failure, isNotNull);
    expect(result.value, isNull);
  });

  test('a main the learner wrote runs when the code runs on its own', () {
    const withMain =
        "function main() {\n  console.log('main ran')\n}\nfunction add(a, b) {\n  return a + b\n}";

    expect(runIn(language, withMain).stdout, ['main ran']);
  });

  test('the frontend names its language', () {
    expect(frontendFor(language).language, language);
  });
}
