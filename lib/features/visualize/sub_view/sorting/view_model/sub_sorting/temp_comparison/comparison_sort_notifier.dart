import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bucket_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/counting_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/heap_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/radix_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/selection_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/shell_sort_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'comparison_sort_state.dart';

class SortingAlgorithm {
  final String name;
  final NotifierProvider<SortingNotifier, SortingNotifierState> provider;
  SortingAlgorithm({required this.name, required this.provider});
}

class ComparisonSortNotifier extends Notifier<ComparisonSortingNotifierState> {
  @override
  ComparisonSortingNotifierState build() {
    return ComparisonSortingNotifierState(
      selectedAlgorithms: [sortingAlgorithms[StringsManager.bubbleSort]!],
    );
  }

  static final Map<String, SortingAlgorithm> sortingAlgorithms = {
    StringsManager.bubbleSort: SortingAlgorithm(
      name: StringsManager.bubbleSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => BubbleSortNotifier(),
      ),
    ),
    StringsManager.insertionSort: SortingAlgorithm(
      name: StringsManager.insertionSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => InsertionSortNotifier(),
      ),
    ),
    StringsManager.selectionSort: SortingAlgorithm(
      name: StringsManager.selectionSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => SelectionSortNotifier(),
      ),
    ),
    StringsManager.mergeSort: SortingAlgorithm(
      name: StringsManager.mergeSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => MergeSortNotifier(),
      ),
    ),
    StringsManager.heapSort: SortingAlgorithm(
      name: StringsManager.heapSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => HeapSortNotifier(),
      ),
    ),
    StringsManager.quickSort: SortingAlgorithm(
      name: StringsManager.quickSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => QuickSortNotifier(),
      ),
    ),
    StringsManager.radixSort: SortingAlgorithm(
      name: StringsManager.radixSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => RadixSortNotifier(),
      ),
    ),
    StringsManager.shellSort: SortingAlgorithm(
      name: StringsManager.shellSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => ShellSortNotifier(),
      ),
    ),
    StringsManager.countingSort: SortingAlgorithm(
      name: StringsManager.countingSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => CountingSortNotifier(),
      ),
    ),
    StringsManager.bucketSort: SortingAlgorithm(
      name: StringsManager.bucketSort,
      provider: NotifierProvider<SortingNotifier, SortingNotifierState>(
        () => BucketSortNotifier(),
      ),
    ),
  };

  SortingEnum get _getOperation => state.operationStatus;

  set _setOperation(SortingEnum value) {
    state = state.copyWith(operationStatus: value);
  }

  void selectAlgorithm(String algo) {
    final isExist = state.selectedAlgorithms.firstWhereOrNull((element) => element.name == algo) != null;
    if (isExist && state.selectedAlgorithms.length == 1) return;

    if (isExist) {
      state = state.copyWith(
          selectedAlgorithms: state.selectedAlgorithms.where((element) => element.name != algo).toList());
      return;
    }

    final value = sortingAlgorithms[algo];
    if (value != null) {
      state = state.copyWith(
        selectedAlgorithms: [
          ...state.selectedAlgorithms,
          value,
        ],
      );
    }
  }

  void changeSize(double size, WidgetRef ref) {
    if (_getOperation == SortingEnum.played) return;

    for (var element in state.selectedAlgorithms) {
      ref.read(element.provider.notifier).changeSize(size);
    }
  }

  void changeSpeed(PlaybackSpeed percent, WidgetRef ref) {
    for (var element in state.selectedAlgorithms) {
      ref.read(element.provider.notifier).changeSpeed(percent);
    }
  }

  Future<void> generateAgain(WidgetRef ref) async {
    final generateAgain = state.selectedAlgorithms.map((e) => ref.read(e.provider.notifier).reset());
    await Future.wait(generateAgain.toList());
    _setOperation = SortingEnum.none;
  }

  Future<void> togglePlay(BuildContext context, WidgetRef ref) async {
    final playSorting = state.selectedAlgorithms.map((e) => ref.read(e.provider.notifier).togglePlay(context));

    await Future.wait(playSorting.toList());

    _setOperation = _getOperation == SortingEnum.played ? SortingEnum.stopped : SortingEnum.played;

    if (context.mounted) _setOperation = SortingEnum.none;
  }

  Future<void> cancelSorting(WidgetRef ref) async {
    final cancelSorting = state.selectedAlgorithms.map((e) => ref.read(e.provider.notifier).cancelSorting());
    await Future.wait(cancelSorting.toList());
  }
}
