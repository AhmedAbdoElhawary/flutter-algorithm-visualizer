import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every complexity has its label', () {
    final expected = {
      ONotationComplexity.constant: 'O(1)',
      ONotationComplexity.logN: 'O(log n)',
      ONotationComplexity.n: 'O(n)',
      ONotationComplexity.nLogN: 'O(n log n)',
      ONotationComplexity.n2: 'O(n²)',
      ONotationComplexity.nk: 'O(nk)',
      ONotationComplexity.nPlusK: 'O(n + k)',
      ONotationComplexity.k: 'O(k)',
      ONotationComplexity.vPlusE: 'O(V + E)',
      ONotationComplexity.eLogV: 'O(E log V)',
    };

    expect(expected.keys, ONotationComplexity.values);
    for (final MapEntry(key: complexity, value: label) in expected.entries) {
      expect(complexity.getText, label);
    }
  });

  test('stability reads yes or no', () {
    AlgorithmComplexity complexity({required bool stable}) => AlgorithmComplexity(
      name: 'x',
      spaceComplexity: ONotationComplexity.constant,
      averageTimeComplexity: ONotationComplexity.n,
      worstTimeComplexity: ONotationComplexity.n,
      bestTimeComplexity: ONotationComplexity.n,
      stable: stable,
    );

    expect(complexity(stable: true).getStabilityText, StringsManager.yes);
    expect(complexity(stable: false).getStabilityText, StringsManager.no);
  });
}
