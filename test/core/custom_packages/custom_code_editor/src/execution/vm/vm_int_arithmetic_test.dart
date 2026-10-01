import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

void main() {
  group('whole numbers past 2^53 stay exact in dart and python', () {
    test('a product taken modulo 1e9+7', () {
      expect(dart('return (1000000006 * 1000000006) % 1000000007;'), 1);
      expect(runIn(EditorLanguage.python, 'return (1000000006 * 1000000006) % 1000000007').value, 1);
    });

    test('a difference of two large numbers', () {
      expect(dart('return 9007199254740993 - 1;'), 9007199254740992);
      expect(runIn(EditorLanguage.python, 'return 9007199254740993 - 2').value, 9007199254740991);
    });

    test('javascript keeps its one number type, so it rounds like real javascript', () {
      final result = runIn(EditorLanguage.javascript, 'return (1000000006 * 1000000006) % 1000000007');
      expect(result.value, isNot(1));
    });
  });

  group('past 64 bits', () {
    String? pythonFailure(String body) => runIn(EditorLanguage.python, body).failure?.code;

    test('dart wraps around, as a real dart int does', () {
      expect(dart('return 9223372036854775807 + 1;'), -9223372036854775808);
    });

    test('python stops with a clear error instead of a wrapped number', () {
      expect(pythonFailure('return 9223372036854775807 + 1'), 'integerTooLarge');
      expect(pythonFailure('return -9223372036854775807 - 2'), 'integerTooLarge');
      expect(pythonFailure('return 5000000000 * 5000000000'), 'integerTooLarge');
      expect(pythonFailure('return 2 ** 64'), 'integerTooLarge');
      expect(
        StringsManager.executionFailureTemplate('integerTooLarge', const {}),
        StringsManager.failureIntegerTooLarge,
      );
    });

    test('python right up to the edge still works', () {
      expect(runIn(EditorLanguage.python, 'return 2 ** 62').value, 4611686018427387904);
      expect(runIn(EditorLanguage.python, 'return 3037000499 * 3037000499').value, 9223372030926249001);
      expect(runIn(EditorLanguage.python, 'return -1 * 5').value, -5);
    });
  });
}
