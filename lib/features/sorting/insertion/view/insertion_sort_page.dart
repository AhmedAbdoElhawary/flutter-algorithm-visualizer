import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/insertion/view_model/insertion_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => InsertionSortNotifier(),
);

class InsertionSortPage extends StatelessWidget {
  const InsertionSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortingPage(instance:
    BasePageViewModel.sortingCards[StringsManager.insertionSort]?.instance ?? _notifierProvider, title: StringsManager.insertionSort);
  }
}
