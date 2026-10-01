import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/selection_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(390, 844)),
      designSize: const Size(390, 844),
      splitScreenMode: false,
      minTextAdapt: false,
    );
  });

  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  void expectDescribed(AlgorithmDescriptionNotifier notifier, String title) {
    expect(notifier.algoComplexity.name, title);
    expect(notifier.algorithmDescription, isNotEmpty);
    expect(notifier.codeSnippet, isNotEmpty);
  }

  group('sorting cards', () {
    final types = {
      SortingAlgoCards.bubble: BubbleSortNotifier,
      SortingAlgoCards.selection: SelectionSortNotifier,
      SortingAlgoCards.insertion: InsertionSortNotifier,
      SortingAlgoCards.merge: MergeSortNotifier,
      SortingAlgoCards.quick: QuickSortNotifier,
    };

    test('every sorting card is listed', () {
      expect(types.keys, SortingAlgoCards.values);
    });

    for (final MapEntry(key: page, value: type) in types.entries) {
      test('${page.name} has its notifier, complexity and description', () {
        final card = BaseViewModel.sortingCards(page);
        final notifier = container.read(card.instance.notifier);

        expect(card.page, page);
        expect(notifier.runtimeType, type);
        expect(card.card.algoComplexity, same(notifier.algoComplexity));
        expectDescribed(notifier, card.title);
      });
    }

    test('each call gives a new provider, so two screens never share a run', () {
      final first = BaseViewModel.sortingCards(SortingAlgoCards.bubble).instance;
      final second = BaseViewModel.sortingCards(SortingAlgoCards.bubble).instance;

      expect(container.read(first.notifier), isNot(same(container.read(second.notifier))));
    });
  });

  group('searching cards', () {
    final types = {
      SearchingAlgoCards.bfs: BFSSearchingNotifier,
      SearchingAlgoCards.dfs: DFSSearchingNotifier,
      SearchingAlgoCards.aStar: AStarSearchingNotifier,
    };

    test('every searching card is listed', () {
      expect(types.keys, SearchingAlgoCards.values);
    });

    for (final MapEntry(key: page, value: type) in types.entries) {
      test('${page.name} has its notifier, complexity and description', () {
        final card = BaseViewModel.searchingCards(page);
        final notifier = container.read(card.instance.notifier);

        expect(card.page, page);
        expect(notifier.runtimeType, type);
        expect(card.card.algoComplexity, same(notifier.algoComplexity));
        expectDescribed(notifier, card.title);
      });
    }
  });

  test('every step a sort makes points at a line of its snippet', () {
    for (final page in SortingAlgoCards.values) {
      final notifier = container.read(BaseViewModel.sortingCards(page).instance.notifier);
      for (final step in notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]).steps) {
        expect(notifier.codeLineForStep(step), inInclusiveRange(0, notifier.codeSnippet.length - 1),
            reason: '${page.name} ${step.kind.name}');
      }
    }
  });
}
