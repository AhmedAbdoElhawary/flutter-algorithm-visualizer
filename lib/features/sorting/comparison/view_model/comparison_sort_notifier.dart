import 'package:algorithm_visualizer/core/helpers/playback_speed.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bubble/view_model/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bucket/view_model/bucket_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/counting/view_model/counting_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/heap/view_model/heap_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/insertion/view_model/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/merge/view_model/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/quick/view_model/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/radix/view_model/radix_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/selection/view_model/selection_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/shell/view_model/shell_sort_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'comparison_sort_state.dart';

class SortingAlgorithm {
  final String name;
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> provider;
  SortingAlgorithm({required this.name, required this.provider});
}

class ComparisonSortNotifier extends StateNotifier<ComparisonSortingNotifierState> {
  ComparisonSortNotifier()
      : super(
          ComparisonSortingNotifierState(
            selectedAlgorithms: [sortingAlgorithms[StringsManager.bubbleSort]!],
          ),
        );

  static final Map<String, SortingAlgorithm> sortingAlgorithms = {
    StringsManager.bubbleSort: SortingAlgorithm(
      name: StringsManager.bubbleSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => BubbleSortNotifier(),
      ),
    ),
    StringsManager.insertionSort: SortingAlgorithm(
      name: StringsManager.insertionSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => InsertionSortNotifier(),
      ),
    ),
    StringsManager.selectionSort: SortingAlgorithm(
      name: StringsManager.selectionSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => SelectionSortNotifier(),
      ),
    ),
    StringsManager.mergeSort: SortingAlgorithm(
      name: StringsManager.mergeSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => MergeSortNotifier(),
      ),
    ),
    StringsManager.heapSort: SortingAlgorithm(
      name: StringsManager.heapSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => HeapSortNotifier(),
      ),
    ),
    StringsManager.quickSort: SortingAlgorithm(
      name: StringsManager.quickSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => QuickSortNotifier(),
      ),
    ),
    StringsManager.radixSort: SortingAlgorithm(
      name: StringsManager.radixSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => RadixSortNotifier(),
      ),
    ),
    StringsManager.shellSort: SortingAlgorithm(
      name: StringsManager.shellSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => ShellSortNotifier(),
      ),
    ),
    StringsManager.countingSort: SortingAlgorithm(
      name: StringsManager.countingSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => CountingSortNotifier(),
      ),
    ),
    StringsManager.bucketSort: SortingAlgorithm(
      name: StringsManager.bucketSort,
      provider: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => BucketSortNotifier(),
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
    final playSorting =
        state.selectedAlgorithms.map((e) => ref.read(e.provider.notifier).togglePlay(context));

    await Future.wait(playSorting.toList());

    _setOperation = _getOperation == SortingEnum.played ? SortingEnum.stopped : SortingEnum.played;

    if (context.mounted) _setOperation = SortingEnum.none;
  }

  Future<void> cancelSorting(WidgetRef ref) async {
    final cancelSorting = state.selectedAlgorithms.map((e) => ref.read(e.provider.notifier).cancelSorting());
    await Future.wait(cancelSorting.toList());
  }
}
