import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each kind of value turns into its plain Dart value', () {
    expect(testValueToRaw(const NullTestValue()), isNull);
    expect(testValueToRaw(const IntTestValue(3)), 3);
    expect(testValueToRaw(const DoubleTestValue(1.5)), 1.5);
    expect(testValueToRaw(const BoolTestValue(true)), true);
    expect(testValueToRaw(const StringTestValue('a')), 'a');
    expect(
      testValueToRaw(const ListTestValue([IntTestValue(1), ListTestValue([NullTestValue()])])),
      [1, [null]],
    );
  });
}
