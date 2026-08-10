import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';

abstract class AlgorithmDescriptionNotifier {
  AlgorithmComplexity get algoComplexity;

  String get algorithmDescription;

  List<String> get codeSnippet;

  int codeLineForStep(SortingStep step);
}

extension AlgorithmNotifierExt on AlgorithmDescriptionNotifier {
  String get code => codeSnippet.join('\n');
}
