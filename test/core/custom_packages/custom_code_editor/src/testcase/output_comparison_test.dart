import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reading the mode from a problem', () {
    test('each key reads back to its mode', () {
      for (final mode in OutputComparison.values) {
        expect(OutputComparison.fromKey(mode.key), mode);
      }
    });

    test('no key, or one we do not know, is an exact match, the strict choice', () {
      expect(OutputComparison.fromKey(null), OutputComparison.exact);
      expect(OutputComparison.fromKey('fuzzy'), OutputComparison.exact);
    });
  });

  group('normalizing before the compare', () {
    String normal(String canonical, OutputComparison mode) => normalizeForComparison(canonical, mode);

    test('exact leaves the order alone', () {
      expect(normal('[3,1,2]', OutputComparison.exact), '[3,1,2]');
      expect(normal('[3,1,2]', OutputComparison.exact), isNot(normal('[1,2,3]', OutputComparison.exact)));
    });

    test('unordered sorts the outer list only, so an inner order still counts', () {
      expect(normal('[[2,1],[0]]', OutputComparison.unordered), '[[0],[2,1]]');
      expect(
        normal('[[1,2],[0]]', OutputComparison.unordered),
        isNot(normal('[[2,1],[0]]', OutputComparison.unordered)),
      );
    });

    test('unordered deep sorts every level', () {
      expect(normal('[[2,1],[0]]', OutputComparison.unorderedDeep), '[[0],[1,2]]');
      expect(
        normal('[[1,2],[0]]', OutputComparison.unorderedDeep),
        normal('[[0],[2,1]]', OutputComparison.unorderedDeep),
      );
    });

    test('a different set of items never matches, whatever the mode', () {
      for (final mode in OutputComparison.values) {
        expect(normal('[1,2]', mode), isNot(normal('[1,3]', mode)));
        expect(normal('[1,1,2]', mode), isNot(normal('[1,2,2]', mode)));
      }
    });

    test('a value that is not a list is compared as is', () {
      expect(normal('42', OutputComparison.unordered), '42');
    });
  });
}
