import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a run is either playing, stopped, or not started', () {
    expect(SortingEnum.values, [SortingEnum.played, SortingEnum.stopped, SortingEnum.none]);
  });
}
