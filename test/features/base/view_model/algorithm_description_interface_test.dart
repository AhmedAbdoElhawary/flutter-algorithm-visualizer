import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

class _Described implements AlgorithmDescriptionNotifier {
  _Described(this.codeSnippet);

  @override
  final List<String> codeSnippet;

  @override
  AlgorithmComplexity get algoComplexity => throw UnimplementedError();

  @override
  String get algorithmDescription => '';

  @override
  int codeLineForStep(SortStep step) => 0;
}

void main() {
  test('code is the snippet lines joined', () {
    expect(_Described(['for i in list:', '  swap()']).code, 'for i in list:\n  swap()');
  });

  test('an empty snippet is empty code', () {
    expect(_Described([]).code, '');
  });
}
