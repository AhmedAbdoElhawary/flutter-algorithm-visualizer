import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

Object? _run(EditorLanguage language, String body) {
  final result = runIn(language, language == EditorLanguage.dart ? '$body;' : body);
  if (result.failure != null) fail('${language.name}: $body -> ${result.failure}');
  return result.value;
}

String? _failure(EditorLanguage language, String body) => runIn(language, body).failure?.code;

void main() {
  group('the same answer in every language', () {
    for (final (body, value) in [
      ('return 6 & 3', 2),
      ('return 6 | 3', 7),
      ('return 6 ^ 3', 5),
      ('return 1 << 3', 8),
      ('return -16 >> 2', -4),
      ('return ~5', -6),
      ('return 1 << 2 + 1', 8),
      ('return 6 & 3 ^ 1', 3),
    ]) {
      for (final language in supportedLanguages) {
        test('${language.name}: $body', () => expect(_run(language, body), value));
      }
    }

    test('compound assignment', () {
      const steps = 'x &= 3; x |= 8; x ^= 1; x <<= 2; x >>= 1';
      expect(_run(EditorLanguage.dart, 'var x = 5; $steps; return x'), 16);
      expect(_run(EditorLanguage.javascript, 'let x = 5; $steps; return x'), 16);
      expect(_run(EditorLanguage.python, 'x = 5\n${steps.replaceAll('; ', '\n')}\nreturn x'), 16);
    });
  });

  group('where the languages differ', () {
    test('javascript puts == above |, dart and python put it below', () {
      expect(_run(EditorLanguage.javascript, 'return 1 | 2 == 3'), 1);
      expect(_run(EditorLanguage.dart, 'return 1 | 2 == 3'), true);
      expect(_run(EditorLanguage.python, 'return 1 | 2 == 3'), true);
    });

    test('javascript works on 32-bit ints', () {
      expect(_run(EditorLanguage.javascript, 'return (7 + 10) >>> 1'), 8);
      expect(_run(EditorLanguage.javascript, 'return -1 >>> 0'), 4294967295);
      expect(_run(EditorLanguage.javascript, 'return 1 << 31'), -2147483648);
      expect(_run(EditorLanguage.javascript, 'return 1 << 32'), 1);
      expect(_run(EditorLanguage.javascript, 'return 2 ** 32 | 0'), 0);
      expect(_run(EditorLanguage.javascript, 'return ~~3.7'), 3);
      expect(_run(EditorLanguage.javascript, 'return true & 1'), 1);
      expect(_run(EditorLanguage.javascript, 'let x = -8; x >>>= 28; return x'), 15);
    });

    test('dart and python work on the whole 64-bit int', () {
      expect(_run(EditorLanguage.dart, 'return 1 << 40'), 1099511627776);
      expect(_run(EditorLanguage.python, 'return 1 << 40'), 1099511627776);
      expect(_run(EditorLanguage.dart, 'return 1 << 64'), 0);
      expect(_failure(EditorLanguage.python, 'return 1 << 64'), 'integerTooLarge');
      expect(_failure(EditorLanguage.python, 'return 3 << 62'), 'integerTooLarge');
    });

    test('a bool pair stays a bool in dart and python', () {
      expect(_run(EditorLanguage.dart, 'return true & false'), false);
      expect(_run(EditorLanguage.dart, 'return true ^ false'), true);
      expect(_run(EditorLanguage.python, 'return True | False'), true);
    });

    test('python sets meet, join and differ with & | ^', () {
      expect(_run(EditorLanguage.python, 'return sorted({1, 2, 3} & {2, 3, 4})'), [2, 3]);
      expect(_run(EditorLanguage.python, 'return sorted({1, 2} | {2, 3})'), [1, 2, 3]);
      expect(_run(EditorLanguage.python, 'return sorted({1, 2, 3} ^ {2, 3, 4})'), [1, 4]);
    });

    test('a negative count or a fraction is a type mismatch outside javascript', () {
      expect(_failure(EditorLanguage.python, 'return 1 << -1'), 'typeMismatch');
      expect(_failure(EditorLanguage.dart, 'return 1.5 & 1;'), 'typeMismatch');
    });
  });

  test('dart generics still close with >>', () {
    const body = 'List<List<int>> g = [[8]]; var m = <String, List<int>>{}; return g[0][0] >> m.length + 1';
    expect(_run(EditorLanguage.dart, body), 4);
  });
}
