// import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
// import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   late ProviderContainer container;
//
//   setUp(() {
//     container = ProviderContainer();
//   });
//   //
//   // tearDown(() {
//   //   container.dispose();
//   // });
//
//   SortingNotifier getNotifier(List<int> list) {
//     final provider = BaseViewModel.sortingCards(SortingAlgoCards.bubble).instance..overrideWithBuild(
//           (ref, state) {
//         return SortingNotifierState(
//             list: list.map((e) => SortableItem(id: e, value: e)).toList(), positions: {});
//       },
//     );
//     return container.read<SortingNotifier>(provider.notifier);
//   }
//
//   group(
//     "Test bubble sort throw sorting notifier",
//         () {
//       getNotifier([5,3,9,1,7]).togglePlay();
//       test("description", body);
//     },
//   );
// }
